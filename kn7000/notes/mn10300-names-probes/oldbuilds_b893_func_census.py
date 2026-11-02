#!/usr/bin/env python3
"""oldbuilds_b893_func_census.py -- which of program 893's (or 935's) func_<ADDR> routines have
no counterpart in build 941, and in which subsystem?

Question (older-program-builds.md, "Still open"): 893's func_ labels are named only where
941's names port.  A func_ of the build falls in one of four classes:
  * twin-unnamed : the exact 941 -> build offset map (its longest 1:1 run of 16+ bytes that
                   covers the byte) places a 941 byte on its first byte,
                   and 941 has no name there either -- naming it is 941's job, the name
                   then ports;
  * twin-named   : 941 names that byte but the name did not reach the build (a port rule
                   refused it; listed so it can be looked at);
  * near-twin    : no 1:1 run of 16+ bytes holds its first byte (the rule the name port
                   uses), but 941 has a routine with the same relocation-masked code
                   (port_names_by_code.signature, entry to first return) within 0x100 bytes
                   of where the nearest mapped run puts it -- a small routine whose
                   relocated operands broke the run; reported with 941's address and name;
  * own          : neither: code 941 rewrote, moved or deleted; only a name written for
                   this build can reach it.
"Subsystem" is the nearest name before it in the build's symbol files (its first two
CamelCase words, e.g. SdSnd, DspBoot), which is how the source reads.

Measured 2026-11-02 at c240d1c0b: b893 6463 func_ = twin-unnamed 6402, own 40, near-twin 16,
twin-named 5 (the 5 are uncommitted kn7000_manual.sym rows; make symbols-893 carries them).

Run (from kn7000/; the offset map is cached, about 10 minutes the first time):
    UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm \
        python3 -I notes/mn10300-names-probes/oldbuilds_b893_func_census.py b893 [CACHE_DIR] [-v]
"""
import bisect
import collections
import glob
import re
import sys

sys.path.insert(0, "tools")
import offset_map as OM           # noqa: E402
import gen_image_s as GI          # noqa: E402
import port_names_by_code as PN   # noqa: E402
import os                         # noqa: E402  (UNIDASM below)

UNIDASM = os.environ.get("UNIDASM", "/home/fsanches/compartilhado/mame-sony-video/unidasm")

BASE, LIB = 0x48400000, 0x4C000000
BUILDS = {"b893": ("baserom/kn7000_program_b893.rom", 0x1846A0, 0x3B76B1),
          "b935": ("baserom/kn7000_program_b935.rom", 0x18595C, 0x3B8F6D)}
LIB941 = 0x3B8FD1


def func_labels(srcdir):
    """CPU address of every func_<ADDR> label of a generated source (read as bytes)."""
    out = set()
    for path in glob.glob(f"{srcdir}/program.s") + glob.glob(f"{srcdir}/program/*.s"):
        for m in re.finditer(rb"^func_([0-9A-F]{8}):", open(path, "rb").read(), re.M):
            out.add(int(m.group(1), 16))
    return out


def sym_rows(paths):
    d = {}
    for p in paths:
        for line in open(p):
            m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)", line)
            if m and not m.group(2).endswith("_entry"):
                d.setdefault(int(m.group(1), 16), m.group(2))
    return d


def names941():
    return sym_rows(("kn7000.sym", "kn7000_manual.sym", "kn7000_exports_from_942.sym"))


