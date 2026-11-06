#!/usr/bin/env python3
"""names_reset_sp_check: does each KN7000 program build's INITIAL_SP (and BootStack) equal the
stack top its own reset code loads (L-mn10300-names-b935-initial-sp)?

Reads the one `mov imm32, aN ; mov aN, sp` of each reference image (tools/port_symbols.py
reset_sp), the INITIAL_SP .equ of the build's symbols.inc, the BootStack row of its manual
symbol file, and the value its `add <X>, a0` after `mulu` / `mov 0x42, d0` adds
(DspPresetRamRecords, func_48412C25's kind-1 case).  Expected (2026-11-06, after
`make symbols-935 symbols-893 symbols-sp7001`): every row OK; stack tops 0x50021CF8 / 0x50021D08 /
0x50021CCC / 0x50021CC8 (941 / 942 / 935 / 893), records 0x50021CF8 / 0x50021D08 / 0x50021CF8 /
0x50021CF4.  Before the fix 935's INITIAL_SP was 941's 0x50021CF8 and 893's was unported.

usage (from kn7000/):
  python3 -I notes/kn7000-names-probes/names_reset_sp_check.py
"""
import re
import struct
import sys

sys.path.insert(0, "tools")
import port_symbols  # noqa: E402

B = {"941": ("baserom/kn7000_program.rom", "src/symbols.inc", "kn7000_manual.sym"),
     "942": ("baserom/kn7000_program_sp7001.rom", "src/sp7001/symbols.inc", "kn7000_sp7001_manual.sym"),
     "935": ("baserom/kn7000_program_b935.rom", "src/b935/symbols.inc", "kn7000_b935_manual.sym"),
     "893": ("baserom/kn7000_program_b893.rom", "src/b893/symbols.inc", "kn7000_b893_manual.sym")}
bad = 0
for b, (rom, inc, man) in B.items():
    img = open(rom, "rb").read()
    sp = port_symbols.reset_sp(img)
    m = re.search(r"^\.equ INITIAL_SP, (0x[0-9A-Fa-f]+)", open(inc).read(), re.M)
    isp = int(m.group(1), 16) if m else None
    bs = next((int(ln.split()[0], 16) for ln in open(man) if re.match(r"0x\w+\s+BootStack\b", ln)), None)
    # `mov 0x42, d0 / nop / nop / mulu / mov dX, a0 / add imm32, a0`: fc d0 imm32 is add imm32, a0
    recs = sorted({struct.unpack_from("<I", img, mo.start() + 2)[0] for mo in re.finditer(rb"\xfc\xd0", img)
                   if 0x50021C00 <= struct.unpack_from("<I", img, mo.start() + 2)[0] < 0x50021E00})
    ok = isp == sp and bs == sp - 0x800
    bad += not ok
    print(f"{b}: reset loads 0x{sp:08X}; INITIAL_SP {('0x%08X' % isp) if isp else 'none'}; BootStack "
          f"{('0x%08X' % bs) if bs else 'unported'}; add-immediates near it {[hex(r) for r in recs]}  "
          f"{'OK' if ok else 'FAIL'}")
sys.exit(1 if bad else 0)
