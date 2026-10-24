#!/usr/bin/env python3
"""How far apart are two KN5000 main-program ROMs?  Sizes the v5 / v6 ports.

QUESTION ANSWERED
    v7, v8, v9 and v10 are byte-exact targets.  The v5 and v6 dumps exist in
    the private romset but have no source.  Before a lane ports v7's (or v9's)
    source to them it needs to know how big the job is: how many bytes differ,
    and whether the images differ in place (same layout, patched bytes) or by
    inserted / deleted code that shifts everything after it, which is what
    turns a port into relabelling work.

    For each pair A -> B this prints:

      positional diff   bytes with A[i] != B[i] at the same offset.  Cheap,
                        and meaningless once anything has shifted.
      offset map        an alignment of B against A: blocks of identical bytes
                        at a constant shift (delta = B offset - A offset),
                        found from 32-byte sequences that occur exactly once
                        in each image, chained in increasing order on both
                        sides (longest increasing subsequence) and extended
                        byte by byte.  Reported: bytes covered, block count,
                        distinct deltas, and the GAPS between blocks -- the
                        bytes of A that have no counterpart in B (to change or
                        delete when porting A's source) and the bytes of B
                        with no counterpart in A (to write).  A gap that is
                        the same size on both sides is a substitution; one
                        that is not changes the shift (an insertion/deletion).

    The offset map is an ESTIMATE, a lower bound on what matches: a region
    that differs from its counterpart every 32 bytes or less has no unique
    anchor, so it is reported as gap even when most of its bytes agree, and
    runs of fill (0xff) between blocks with different shifts count as gap.

INPUTS
    original_ROMs/kn5000_vN_program.rom when it exists (v7, v9, v10; v8 after
    `make`), otherwise $KN5000_ROMS_DIR/kn5000_vN_program.rom, default
    ~/compartilhado/technics_roms/roms/kn5000 (the private romset; v5 and v6
    are only there).  Each input's SHA-1 is printed so a figure can be tied to
    the image it came from.

RUN
    python3 scripts/analysis/kn5000_version_delta.py                 # default pairs
    python3 scripts/analysis/kn5000_version_delta.py v6:v7 --map OUT.tsv
    python3 scripts/analysis/kn5000_version_delta.py v6:v7 --k 16      # anchor length
    --map writes the block list of the LAST pair (A start, A end, B start,
    delta; CPU addresses) for a porting lane to work from.
    Default pairs: v5:v6 v6:v7 v5:v7, then v7:v9 and v9:v10 as yardsticks
    (v7 was ported from v9/v10, so its distance is a known amount of work).
"""
import bisect
import hashlib
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ROMS_DIR = os.environ.get("KN5000_ROMS_DIR",
                          os.path.expanduser("~/compartilhado/technics_roms/roms/kn5000"))
BASE = 0xE00000
K = 32
DEFAULT_PAIRS = ["v5:v6", "v6:v7", "v5:v7", "v7:v9", "v9:v10"]


def rom_path(tag):
    name = f"kn5000_{tag}_program.rom"
    local = os.path.join(ROOT, "original_ROMs", name)
    return local if os.path.exists(local) else os.path.join(ROMS_DIR, name)


def unique_kgrams(data):
    """{kgram: offset} for the K-byte sequences that occur exactly once."""
    seen = {}
    for i in range(len(data) - K + 1):
        s = data[i:i + K]
        seen[s] = -1 if s in seen else i
    return {s: i for s, i in seen.items() if i >= 0}


