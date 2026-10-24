#!/usr/bin/env python3
"""How far apart are two HD-AE5000 ROM versions, and what kind of change is it?

QUESTION ANSWERED
    The HD-AE5000 expansion ROM (512 KiB at 0x280000) exists in four dumps:
    v2.06i (the byte-exact source tree in hdae5000/), v2.01i, v1.15i and
    v1.10i (private romset; hd-ae5000.ic4 there is v1.15i).  Before a lane
    ports the v2.06i source to an older version it needs to know how big the
    job is and what KIND of bytes differ: moved pointers cost nothing with
    symbolic source, a moved RAM variable or a renumbered UI object costs one
    constant, a changed picture costs one image file, and only the rest is
    code or data that really changed.

    For each pair A -> B this prints the offset-map measures of
    kn5000_version_delta.py (whose anchors() / blocks() it reuses: 32-byte
    sequences unique in both images, chained monotonically and extended byte
    by byte into identical blocks; what lies between blocks is a GAP), then
    classifies every differing byte of the same-size gaps by the value it
    sits in:

      rom-moved   a 3-byte little-endian value in 0x280000-0x2fffff on both
                  sides that the offset map sends from A's target to B's
                  (a pointer whose target moved);
      rom-other   in that range on both sides, but the map does not explain it
                  (target inside a gap);
      ram         a 3-byte value in the expansion's RAM 0x200000-0x23ffff on
                  both sides (a moved variable);
      ui-object   a 4-byte value 0x007fNNNN on both sides -- the id of a UI
                  object of the HD-AE5000's title 0x7F (HDAE5000_OBJ_*):
                  objects were added or removed, so the ids renumber;
      other       everything else.
    Bytes of a size-changing gap are not classified (counted as a whole).
    Each gap is attributed to the A symbol it starts in when A is v2.06i
    (symbols/hdae5000_symbols_reference.txt), and the differing bytes are
    totalled per top-level A symbol (local `_Skip`/`_Loop`-style suffixes
    folded into their routine only by nearest-symbol lookup; read the list
    as "where", not "what").

    Caveats as for kn5000_version_delta.py: the offset map is a lower bound
    on what matches; a 3-byte window can be a coincidence (two unrelated
    bytes that happen to look like an address), so the classes are an
    estimate of the mix, not a proof per byte.

INPUTS
    original_ROMs/hd-ae5000_<tag>.ic4 when it exists (v2_06i is tracked; the
    others appear there once `make` has copied them), otherwise
    $KN5000_ROMS_DIR/hd-ae5000_<tag>.ic4, default
    ~/compartilhado/technics_roms/roms/kn5000 (the private romset).  Each
    input's SHA-1 is printed so a figure can be tied to the image.

RUN
    python3 scripts/analysis/hdae5000_version_delta.py                # default pairs
    python3 scripts/analysis/hdae5000_version_delta.py v2_06i:v2_01i --top 30
    python3 scripts/analysis/hdae5000_version_delta.py v2_06i:v2_01i --map OUT.tsv
    Default pairs: v2_06i:v2_01i v2_01i:v1_15i v1_15i:v1_10i v2_06i:v1_15i.
    --map writes the block list of the LAST pair (A start, A end, B start,
    delta; CPU addresses).  --top N sets how many gaps / symbols are listed.
"""
import bisect
import collections
import hashlib
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import kn5000_version_delta as kvd  # noqa: E402  (anchors / blocks, K = 32)

ROMS_DIR = os.environ.get("KN5000_ROMS_DIR",
                          os.path.expanduser("~/compartilhado/technics_roms/roms/kn5000"))
BASE, END = 0x280000, 0x300000
RAM_LO, RAM_HI = 0x200000, 0x240000
DEFAULT_PAIRS = ["v2_06i:v2_01i", "v2_01i:v1_15i", "v1_15i:v1_10i", "v2_06i:v1_15i"]
SYMFILE = os.path.join(ROOT, "symbols/hdae5000_symbols_reference.txt")


