#!/usr/bin/env python3
"""songtable_sysex_rx.py -- questions: (1) which messages does the "type 4" Technics SysEx handler
func_484C1B6F (941; called from func_484B9EF6 for descriptor type 4) take, and which sub-handler gets
each? (2) which M3 source does an incoming SysEx carry?

(1) Collects every descriptor the RX matcher func_484C01F1 (0x484C01F1..0x484C1B17) can return
    (`mov imm32, d0` = FC CC imm32 with a 0x486xxxxx operand), reads {u32 id, u16 type, u16 sub,
    u32 template} and prints the type-4 ones with their template and the sub-handler the compare
    ladder at 0x484C1B9B sends them to (SUB below, read from that ladder).
(2) Prints bytes +0x1D..+0x1F of the context template func_484BA15D_Table 0x48617514 (copied into the
    SysEx context 0x50151B90 and the SMF-import context 0x50081F84).  The source nibble of a SysEx
    result is added by func_484BFBEA from context +0x1F (bit 0 -> +0x30000000 = source 3, bit 1 ->
    +0x60000000 = source 6); func_484BA1D1 / func_484BA20F store 0x01 / 0x41 there.  func_484B9B2E
    (+0x1D: bit 0 -> source 2, bit 1 -> source 6) serves the per-channel contexts 0x50150AE4 /
    0x50150D04 (+0x1D := 1 by func_484B2F27 / func_484B2FEC), not SysEx.
Run from kn7000/:  python3 -I notes/mn10300-names-probes/songtable_sysex_rx.py
"""
import struct
B = 0x48400000
d = open("baserom/kn7000_program.rom", "rb").read()
SUB = {0: None, 1: None, 3: None, 4: None, 6: None, 7: None, 9: None, 0xA: None, 0xD: None,
       2: "func_484C1D13", 5: "func_484C1D17", 8: "func_484C1E0C", 0xB: "func_484C1E1A", 0xC: "func_484C1EDE",
       0xE: "func_484C1FAF", 0xF: "func_484C214D", 0x10: "func_484C22CD", 0x11: "func_484C24B1",
       0x12: "func_484C262D", 0x13: "func_484C27A9", 0x14: "func_484C295F", 0x15: "func_484C2B23",
       0x16: "func_484C2C9F", 0x17: "func_484C2E55"}
ptrs = []
for i in range(0x484C01F1 - B, 0x484C1B17 - B):
    if d[i] == 0xFC and d[i + 1] == 0xCC:
        v = struct.unpack_from("<I", d, i + 2)[0]
        if 0x48600000 <= v < 0x48700000 and v not in ptrs:
            ptrs.append(v)
rows = []
for p in ptrs:
    idv, typ, sub, tp = struct.unpack_from("<IHHI", d, p - B)
    tm = d[tp - B:tp - B + 48]
    rows.append((typ, sub, p, tm[:tm.index(0xF7) + 1] if 0xF7 in tm else tm))
print(f"{len(rows)} descriptors; per type:", {t: sum(1 for r in rows if r[0] == t) for t in sorted({r[0] for r in rows})})
for typ, sub, p, tm in sorted(r for r in rows if r[0] == 4):
    print(f"  sub 0x{sub:02X} desc 0x{p:08X} -> {SUB.get(sub) or 'ignored (returns -1)':22s} {tm.hex(' ')}")
t = d[0x48617514 - B:0x48617514 - B + 0x40]
print(f"context template 0x48617514: +0x1D {t[0x1D]:#04x} +0x1E {t[0x1E]:#04x} +0x1F {t[0x1F]:#04x}")
