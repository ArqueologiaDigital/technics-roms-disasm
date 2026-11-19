#!/usr/bin/env python3
"""Does model/to_llvm.py translate a byte register of the extended set (QC, QIZL ...) as the SECOND operand of an ALU
instruction, to the bytes the ROM has?

QUESTION ANSWERED / WHY: V4.23 writes `cp L,QC` in Voice_Build_SoundingVoiceList (helper AP, run
2026-11-19-11-sub-r23h-helpers, listing sub_AM_23a.asm); to_llvm left such lines `untranslated`, so the function could
not be checked or built (the translator gap of HANDOFF-2026-11-18.md, "a byte register such as QE / IXL as a second
operand").  to_llvm now writes `cpb_erp r, bank` (and addb_erp / subb_erp / andb_erp / orb_erp).  This script feeds
to_llvm.translate_line one line per form, assembles each with llvm-mc (model/check_bytes.assemble) and compares with
the expected bytes: c7 <bank code> <sub-opcode + r>, the encoding of the ROM's own `cpb_erp A, 0xFA` (c7 fa f1 in
Voice_Poly_NoteOn, cp A,QIZL).  Exit 1 on any difference.

    python3 -B notes/cc900-c-subcpu-2026-11-16/erp_operand_check.py      (repository root)
"""
import os, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'model'))
import to_llvm                                               # noqa: E402
import check_bytes                                           # noqa: E402

R = {'W': 0, 'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'H': 6, 'L': 7}
SUB = {'add': 0x80, 'sub': 0xa0, 'and': 0xc0, 'or': 0xe0, 'cp': 0xf0}
CASES = [('cp', 'L', 'QC'), ('cp', 'A', 'QIZL'), ('cp', 'A', 'QE'), ('add', 'A', 'IXL'), ('sub', 'C', 'QIZH'),
         ('and', 'E', 'QA'), ('or', 'B', 'IYH')]


def main():
    bad = 0
    for op, r, q in CASES:
        line = '\t%s %s,%s' % (op, r, q)
        text = to_llvm.translate_line(line, {}, set())
        want = bytes([0xc7, to_llvm.ERP_BYTE[q], SUB[op] + R[r]])
        if 'untranslated' in text:
            got = None
        else:
            got = check_bytes.assemble('\t.text\n\t.globl t\nt:\n%s\n' % text)['t']
        ok = got == want
        bad += not ok
        print('%-4s %-16s %-24s %s' % ('ok' if ok else 'BAD', line.strip(), text.strip(),
                                       got.hex(' ') if got is not None else 'untranslated'))
    print('%d of %d forms translate to the expected bytes' % (len(CASES) - bad, len(CASES)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
