#!/usr/bin/env python3
"""sysex_rx_ids.py -- question: which M3 parameter ids can an incoming SysEx set on the KN7000 (941)?
Collects every descriptor pointer the RX matcher 0x484C01F4..0x484C1B17 can return ('mov 0x4861xxxx, d0'
in disasm/program.asm) and prints each descriptor's id/type/subtype/template (layout as in sysex_desc.py)."""
import re, sys
sys.path.insert(0, '.')
from romread import *
D = "/home/fsanches/compartilhado/kn7000_disassembly/disasm/program.asm"
ptrs = []
for ln in open(D):
    m = re.match(r"^([0-9a-f]{8}): .*\bmov +0x(486[0-9a-f]{5}), d0", ln)
    if m and 0x484C01F4 <= int(m.group(1), 16) < 0x484C1B17:
        p = int(m.group(2), 16)
        if p not in ptrs: ptrs.append(p)
def tmpl(p):
    out = []
    for i in range(48):
        c = u8(p + i); out.append(c)
        if c == 0xF7: break
    return " ".join(f"{c:02X}" for c in out)
rows = []
for d in ptrs:
    rows.append((u32(d), u16(d+4), u16(d+6), d, tmpl(u32(d+8)) if 0x48400000 <= u32(d+8) < 0x48800000 else "?"))
print(f"{len(ptrs)} descriptors")
for i, t, s, d, tm in sorted(rows):
    print(f"  id {i:08X} type {t} sub {s:#04x} desc {d:08X}  {tm}")