def anchors(a, b):
    """Monotonic chain of (a_off, b_off) unique-kgram matches."""
    ua = unique_kgrams(a)
    pairs = []
    for i in range(len(b) - K + 1):
        j = ua.get(b[i:i + K])
        if j is not None:
            pairs.append((j, i))
    # a k-gram unique in A may still repeat in B; keep only B-unique ones too
    ub = unique_kgrams(b)
    pairs = sorted(p for p in pairs if ub.get(b[p[1]:p[1] + K]) == p[1])
    # longest strictly increasing subsequence on the B offsets
    tails, tails_idx, prev = [], [], [None] * len(pairs)
    for n, (_, bo) in enumerate(pairs):
        k = bisect.bisect_left(tails, bo)
        if k == len(tails):
            tails.append(bo)
            tails_idx.append(n)
        else:
            tails[k] = bo
            tails_idx[k] = n
        prev[n] = tails_idx[k - 1] if k else None
    chain, n = [], (tails_idx[-1] if tails_idx else None)
    while n is not None:
        chain.append(pairs[n])
        n = prev[n]
    return chain[::-1]


def blocks(a, b, chain):
    """Extend the anchor chain into maximal identical blocks (a0, a1, b0)."""
    out = []
    fa = fb = 0                     # frontier: nothing before it may be reused
    for ao, bo in chain:
        if ao < fa or bo < fb:
            continue
        s_a, s_b = ao, bo
        while s_a > fa and s_b > fb and a[s_a - 1] == b[s_b - 1]:
            s_a -= 1
            s_b -= 1
        e_a, e_b = ao + K, bo + K
        while e_a < len(a) and e_b < len(b) and a[e_a] == b[e_b]:
            e_a += 1
            e_b += 1
        out.append((s_a, e_a, s_b))
        fa, fb = e_a, e_b
    return out


def analyse(ta, tb):
    a = open(rom_path(ta), "rb").read()
    b = open(rom_path(tb), "rb").read()
    pos = sum(1 for x, y in zip(a, b) if x != y) + abs(len(a) - len(b))
    bl = blocks(a, b, anchors(a, b))
    matched = sum(e - s for s, e, _ in bl)
    deltas = {}
    for s, e, sb in bl:
        deltas[sb - s] = deltas.get(sb - s, 0) + (e - s)
    gaps = []                       # (a_start, a_len, b_start, b_len)
    pa = pb = 0
    for s, e, sb in bl + [(len(a), len(a), len(b))]:
        if s > pa or sb > pb:
            gaps.append((pa, s - pa, pb, sb - pb))
        pa, pb = e, sb + (e - s)
    subst = [g for g in gaps if g[1] == g[3]]
    indel = [g for g in gaps if g[1] != g[3]]
    subst_diff = sum(sum(1 for i in range(g[1]) if a[g[0] + i] != b[g[2] + i]) for g in subst)
    reloc = relocation_bytes(a, b, bl, subst)
    return dict(a=a, b=b, pos=pos, blocks=bl, matched=matched, deltas=deltas, gaps=gaps,
                subst=subst, indel=indel, subst_diff=subst_diff, reloc=reloc)


def relocation_bytes(a, b, bl, subst):
    """Differing bytes in same-size gaps explained as a moved 24-bit pointer.

    A byte counts when it lies in a 3-byte little-endian value that is a ROM
    address (0xe00000-0xffffff) on both sides and the offset map sends A's
    target to B's: the pointer changed only because what it points at moved.
    With symbolic source such bytes cost nothing to port.  16-bit relative
    displacements (jr / calr / jrl) and moved RAM variables are NOT recognised,
    so what is left over is an upper bound on real change.
    """
    starts = [s for s, _, _ in bl]

    def maps(ta, tb):
        k = bisect.bisect_right(starts, ta) - 1
        if k < 0:
            return False
        s, e, sb = bl[k]
        return s <= ta < e and tb == ta + (sb - s)

    hit = 0
    for ga, n, gb, _ in subst:
        covered = set()
        for i in range(n):
            if a[ga + i] == b[gb + i] or i in covered:
                continue
            for s in (i - 2, i - 1, i):
                if s < 0 or s + 3 > n:
                    continue
                va = int.from_bytes(a[ga + s:ga + s + 3], "little")
                vb = int.from_bytes(b[gb + s:gb + s + 3], "little")
                if va >= BASE and vb >= BASE and maps(va - BASE, vb - BASE):
                    covered.update((s, s + 1, s + 2))
                    break
        hit += sum(1 for i in covered if a[ga + i] != b[gb + i])
    return hit


