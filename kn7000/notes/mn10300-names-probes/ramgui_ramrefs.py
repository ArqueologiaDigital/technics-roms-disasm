#!/usr/bin/env python3
"""ramgui_ramrefs: which source lines of each KN7000 program build (941, 942 + the
SP7001 plug-in, 935, 893) name a work-RAM address inside a given span, and which
referenced addresses bound the span from below and above?

Question it answers: is a RAM span referenced by any build (directly, as an
operand constant, a typed-data word spelled in decimal, or a symbol (+ offset) whose
value lies in the span), and where is the nearest referenced address on each side.
Both the cached alias 0x50xxxxxx and the uncached alias 0x90xxxxxx are matched.  It
also counts LE 32-bit words in the build's images whose value lies in the span (any
alignment: an upper bound), and lists the 4-aligned ones in the program's typed data
region, in the SP7001 plug-in (table ROM 0x3E8000..) and in BASEEXT.XAP: pointers held
as raw data would be among them.  Words inside code are instruction overlaps; every
operand of a decoded instruction is already in the source.

It reads the generated, byte-exact sources (src/<build>/...), so a computed
access (base + index) is NOT seen: such accesses must be read in the code.

usage (from kn7000/):
  python3 -I notes/mn10300-names-probes/ramgui_ramrefs.py BUILD LO HI [BUILD LO HI ...]
  BUILD = 941 | 942 | 935 | 893 ; LO/HI hex, HI exclusive
example:
  python3 -I notes/mn10300-names-probes/ramgui_ramrefs.py 941 0x5004a5fc 0x5004a76c
"""
import array, bisect, glob, os, re, sys

TREES = {
    "941": (["src/program/*.s", "src/program/data/*.s", "src/program.s"], ["src/symbols.inc"],
            ["src/program/data/labels.sym"], ["baserom/kn7000_program.rom"]),
    "942": (["src/sp7001/program/*.s", "src/sp7001/program/data/*.s", "src/sp7001/program.s",
             "src/sp7001/table.s", "src/sp7001/baseext.s", "src/sp7001/plugin/data/*.s"],
            ["src/sp7001/symbols.inc", "src/sp7001/table_symbols.inc"],
            ["src/sp7001/program/data/labels.sym", "src/sp7001/plugin/data/labels.sym"],
            ["baserom/kn7000_program_sp7001.rom", "baserom/kn7000_table_sp7001.rom",
             "baserom/sp7001_baseext.xap"]),
    "935": (["src/b935/program/*.s", "src/b935/program/data/*.s", "src/b935/program.s"],
            ["src/b935/symbols.inc"], ["src/b935/program/data/labels.sym"],
            ["baserom/kn7000_program_b935.rom"]),
    "893": (["src/b893/program/*.s", "src/b893/program/data/*.s", "src/b893/program.s"],
            ["src/b893/symbols.inc"], ["src/b893/program/data/labels.sym"],
            ["baserom/kn7000_program_b893.rom"]),
}
HEX = re.compile(rb"\b0x([59]0[0-9a-fA-F]{6})\b")
DEC = re.compile(rb"(?<![\w.])(13[0-9]{8}|2[0-9]{9})(?![\w.])")     # decimal spellings in typed data
SYMOFF = re.compile(rb"\b([A-Za-z_]\w*)\b(?:\s*\+\s*(0x[0-9a-fA-F]+|[0-9]+))?")


