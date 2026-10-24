#!/usr/bin/env python3
"""respell_drumparam_channel_bit_table.py -- type the 7-byte one-hot table read by DrumParam_LookupChannelBit.

QUESTION IT ANSWERS / JOB IT DOES
  The bytes after DrumParam_LookupChannelBit's `ret` were spelled as instructions (`normal / push sr / max /
  ld (P4:8), 32:io / .byte 0x40`).  Their only reader is `ld xix, <label> / ld a, (xix+a) / ld (0x37c9), a`
  with A = (0x39b8) (v10/v9 addresses; v7 reads (0x391c) and stores (0x372d)), so they are data;
  llvm-mc assembles the old lines to 01 02 04 08 10 20 40 (P4 = 0x10), the one-hot part bit for
  channel index 0..6.  This rewrites the five lines as one `.byte` line, with a
  version-neutral comment (no RAM addresses, which differ in v7), in every maincpu tree that holds them
  (v10, v9, v7).  Bytes do not change (make gate).

  Run it before or after scripts/renaming/rename_seq_headers_wave2.sed (it accepts either label name).

USAGE
  python3 scripts/tools/respell_drumparam_channel_bit_table.py          # rewrite in place
  python3 scripts/tools/respell_drumparam_channel_bit_table.py --check   # exit 1 if any tree is not respelled
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ['v10', 'v9', 'v7']
OLD = re.compile(rb'^((?:PatIdx_Lookup_Return|DrumParam_ChannelBitTable):)\n\tnormal\n\tpush\tsr\n\tmax\n'
                 rb'\tld\t\(P4:8\), 32:io\n\t\.byte 0x40\n', re.M)
NEW = (b'\\1\n'
       b'\t; One-hot part bit per easy-composer channel index 0..6; DrumParam_LookupChannelBit indexes it\n'
       b'\t; with the selected channel and stores the entry.  Was spelled as normal / push sr / max /\n'
       b'\t; ld (P4:8),32:io.\n'
       b'\t.byte 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40\n')


def main():
    check = '--check' in sys.argv
    pending = 0
    for t in TREES:
        p = os.path.join(ROOT, t, 'maincpu', 'sequencer', 'accompaniment_engine.s')
        b = open(p, 'rb').read()
        n = len(OLD.findall(b))
        pending += n
        if n and not check:
            open(p, 'wb').write(OLD.sub(NEW, b))
        print('%s: %d block(s) %s' % (t, n, 'pending' if check else 'respelled'))
    return 1 if (check and pending) else 0


if __name__ == '__main__':
    sys.exit(main())
