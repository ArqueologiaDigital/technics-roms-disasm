#!/usr/bin/env python3
"""Does model/to_llvm.py translate asm900's fims() (a float constant as a 32-bit immediate) to the ROM's bytes?

QUESTION ANSWERED / WHY: V4.23 writes a float constant moved into a register as `ld XWA,fims(3.0)`; to_llvm did not
know fims() (HANDOFF-2026-11-18.md: it blocked building DSP_BiquadWarp_FP and DSP_FilterLUT_Fetch once they match;
only lane_sub's checker sub_v423.py knew it).  to_llvm.translate_line now rewrites fims(x) to the IEEE-754 single
bits.  This feeds a few such lines through translate_line, assembles each with llvm-mc (model/check_bytes.assemble)
and compares with the expected bytes of the 5-byte `ld xrr, imm32` form, 40+r then the four bytes little-endian (the
ROM's `ld xwa,0x40400000` = 40 00 00 40 40).  Exit 1 on any difference.

    python3 -B notes/cc900-c-subcpu-2026-11-16/fims_check.py      (repository root)
"""
import os, struct, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'model'))
import to_llvm                                               # noqa: E402
import check_bytes                                           # noqa: E402

REG = {'XWA': 0, 'XBC': 1, 'XDE': 2, 'XHL': 3}
CASES = [('XWA', '3.0'), ('XWA', '1'), ('XBC', '0.5'), ('XDE', '-12.0'), ('XHL', '1.5e3'), ('XWA', '0'),
         ('XWA', '0.0')]
# fims(0): the short form `ld xwa, 0:i3` = e8+r a8 (the ROM's DSP_BiquadCoeff_Compute zero tap; helper AU, 2026-11-21)


def main():
    bad = 0
    for r, v in CASES:
        line = '\tld %s,fims(%s)' % (r, v)
        text = to_llvm.translate_line(line, {}, set())
        bits = struct.unpack('<I', struct.pack('<f', float(v)))[0]
        want = bytes([0xe8 + REG[r], 0xa8]) if bits == 0 else bytes([0x40 + REG[r]]) + struct.pack('<I', bits)
        got = check_bytes.assemble('\t.text\n\t.globl t\nt:\n%s\n' % text)['t'] if 'fims' not in text else None
        ok = got == want
        bad += not ok
        print('%-4s %-22s %-24s %s' % ('ok' if ok else 'BAD', line.strip(), text.strip(),
                                       got.hex(' ') if got is not None else 'untranslated'))
    print('%d of %d forms translate to the expected bytes' % (len(CASES) - bad, len(CASES)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
