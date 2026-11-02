#!/usr/bin/env python3
"""oldbuilds_ported_ram_check.py -- does every name ported 941 -> 893 / 935 sit on a routine
that touches the SAME RAM variables as 941's?  (Short routines: entry to first return within
0x60 bytes, the accessors the hazard below concerns.)

Question: tools/check_ported_names.py compares relocation-masked code, so a one-line
accessor (`mov (0x500062FC), d0; retf`) matches ANY accessor of the same shape.  Where
the build's RAM layout moved (893's SD SOUND cursors sit 8 bytes lower than 941's),
the offset map can align such byte-identical accessors with the wrong variable, and
the name then lands on the wrong routine with check-names still saying "same".
This probe decodes each ported routine in both images (entry to first return, as
port_names_by_code.signature does), collects the RAM addresses (0x50000000..0x50FFFFFF)
it names, maps 941's through the program offset map's RAM deltas
(port_symbols.ram_map, the map the port itself uses) and reports every name whose
build routine names a different set.  A reported row is a misplaced name, a routine
that really changed, or a RAM address the map cannot place (shown as `?`, never counted as a difference).

Measured 2026-11-02 at c240d1c0b, b893: 681 short ported routines that name RAM checked, 1
differs: SdAudSongIndexSet (941 stores 0x500062FC, 893's stores 0x500062F4).  Only the setter
shows: the RAM deltas come from the same mis-aligned runs, so the mislabelled getters look
consistent here; reading the setters' bounds settles the SD SOUND cursor block
(notes/older-program-builds.md).

Run (from kn7000/, read-only; the offset map is cached, about 10 minutes the first time):
    UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm \
        python3 -I notes/mn10300-names-probes/oldbuilds_ported_ram_check.py b893 [CACHE_DIR]
CACHE_DIR defaults to build/offset-maps (what `make symbols-893` writes).
"""
import os
import re
import sys

sys.path.insert(0, "tools")
import gen_image_s as GI          # noqa: E402
import offset_map as OM           # noqa: E402
import port_symbols as PS         # noqa: E402

UNIDASM = os.environ.get("UNIDASM", "/home/fsanches/compartilhado/mame-sony-video/unidasm")
BASE = 0x48400000
LIB = 0x4C000000
RETS = {"ret", "retf", "rets", "rti"}
BUILDS = {"b893": ("baserom/kn7000_program_b893.rom", [(0x80, 0x1846A0, BASE), (0x3B76B1, 0x3F55CF, LIB - 0x3B76B1)]),
          "b935": ("baserom/kn7000_program_b935.rom", [(0x80, 0x18595C, BASE), (0x3B8F6D, 0x3F6E9D, LIB - 0x3B8F6D)])}
CODE941 = [(0x80, 0x186000, BASE), (0x3B8FD1, 0x3F6F01, LIB - 0x3B8FD1)]
RAMRE = re.compile(r"0x(50[0-9a-f]{6})\b")
LIMIT = 0x60      # short routines only (entry to first return within 0x60 bytes): the
                  # accessors whose code is byte-identical whatever variable they name


def image(rom, code):
    img = GI.Image.__new__(GI.Image)
    img.rom, img.base, img.code, img.unidasm = rom, BASE, sorted(code), UNIDASM
    img.d, img.ix = open(rom, "rb").read(), {}
    return img


def rams(img, cpu):
    off = img.off(cpu)
    if off is None:
        return None
    out = []
    for o, b, mnem, ops in img.decode(off, min(img.code_end(off), off + LIMIT)):
        out += [int(x, 16) for x in RAMRE.findall(ops)]
        if mnem in RETS:
            return out
    return None


def rows(path):
    d = {}
    for line in open(path):
        m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)", line)
        if m:
            d[m.group(2)] = int(m.group(1), 16)
    return d


def main():
    key = sys.argv[1] if len(sys.argv) > 1 else "b893"
    cache = sys.argv[2] if len(sys.argv) > 2 else "build/offset-maps"
    rom, code = BUILDS[key]
    A = open("baserom/kn7000_program.rom", "rb").read()
    B = open(rom, "rb").read()
    pmap = OM.cached(A, B, cache)
    ram = PS.ram_map(pmap, OM._trim(A), OM._trim(B))
    a_names, b_names = {}, {}
    for p in ("kn7000.sym", "kn7000_manual.sym", "kn7000_exports_from_942.sym"):
        a_names.update(rows(p))
    for p in (f"kn7000_{key}.sym", f"kn7000_{key}_manual.sym", f"kn7000_{key}_exports.sym",
              f"kn7000_{key}_bycode.sym"):
        b_names.update(rows(p))
    ia, ib = image("baserom/kn7000_program.rom", CODE941), image(rom, code)
    checked = bad = 0
    for name in sorted(b_names, key=lambda n: b_names[n]):
        if name not in a_names or name.endswith("_entry"):
            continue
        ca, cb = a_names[name], b_names[name]
        if not (BASE <= ca < BASE + 0x186000 or LIB <= ca < LIB + 0x40000):
            continue
        ra, rb = rams(ia, ca), rams(ib, cb)
        if ra is None or rb is None or not ra:
            continue
        checked += 1
        mapped = [v + ram[v] if v in ram else None for v in ra]
        if len(ra) != len(rb) or any(m is not None and m != v for m, v in zip(mapped, rb)):
            bad += 1
            print(f"{name:30s} 941 {ca:#010x} " + ",".join(f"{v:#x}" for v in ra)
                  + "  expected " + ",".join("?" if m is None else f"{m:#x}" for m in mapped)
                  + f"  {key} {cb:#010x} has " + ",".join(f"{v:#x}" for v in rb))
    print(f"{checked} ported routines that name RAM checked; {bad} differ")


main()