def main():
    key = sys.argv[1] if len(sys.argv) > 1 and not sys.argv[1].startswith("-") else "b893"
    cache = next((a for a in sys.argv[2:] if not a.startswith("-")), "build/offset-maps")
    rom, r1_end, libf = BUILDS[key]
    A = open("baserom/kn7000_program.rom", "rb").read()
    B = open(rom, "rb").read()
    pmap = OM.cached(A, B, cache)
    a_all = set(names941())
    for path in glob.glob("src/program/*.s"):
        for m in re.finditer(rb"^func_([0-9A-F]{8}):", open(path, "rb").read(), re.M):
            a_all.add(int(m.group(1), 16))
    # build -> 941.  The map is not one-to-one in the build's space: where 941 rewrote the
    # DSP block, difflib aligned single bytes of it with bytes scattered over the build's
    # moved code, so take the LONGEST 1:1 run that covers the build byte, and ignore runs
    # shorter than MIN_RUN (the rule port_symbols.py --min-run 16 applies to names).
    MIN_RUN = 16
    inv = sorted((b0, b0 + a1 - a0, a0) for a0, a1, b0 in pmap.blocks if a1 - a0 >= MIN_RUN)
    los = [x[0] for x in inv]
    longest = max(x[1] - x[0] for x in inv)

    def back(off):                      # build file offset -> 941 file offset
        i = bisect.bisect_right(los, off) - 1
        best = None
        while i >= 0 and inv[i][0] > off - longest:
            lo, hi, a0 = inv[i]
            if lo <= off < hi and (best is None or hi - lo > best[1] - best[0]):
                best = inv[i]
            i -= 1
        return None if best is None else best[2] + off - best[0]

    def image(path, code):
        img = GI.Image.__new__(GI.Image)
        img.rom, img.base, img.code, img.unidasm = path, BASE, sorted(code), UNIDASM
        img.d, img.ix = open(path, "rb").read(), {}
        return img
    ia = image("baserom/kn7000_program.rom", [(0x80, 0x186000, BASE), (LIB941, 0x3F6F01, LIB - LIB941)])
    ib = image(rom, [(0x80, r1_end, BASE), (libf, len(B.rstrip(b"\xff")), LIB - libf)])
    starts941 = sorted(o for o in (ia.off(c) for c in a_all) if o is not None)

    def near_twin(off, lib):
        """941 file offset of a same-code routine near the predicted place, else None."""
        i = bisect.bisect_right(los, off) - 1
        if i < 0:
            return None
        pred = inv[i][2] + off - inv[i][0]
        sb = PN.signature(ib, off)
        if sb is None:
            return None
        j = bisect.bisect_left(starts941, pred - 0x100)
        while j < len(starts941) and starts941[j] <= pred + 0x100:
            if PN.signature(ia, starts941[j]) == sb:
                return starts941[j]
            j += 1
        return None

    a = names941()
    named = sym_rows([f"kn7000_{key}.sym", f"kn7000_{key}_manual.sym", f"kn7000_{key}_exports.sym",
                      f"kn7000_{key}_bycode.sym"])
    funcs = func_labels(f"src/{key}")
    L = sorted([(c, n) for c, n in named.items() if c >= BASE] + [(c, f"func_{c:08X}") for c in funcs])
    cls = collections.Counter()
    by_sub = collections.defaultdict(collections.Counter)
    rows = collections.defaultdict(list)
    last = "-"
    for cpu, nm in L:
        if not nm.startswith("func_"):
            w = re.findall(r"[A-Z][a-z0-9]*", nm)
            last = "".join(w[:2]) if w else nm
            continue
        lib = cpu >= LIB
        off = cpu - LIB + libf if lib else cpu - BASE
        ao = back(off)
        if ao is None:
            c, tw = "own", near_twin(off, lib)
            if tw is not None:
                c, ao = "near-twin", tw
        else:
            acpu = (ao - LIB941 + LIB) if ao >= LIB941 else ao + BASE
            c = "twin-named" if acpu in a else "twin-unnamed"
        cls[c] += 1
        by_sub[c][("lib:" if lib else "") + last] += 1
        rows[c].append((cpu, last, ao))
    print(f"{key}: {sum(cls.values())} func_ labels: " + ", ".join(f"{k} {v}" for k, v in cls.most_common()))
    for c in ("own", "near-twin", "twin-named", "twin-unnamed"):
        top = by_sub[c].most_common(None if "-v" in sys.argv else 30)
        print(f"\n== {c} by subsystem (nearest named routine before it):")
        for s, n in top:
            print(f"  {n:5d}  {s}")
    if "-v" in sys.argv:
        for c in ("own", "near-twin", "twin-named"):
            print(f"\n== {c} rows")
            for cpu, sub, ao in rows[c]:
                extra = ""
                if ao is not None:
                    acpu = (ao - LIB941 + LIB) if ao >= LIB941 else ao + BASE
                    extra = f"  941 {acpu:#010x} {a.get(acpu, 'func_%08X' % acpu)}"
                print(f"  {cpu:#010x}  after {sub}{extra}")


main()