def rom_path(tag):
    name = f"hd-ae5000_{tag}.ic4"
    local = os.path.join(ROOT, "original_ROMs", name)
    return local if os.path.exists(local) else os.path.join(ROMS_DIR, name)


def load_symbols():
    syms = []
    if os.path.exists(SYMFILE):
        for ln in open(SYMFILE, encoding="latin-1"):
            p = ln.split()
            if len(p) == 2 and not ln.startswith("#"):
                v = int(p[1], 16)
                if BASE <= v < END:
                    syms.append((v, p[0]))
    syms.sort()
    return syms


def analyse(ta, tb):
    a = open(rom_path(ta), "rb").read()
    b = open(rom_path(tb), "rb").read()
    assert len(a) == len(b) == END - BASE
    pos = sum(1 for x, y in zip(a, b) if x != y)
    bl = kvd.blocks(a, b, kvd.anchors(a, b))
    gaps = []
    pa = pb = 0
    for s, e, sb in bl + [(len(a), len(a), len(b))]:
        if s > pa or sb > pb:
            gaps.append((pa, s - pa, pb, sb - pb))
        pa, pb = e, sb + (e - s)
    return a, b, pos, bl, gaps


def classify(a, b, bl, gaps):
    """Per differing byte of the same-size gaps: its class (see docstring)."""
    starts = [s for s, _, _ in bl]

    def maps(ta, tb):
        k = bisect.bisect_right(starts, ta) - 1
        if k < 0:
            return False
        s, e, sb = bl[k]
        return s <= ta < e and tb == ta + (sb - s)

    out = {}                      # A offset -> class
    for ga, n, gb, nb in gaps:
        if n != nb:
            continue
        for i in range(n):
            if a[ga + i] == b[gb + i] or (ga + i) in out:
                continue
            cls = "other"
            for s in (i - 3, i - 2, i - 1, i):        # 4-byte UI object id first
                if 0 <= s and s + 4 <= n:
                    va = int.from_bytes(a[ga + s:ga + s + 4], "little")
                    vb = int.from_bytes(b[gb + s:gb + s + 4], "little")
                    if va >> 16 == 0x7f and vb >> 16 == 0x7f:
                        cls = "ui-object"
                        break
            if cls == "other":
                for s in (i - 2, i - 1, i):
                    if s < 0 or s + 3 > n:
                        continue
                    va = int.from_bytes(a[ga + s:ga + s + 3], "little")
                    vb = int.from_bytes(b[gb + s:gb + s + 3], "little")
                    if BASE <= va < END and BASE <= vb < END:
                        cls = "rom-moved" if maps(va - BASE, vb - BASE) else "rom-other"
                        break
                    if RAM_LO <= va < RAM_HI and RAM_LO <= vb < RAM_HI:
                        cls = "ram"
                        break
            out[ga + i] = cls
    return out


