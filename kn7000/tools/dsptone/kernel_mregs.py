#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>; GPL v3+
#
# kernel_mregs.py [--unidasm PATH] -- which modify registers does each program build's DSP kernel set, and which
# one do its effect programs step their outputs with? DSPTONE's first build used DM(I4, M2) as the 941 listings
# do (kn7000/dsp/kernel-architecture.md section 7: M2 = +1) and, on program 893, wrote its output pair three words
# apart: the 893 kernel sets M0 = +1, M1 = +2, M2 = +3 (MAME, 2026-10-20, test/run_mame.sh; the words MAME downloads
# are the chip's, pass 7). This finds, in each program image, the kernel record's PM block at 0x8D00 (block header
# 20 04 80 xx 00 00 8D 00, ../../dsp/README.md) and its copy stub's block at 0x8000, and prints the boot-init's
# first 14 instructions and the copy stub (PM 0x80FB-0x80FE: "R0 = DM(0x20, I4); DM(I4, Mx) = R0", twice) through
# unidasm -arch sharc.
#   python3 -I kernel_mregs.py
import os
import struct
import subprocess
import sys
import tempfile

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'cnv_romdump'))
import find_dsp as F  # noqa: E402

UNIDASM = os.path.expanduser('~/compartilhado/mame-sony-video/unidasm')


def block(img, target):
    """the payload of the first PM block for `target` (record format: ../../dsp/README.md)"""
    pat = bytes([0x20, 0x04, 0x80])
    o = 0
    while True:
        o = img.find(pat, o)
        if o < 0:
            return None
        a, t, c, n = struct.unpack_from('>HHHH', img, o + 4)
        if a == 0 and t == target and c == 0 and 0 < n < 0x2000 and n % 6 == 0:
            return o, img[o + 12:o + 12 + n]
        o += 1


def dis(payload, base, first, count):
    words = [struct.unpack_from('>3H', payload, 6 * k) for k in range(len(payload) // 6)]
    slots = b''.join(struct.pack('<Q', (w[0] << 32) | (w[1] << 16) | w[2]) for w in words)
    with tempfile.NamedTemporaryFile(suffix='.bin') as t:
        t.write(slots)
        t.flush()
        out = subprocess.run([UNIDASM, t.name, '-arch', 'sharc', '-basepc', hex(base)], capture_output=True,
                             text=True).stdout.splitlines()
    return [ln for ln in out if first <= int(ln.split(':')[0], 16) < first + count]


def main():
    global UNIDASM
    if '--unidasm' in sys.argv:
        UNIDASM = sys.argv[sys.argv.index('--unidasm') + 1]
    for k, img in F.images().items():
        b, b0 = block(img, 0x8D00), block(img, 0x8000)
        if not b or not b0:
            print(f'== {k}: the kernel blocks are not found')
            continue
        print(f'== {k}: PM 0x8D00 block at file offset {b[0]:#x}, PM 0x8000 block at {b0[0]:#x}')
        for ln in dis(b[1], 0x8D00, 0x8D00, 14) + dis(b0[1], 0x8000, 0x80FB, 4):
            print('   ' + ln)


if __name__ == '__main__':
    main()
