#!/usr/bin/env python3
"""Which hand-assembly text did the splice replace for each LABEL?  (input of create_v140_subcpu_source.py's UNSPLICE)

QUESTION ANSWERED: after a promotion spliced LABELs (scripts/tools/cc900_splice.py: a function's hand assembly
became one `.include` line plus `.set` lines for its inner labels; a case table's `.short` lines one `.include`
line), what exact bytes of the file before the splice did each block replace?  The v140 generator puts those bytes
back for a function whose v1.40 body V4.23 does not reproduce yet (scripts/generators/v140_subcpu_hand/LABEL.s).

OLD is the file before the splice (e.g. `git show HEAD:v141/subcpu/subcpu_data_tables.s > OLD`), NEW the file
after it.  Every LABEL named must be spliced in NEW, and NEW must differ from OLD only in those blocks: the text
between and around the blocks is matched in OLD in order, and each block's hand text is what OLD has between them.

    python3 -B notes/cc900-c-subcpu-2026-11-16/hand_span_capture.py OLD NEW OUTDIR LABEL...      (repository root)
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'scripts', 'generators'))
import create_v140_subcpu_source as gen  # noqa: E402


def main():
    if len(sys.argv) < 5:
        sys.exit(__doc__)
    old = open(sys.argv[1], 'rb').read()
    new = open(sys.argv[2], 'rb').read()
    outdir, labels = sys.argv[3], sys.argv[4:]
    blocks = []
    for lab in labels:
        ms = list(gen.spliced_block(lab.encode()).finditer(new))
        if len(ms) != 1:
            sys.exit('%s: spliced block found %d times in NEW (want 1)' % (lab, len(ms)))
        blocks.append((ms[0].start(), ms[0].end(), lab))
    blocks.sort()
    segs = [new[:blocks[0][0]]] + [new[blocks[i][1]:blocks[i + 1][0]] for i in range(len(blocks) - 1)] \
        + [new[blocks[-1][1]:]]
    if not old.startswith(segs[0]) or not old.endswith(segs[-1]):
        sys.exit('the text before the first block or after the last differs between OLD and NEW')
    pos, end = len(segs[0]), len(old) - len(segs[-1])
    for i, (_, _, lab) in enumerate(blocks):
        if i + 1 < len(blocks):
            nxt = old.find(segs[i + 1], pos)
            if nxt < 0 or nxt + len(segs[i + 1]) > end:
                sys.exit('%s: the text after its block is not in OLD' % lab)
        else:
            nxt = end
        hand = old[pos:nxt]
        if not hand.startswith(lab.encode() + b':'):
            sys.exit('%s: the replaced text does not start at the label' % lab)
        out = os.path.join(outdir, lab + '.s')
        open(out, 'wb').write(hand)
        print('%s: %d bytes of hand text (%d lines) -> %s' % (lab, len(hand), hand.count(b'\n'), out))
        pos = nxt + (len(segs[i + 1]) if i + 1 < len(blocks) else 0)


if __name__ == '__main__':
    main()