def report(ta, tb, a, b, pos, bl, gaps, cls, syms, top):
    n = len(a)
    deltas = collections.Counter()
    for s, e, sb in bl:
        deltas[sb - s] += e - s
    matched = sum(e - s for s, e, _ in bl)
    subst = [g for g in gaps if g[1] == g[3]]
    indel = [g for g in gaps if g[1] != g[3]]
    churn = sum(g[3] - g[1] for g in indel if g[3] > g[1])
    c = collections.Counter(cls.values())
    print(f"=== {ta} -> {tb} ===")
    print(f"  positional diff ...... {pos:>9,} B ({100.0 * pos / n:.2f}%)")
    print(f"  aligned (offset map) . {matched:>9,} B in {len(bl):,} blocks, "
          f"{len(deltas):,} distinct deltas")
    print(f"  gaps ................. {len(gaps):,}: {sum(g[1] for g in gaps):,} B of {ta} "
          f"unaligned")
    print(f"    same-size .......... {len(subst):,} gaps, {sum(g[1] for g in subst):,} B, "
          f"of which {len(cls):,} B differ:")
    for k in ("rom-moved", "rom-other", "ram", "ui-object", "other"):
        print(f"      {k:<11} {c.get(k, 0):>9,} B")
    print(f"    size-changing ...... {len(indel):,} gaps, {sum(g[1] for g in indel):,} B of {ta}, "
          f"{sum(g[3] for g in indel):,} B of {tb}; layout churn {churn:,} B")
    est = c.get("other", 0) + c.get("rom-other", 0) + sum(g[1] for g in indel)
    print(f"  estimated change ..... {est:,} B of {ta} (other + rom-other + size-changing gaps; "
          f"rom-moved, ram and ui-object bytes left out)")
    print("  largest deltas (shift: bytes) " +
          ", ".join(f"{d:+#x}: {k:,}" for d, k in deltas.most_common(6)))
    use_syms = syms and ta == "v2_06i"
    addrs = [s[0] for s in syms]

    def where(off):
        if not use_syms:
            return ""
        k = bisect.bisect_right(addrs, BASE + off) - 1
        return f"{syms[k][1]}+{BASE + off - syms[k][0]:#x}" if k >= 0 else "?"
    print(f"  largest gaps (A addr+len -> B addr+len, differing bytes or 'resized'):")
    for g in sorted(gaps, key=lambda g: -max(g[1], g[3]))[:top]:
        nd = sum(1 for i in range(g[1]) if (g[0] + i) in cls) if g[1] == g[3] else None
        tag = f"{nd:,} differ" if nd is not None else "resized"
        print(f"    {BASE + g[0]:06x}+{g[1]:<6} -> {BASE + g[2]:06x}+{g[3]:<6} {tag:<13} {where(g[0])}")
    if use_syms:
        per = collections.defaultdict(collections.Counter)
        for off, k in cls.items():
            j = bisect.bisect_right(addrs, BASE + off) - 1
            per[syms[j][1] if j >= 0 else "?"][k] += 1
        print(f"  differing same-size-gap bytes per {ta} symbol (top {top}):")
        for name, cc in sorted(per.items(), key=lambda kv: -sum(kv[1].values()))[:top]:
            detail = ", ".join(f"{k} {v:,}" for k, v in cc.most_common())
            print(f"    {sum(cc.values()):>7,}  {name}: {detail}")
    print()


def main():
    args = sys.argv[1:]
    top, mapfile = 15, None
    if "--top" in args:
        i = args.index("--top")
        top = int(args[i + 1])
        del args[i:i + 2]
    if "--map" in args:
        i = args.index("--map")
        mapfile = args[i + 1]
        del args[i:i + 2]
    pairs = args or DEFAULT_PAIRS
    tags = []
    for p in pairs:
        for t in p.split(":"):
            if t not in tags:
                tags.append(t)
    for t in tags:
        p = rom_path(t)
        if not os.path.exists(p):
            sys.exit(f"missing input {p} (set KN5000_ROMS_DIR)")
        shown = os.path.relpath(p, ROOT) if p.startswith(ROOT + os.sep) else p
        print(f"  {t:7} {hashlib.sha1(open(p, 'rb').read()).hexdigest()}  {shown}")
    print(f"  K = {kvd.K}-byte unique anchors\n")
    syms = load_symbols()
    last = None
    for p in pairs:
        ta, tb = p.split(":")
        a, b, pos, bl, gaps = analyse(ta, tb)
        cls = classify(a, b, bl, gaps)
        report(ta, tb, a, b, pos, bl, gaps, cls, syms, top)
        last = bl
    if mapfile and last is not None:
        with open(mapfile, "w") as fh:
            fh.write("a_start\ta_end\tb_start\tdelta\n")
            for s, e, sb in last:
                fh.write(f"{BASE + s:06x}\t{BASE + e:06x}\t{BASE + sb:06x}\t{sb - s:+d}\n")
        print(f"wrote {len(last):,} blocks to {mapfile}")


if __name__ == "__main__":
    main()
