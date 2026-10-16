#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Recovers the names in the SP7001 firmware's (program build 942) PLUG-iN EXPORT
# TABLE: the services the firmware offers to the table-flash XAPR plug-in, looked
# up by name. Question it answers: "what does the firmware itself call the
# routines it exports to plug-ins?" -- authoritative names, like the MILK
# reflection names, for ~231 functions (the uITRON kernel services in the
# library, firmware APIs, and the forwarders new in 942).
#
# Layout (same shape as a MILK reflection table): a u32 code-pointer array, a
# NUL word, then a u32 name-pointer array into a block of NUL-terminated names.
# Pairing: name[k] names code[k+1] -- code[0] (= 0) and the last name are
# unpaired. That pairing is NOT assumed: before writing anything this tool
# checks it against the uITRON semantics of four interrupt services on the
# MN10300 (PSW bit 11 = IE): loc_cpu and dis_int must clear IE
# (`and 0xf7ff, psw`) and ena_int must set it (`or 0x0800, psw`); a pairing that
# fails aborts. (Set*/Reset*/Check* triples were also spot-checked by hand.)
#
# Entries whose target already carries a name in the given .sym files are
# written as comments (aliases), so existing names stay canonical.
#
# Usage:  sp7001_exports.py <program.rom> <out.sym> [existing.sym ...]
import os
import re
import struct
import subprocess
import sys

BASE = 0x48400000
LIB_CPU = 0x4C000000


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    rom, out = sys.argv[1], sys.argv[2]
    unidasm = os.environ.get("UNIDASM", "../mame-sony-video/unidasm")
    P = open(rom, "rb").read()
    u = lambda o: struct.unpack_from("<I", P, o)[0]

    # the name block holds 'loc_cpu' first; the name array points at it
    s = P.find(b"loc_cpu\x00unl_cpu\x00")
    if s < 0:
        sys.exit("sp7001_exports: no export name block ('loc_cpu') in this image")
    name_arr = P.find(struct.pack("<I", BASE + s))
    while name_arr % 4 and name_arr >= 0:              # the arrays are word-aligned
        name_arr = P.find(struct.pack("<I", BASE + s), name_arr + 1)
    names = []
    while True:
        p = u(name_arr + 4 * len(names)) - BASE
        if not (0 <= p < len(P)) or not re.fullmatch(rb"[\x20-\x7e]*", P[p:P.index(0, p)]):
            break
        names.append(P[p:P.index(0, p)].decode("latin1"))
    if u(name_arr - 4) != 0:
        sys.exit("sp7001_exports: no NUL word before the name array")
    code_arr = name_arr - 4 - 4 * len(names)
    pairs = [(names[k], u(code_arr + 4 * (k + 1))) for k in range(len(names) - 1)]
    pairs = [(n, f) for n, f in pairs if n and f]

    def body(cpu):
        if LIB_CPU <= cpu < LIB_CPU + 0x100000:
            off = cpu - LIB_CPU + lib_base
        else:
            off = cpu - BASE
        txt = subprocess.run([unidasm, rom, "-arch", "mn10300", "-basepc", hex(cpu), "-skip",
                              hex(off), "-count", "96"], capture_output=True, text=True).stdout
        lines = []
        for ln in txt.splitlines():
            lines.append(ln)
            if re.search(r"\s(ret|rets|retf)\s", ln):
                break
        return "\n".join(lines)

    # program-flash file offset of the library image (the boot copies it to
    # 0x4C000000); tools/port_symbols.py prints it for a ported build
    lib_base = int(os.environ.get("LIB_FILE_BASE", "0"), 0)
    if not lib_base:
        sys.exit("sp7001_exports: set LIB_FILE_BASE (program-flash file offset of the library image)")

    by = dict(pairs)
    checks = [("loc_cpu", "and     0xf7ff, psw", "or      0x0800, psw"),
              ("dis_int", "and     0xf7ff, psw", "or      0x0800, psw"),
              ("ena_int", "or      0x0800, psw", None)]
    for nm, must, mustnot in checks:
        b = body(by[nm])
        if must not in b or (mustnot and mustnot in b):
            sys.exit(f"sp7001_exports: pairing check FAILED for {nm} -> 0x{by[nm]:08X}")

    known = {}
    for p in sys.argv[3:]:
        for line in open(p):
            m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)", line)
            if m and not line.lstrip().startswith(";"):
                known.setdefault(int(m.group(1), 16), m.group(2))
    taken = set(known.values())
    L = ["; KN7000 SP7001 (program build 942) PLUG-iN EXPORT TABLE -- names the firmware itself",
         f"; gives the services it exports to the XAPR plug-in (tools/sp7001_exports.py). Code array",
         f"; 0x{BASE + code_arr:08X}, NUL, name array 0x{BASE + name_arr:08X}; name[k] names code[k+1]",
         "; (checked: loc_cpu/dis_int clear PSW.IE, ena_int sets it). Targets that already have a",
         "; name elsewhere are listed as comments (aliases).",
         ";"]
    act = ali = 0
    for nm, f in sorted(pairs, key=lambda p: p[1]):
        sp = "lib" if LIB_CPU <= f < LIB_CPU + 0x100000 else "program"
        if f in known:
            L.append(f"; 0x{f:08X}  {nm}\t; alias of {known[f]} ({sp})")
            ali += 1
        elif nm in taken:
            L.append(f"; 0x{f:08X}  {nm}\t; name already used elsewhere ({sp})")
            ali += 1
        else:
            L.append(f"0x{f:08X}  {nm}\t; exported to plug-ins ({sp})")
            taken.add(nm)
            act += 1
    open(out, "w").write("\n".join(L) + "\n")
    print(f"sp7001_exports: {len(pairs)} exports ({act} new names, {ali} aliases) -> {out}; "
          f"pairing verified (loc_cpu, dis_int, ena_int)")


if __name__ == "__main__":
    main()