def load(build):
    srcs, incs, labs, roms = TREES[build]
    files = sorted({f for g in srcs for f in glob.glob(g)})
    sym = {}
    for f in incs:
        if os.path.exists(f):
            for ln in open(f, "rb"):
                m = re.match(rb"\.equ\s+(\w+),\s*0x([0-9A-Fa-f]+)", ln)
                if m:
                    sym[m.group(1)] = int(m.group(2), 16)
    for f in labs:
        if os.path.exists(f):
            for ln in open(f, "rb"):
                p = ln.split()
                if len(p) >= 2 and not ln.startswith(b";"):
                    sym.setdefault(p[1], int(p[0], 16))
    ramsym = {n: a for n, a in sym.items() if 0x50000000 <= a < 0x50400000}
    refs = []                      # (addr, file, lineno, text)
    for f in files:
        for i, ln in enumerate(open(f, "rb").read().split(b"\n"), 1):
            code = ln.split(b"#", 1)[0]
            if not code.strip():
                continue
            for m in HEX.finditer(code):
                v = int(m.group(1), 16)
                if 0x90000000 <= v < 0x90400000:
                    v -= 0x40000000          # uncached alias of work RAM
                if 0x50000000 <= v < 0x50400000:
                    refs.append((v, f, i, ln))
            for m in DEC.finditer(code):
                v = int(m.group(1))
                if 0x90000000 <= v < 0x90400000:
                    v -= 0x40000000
                if 0x50000000 <= v < 0x50400000:
                    refs.append((v, f, i, ln))
            st = code.lstrip()
            if st.startswith(b".equ"):
                continue
            body = code.split(b":", 1)[1] if re.match(rb"^[A-Za-z_]\w*:", code) else code
            for m in SYMOFF.finditer(body):
                a = ramsym.get(m.group(1))
                if a is not None:
                    refs.append((a + int(m.group(2) or b"0", 0), f, i, ln))
    refs.sort(key=lambda r: r[0])
    blobs = [open(r, "rb").read() for r in roms if os.path.exists(r)]
    # the program image's typed data region: first .. last data label (labels.sym);
    # code region 1 lies below it and the library image (code) above it
    rows = [(int(p[0], 16), int(p[2])) for p in (ln.split() for ln in open(labs[0], "rb"))
            if len(p) >= 3 and p[0].startswith(b"0x48")]
    data = (min(r[0] for r in rows) - 0x48400000, max(r[0] + r[1] for r in rows) - 0x48400000)
    return refs, blobs, data


def main(argv):
    cache = {}
    for k in range(0, len(argv), 3):
        b, lo, hi = argv[k], int(argv[k + 1], 16), int(argv[k + 2], 16)
        if b not in cache:
            cache[b] = load(b)
        refs, blobs, data_lo = cache[b]
        keys = [r[0] for r in refs]
        i, j = bisect.bisect_left(keys, lo), bisect.bisect_left(keys, hi)
        print(f"== build {b}: span 0x{lo:08X}..0x{hi:08X} (0x{hi - lo:X} bytes)")
        below = refs[i - 1] if i else None
        above = refs[j] if j < len(refs) else None
        if below:
            print(f"   nearest below: 0x{below[0]:08X}  {below[1]}:{below[2]}  {below[3].strip().decode('latin-1')}")
        print(f"   source references inside: {j - i}")
        for r in refs[i:j][:40]:
            print(f"     0x{r[0]:08X}  {r[1]}:{r[2]}  {r[3].strip().decode('latin-1')}")
        if above:
            print(f"   nearest above: 0x{above[0]:08X}  {above[1]}:{above[2]}  {above[3].strip().decode('latin-1')}")
        hits = []
        for ri, blob in enumerate(blobs):
            for al in range(4):
                arr = array.array("I", blob[al:al + (len(blob) - al) // 4 * 4])
                for k, v in enumerate(arr):
                    if lo <= v < hi or lo <= v - 0x40000000 < hi:
                        hits.append((ri, al + 4 * k, v))
        print(f"   LE words in the ROM images with a value in the span (any alignment, either alias): {len(hits)}")
        # candidates: 4-aligned words in the program's data region, in the SP7001 plug-in
        # (table ROM 0x3E8000..) or in BASEEXT.XAP
        al = [h for h in hits if h[1] % 4 == 0 and (
              (h[0] == 0 and data_lo[0] <= h[1] < data_lo[1]) or
              (h[0] == 1 and h[1] >= 0x3E8000) or h[0] == 2)]
        print(f"   ... of which 4-aligned in the program's data region (0x{data_lo[0]:X}..0x{data_lo[1]:X}),"
              f" the plug-in (table ROM 0x3E8000..) or BASEEXT.XAP: {len(al)}")
        for ri, off, v in sorted(al)[:20]:
            print(f"     {TREES[b][3][ri]} +0x{off:06X} = 0x{v:08X}")


if __name__ == "__main__":
    main(sys.argv[1:])