def report(ta, tb, r):
    n = len(r["a"])
    agap = sum(g[1] for g in r["gaps"])
    bgap = sum(g[3] for g in r["gaps"])
    print(f"=== {ta} -> {tb} ===")
    print(f"  positional diff ...... {r['pos']:>9,} B ({100.0 * r['pos'] / n:.2f}%)")
    print(f"  aligned (offset map) . {r['matched']:>9,} B in {len(r['blocks']):,} blocks, "
          f"{len(r['deltas']):,} distinct deltas")
    print(f"  gaps ................. {len(r['gaps']):,}: {agap:,} B of {ta} / {bgap:,} B of {tb} "
          f"unaligned")
    print(f"    same-size (subst) .. {len(r['subst']):,} gaps, "
          f"{sum(g[1] for g in r['subst']):,} B, of which {r['subst_diff']:,} B differ")
    grow = sum(g[3] - g[1] for g in r["indel"] if g[3] > g[1])
    shrink = sum(g[1] - g[3] for g in r["indel"] if g[1] > g[3])
    # Both images are 2 MiB, so the two sides' gap totals are equal and growth
    # always equals shrinkage (code that grows is paid for by fill that
    # shrinks).  `churn` is that amount: how far the layout moves around.
    assert grow == shrink
    print(f"    size-changing ...... {len(r['indel']):,} gaps, "
          f"{sum(g[1] for g in r['indel']):,} B of {ta}; layout churn {grow:,} B "
          f"(as much grows as shrinks: both images are 2 MiB)")
    real = r["subst_diff"] - r["reloc"] + sum(g[1] for g in r["indel"])
    print(f"    moved-pointer bytes  {r['reloc']:,} of the {r['subst_diff']:,} differing "
          f"same-size-gap bytes (24-bit ROM pointers the map explains)")
    print(f"  estimated change ..... {real:,} B of {ta} "
          f"(differing same-size-gap bytes - moved pointers + size-changing gaps)")
    top = sorted(r["deltas"].items(), key=lambda kv: -kv[1])[:6]
    print("  largest deltas (shift: bytes) " +
          ", ".join(f"{d:+#x}: {c:,}" for d, c in top))
    big = sorted(r["gaps"], key=lambda g: -max(g[1], g[3]))[:5]
    print("  largest gaps (A addr+len -> B addr+len) " +
          "; ".join(f"{BASE + g[0]:06x}+{g[1]} -> {BASE + g[2]:06x}+{g[3]}" for g in big))
    print()


def main():
    global K
    args = sys.argv[1:]
    if "--k" in args:
        i = args.index("--k")
        K = int(args[i + 1])
        del args[i:i + 2]
    mapfile = None
    if "--map" in args:
        i = args.index("--map")
        mapfile = args[i + 1]
        del args[i:i + 2]
    pairs = args or DEFAULT_PAIRS
    tags = sorted({t for p in pairs for t in p.split(":")}, key=lambda t: int(t[1:]))
    for t in tags:
        p = rom_path(t)
        if not os.path.exists(p):
            sys.exit(f"missing input {p} (set KN5000_ROMS_DIR)")
        shown = os.path.relpath(p, ROOT) if p.startswith(ROOT + os.sep) else p
        print(f"  {t:4} {hashlib.sha1(open(p, 'rb').read()).hexdigest()}  {shown}")
    print(f"  K = {K}-byte unique anchors\n")
    r = None
    for p in pairs:
        ta, tb = p.split(":")
        r = analyse(ta, tb)
        report(ta, tb, r)
    if mapfile and r is not None:
        with open(mapfile, "w") as fh:
            fh.write("a_start\ta_end\tb_start\tdelta\n")
            for s, e, sb in r["blocks"]:
                fh.write(f"{BASE + s:06x}\t{BASE + e:06x}\t{BASE + sb:06x}\t{sb - s:+d}\n")
        print(f"wrote {len(r['blocks']):,} blocks to {mapfile}")


if __name__ == "__main__":
    main()
