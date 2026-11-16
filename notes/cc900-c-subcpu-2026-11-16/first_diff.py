#!/usr/bin/env python3
"""Where and how does one function's V4.23 code first differ from the ROM?

QUESTION ANSWERED: sub_v423.py reports "DIFF at +N"; this prints, for one function of one listing, the bytes of our
translation and of the ROM side by side around +N, and the ROM's own instructions there (MAME's unidasm reading of
the payload ROM).  Only bytes and the ROM's disassembly are printed, no line of the Toshiba listing.

usage: python3 -B notes/cc900-c-subcpu-2026-11-16/first_diff.py LISTING.asm FUNCTION [--cfile C ...] [--context N]
"""
import os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import sub_v423 as S                                          # noqa: E402
import check_bytes                                            # noqa: E402

UNIDASM = os.path.expanduser('~/compartilhado/tools/unidasm')


def main():
    a = sys.argv[1:]
    if len(a) < 2:
        sys.exit(__doc__)
    ctx = int(a[a.index('--context') + 1]) if '--context' in a else 16
    cfiles = [a[i + 1] for i, x in enumerate(a) if x == '--cfile']
    S.KEEP_BYTES = {}
    res = S.compare(a[0], 'v142/subcpu', cfiles)
    ref = check_bytes.load_reference(os.path.join(S.REPO, 'symbols', 'subcpu_symbols_reference.txt'))
    rom = open(os.path.join(S.REPO, 'original_ROMs', 'kn5000_subprogram_v142.rom'), 'rb').read()
    for fn, n, v in res:
        if fn != a[1]:
            continue
        print(fn, n, v)
        mine = S.KEEP_BYTES.get(fn)
        if mine is None or not v.startswith('DIFF'):
            return 0
        at = int(v.split('+')[1])
        off = S.rom_offset(ref[fn])
        lo, hi = max(0, at - ctx), at + ctx
        print('ours %s' % mine[lo:hi].hex(' '))
        print('rom  %s' % rom[off + lo:off + hi].hex(' '))
        tmp = os.path.join(os.environ.get('TMPDIR', '/home/fsanches/compartilhado/tmp'), 'first_diff.bin')
        open(tmp, 'wb').write(rom[off + lo:off + hi + 8])
        r = subprocess.run([UNIDASM, tmp, '-arch', 'tlcs900', '-basepc', hex(ref[fn] + lo)], capture_output=True,
                           text=True)
        print(r.stdout)
    return 0


if __name__ == '__main__':
    sys.exit(main())
