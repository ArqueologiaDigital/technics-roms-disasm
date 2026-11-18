#!/usr/bin/env python3
"""Checks of two translator / checker rules added by lane_p6 on 2026-11-18, without the VM or any Toshiba text.

usage: python3 -I -B test_to_llvm_qidx.py      (from anywhere; needs the pinned llvm-mc)

1. to_llvm.translate_line on an immediate operation on a byte or word in memory indexed by an upper word,
   `OP (Xrr+Qrr),#` (ld / cp / add / adc / sub / sbc / and / xor / or, b and w, and inc / dec): the line must
   assemble to the TLCS-900 bytes (TLCS900InstrInfo.td, "(base+idx16) on every source- and destination-memory
   operation": c3 / d3 07 base index 38..3f imm; f3 07 base index 00 / 02 imm; 60+n / 68+n for inc / dec).  The
   first case is Sprintf_FormatGGeneral's `orb (XDE+QIZ),0x30`, which llvm-mc refused before.  The forms written as
   `.byte` (no backend pseudo) were read back with MAME's unidasm on 2026-11-18: c3 07 ec f2 38 02 = add
   (XHL+QIX),0x02; d3 07 e8 fa 3d ff ff = xor (XDE+QIZ),0xffff; f3 07 e8 fa 02 01 00 = ld (XDE+QIZ),0x0001;
   d3 07 e4 fa 6a = decw 2,(XBC+QIZ).
2. asm_vs_rom.place_locals: a function assembled on its own must give an absolute operand naming its own label (a
   switch base, `lda xix, (L:24)`) the label's ROM address, as ParaLoadOpt_AudioFlagCheck needs.
Prints one line per case and exits 1 on any failure.
"""
import os, re, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import to_llvm                                               # noqa: E402
import check_bytes                                           # noqa: E402
import asm_vs_rom                                            # noqa: E402

LLVM_MC = os.path.join(check_bytes.LLVM_BIN, 'llvm-mc')

# (listing line, expected bytes)
QIDX_CASES = [
    ('\torb\t(XDE+QIZ),0x30', 'c3 07 e8 fa 3e 30'),
    ('\tandb\t(XWA+QIZ),0x7f', 'c3 07 e0 fa 3c 7f'),
    ('\tsubb\t(XBC+QIZ),0x1', 'c3 07 e4 fa 3a 01'),
    ('\taddb\t(XHL+QIX),0x2', 'c3 07 ec f2 38 02'),
    ('\tadcb\t(XHL+QIX),0x2', 'c3 07 ec f2 39 02'),
    ('\tsbcb\t(XHL+QIX),0x2', 'c3 07 ec f2 3b 02'),
    ('\txorb\t(XDE+QIZ),0x80', 'c3 07 e8 fa 3d 80'),
    ('\tcpb\t(XBC+QIZ),0x0', 'c3 07 e4 fa 3f 00'),
    ('\tldb\t(XBC+QIZ),0x20', 'f3 07 e4 fa 00 20'),
    ('\torw\t(XDE+QIZ),0x1234', 'd3 07 e8 fa 3e 34 12'),
    ('\tandw\t(XDE+QIZ),0xff00', 'd3 07 e8 fa 3c 00 ff'),
    ('\taddw\t(XDE+QIZ),0x10', 'd3 07 e8 fa 38 10 00'),
    ('\txorw\t(XDE+QIZ),0xffff', 'd3 07 e8 fa 3d ff ff'),
    ('\tcpw\t(XDE+QIZ),0x8', 'd3 07 e8 fa 3f 08 00'),
    ('\tldw\t(XDE+QIZ),0x1', 'f3 07 e8 fa 02 01 00'),
    ('\tinc\t0x1,(XBC+QIZ)', 'c3 07 e4 fa 61'),
    ('\tdecw\t0x2,(XBC+QIZ)', 'd3 07 e4 fa 6a'),
]


def encode(text):
    """llvm-mc -show-encoding of one source text -> the bytes of every instruction and .byte line, in order."""
    with tempfile.TemporaryDirectory() as d:
        s = os.path.join(d, 't.s')
        open(s, 'w').write('\t.text\n' + text + '\n')
        r = subprocess.run([LLVM_MC, '-triple=tlcs900', '-show-encoding', s], capture_output=True, text=True)
    if r.returncode:
        return 'llvm-mc: ' + r.stderr.strip().splitlines()[0]
    out = []
    for line in r.stdout.splitlines():
        m = re.search(r'encoding: \[([^\]]*)\]', line)
        if m:
            out += [x.strip()[2:] for x in m.group(1).split(',')]
        m = re.match(r'^\s*\.byte\s+(.*?)(\s*;.*)?$', line)
        if m:
            out += ['%02x' % (int(x, 0) & 0xff) for x in m.group(1).split(',')]
    return ' '.join(out)


def main():
    bad = 0
    for line, want in QIDX_CASES:
        t = to_llvm.translate_line(line, {}, set())
        got = encode(t)
        ok = got == want
        bad += not ok
        print('%-4s %-30s -> %-40s %s' % ('ok' if ok else 'FAIL', line.strip().replace('\t', ' '), t.strip(),
                                          '' if ok else '(got %s, want %s)' % (got, want)))
    # place_locals: L1 is 6 bytes into a function at 0xf768af, so `lda xix, (L1:24)` must carry 0xf768b5
    body = ['\tnop', '\tlda xix, (L1:24)', 'L1:', '\tret']
    fa = 0xf768af
    text = '\t.text\n\t.globl F\nF:\n.Lcc900_fn0:\n' + '\n'.join(asm_vs_rom.place_locals(body, fa)) + '\n'
    got = check_bytes.assemble(text)['F'].hex(' ')
    want = '00 f2 b5 68 f7 34 0e'                        # nop; lda xix,(0xf768b5:24) = f2 a24 34 (f2 .. 30+r); ret
    ok = got == want
    bad += not ok
    print('%-4s place_locals: lda xix,(L1:24) at 0x%x -> %s%s' % ('ok' if ok else 'FAIL', fa, got,
                                                                  '' if ok else ' (want %s)' % want))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
