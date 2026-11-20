#!/usr/bin/env python3
"""Which hand-assembly text did the splice replace for LABEL?  (input of create_v140_subcpu_source.py's UNSPLICE)

QUESTION ANSWERED: after a promotion spliced LABEL (scripts/tools/cc900_splice.py: its hand assembly became one
`.include` line plus `.set` lines for its inner labels), what exact bytes of the file before the splice did that
block replace?  The v140 generator puts those bytes back for a function whose v1.40 body V4.23 does not reproduce
yet (scripts/generators/v140_subcpu_hand/LABEL.s).

OLD is the file before the splice (e.g. `git show HEAD:v141/subcpu/core/13_audio_process_dsp_and_effects.s >
OLD`), NEW the file after it.  The text before the spliced block and the text after it must be the same in both
files (one function per file and promotion); the script checks that and writes OLD's middle to OUT.

    python3 -B notes/cc900-c-subcpu-2026-11-16/hand_span_capture.py OLD NEW LABEL OUT      (repository root)
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'scripts', 'generators'))
import create_v140_subcpu_source as gen  # noqa: E402


def main():
    if len(sys.argv) != 5:
        sys.exit(__doc__)
    old = open(sys.argv[1], 'rb').read()
    new = open(sys.argv[2], 'rb').read()
    label = sys.argv[3].encode()
    ms = list(gen.spliced_block(label).finditer(new))
    if len(ms) != 1:
        sys.exit('%s: spliced block found %d times in NEW (want 1)' % (sys.argv[3], len(ms)))
    m = ms[0]
    prefix, suffix = new[:m.start()], new[m.end():]
    if not old.startswith(prefix) or not old.endswith(suffix) or len(prefix) + len(suffix) > len(old):
        sys.exit('%s: the text around the block differs between OLD and NEW' % sys.argv[3])
    hand = old[len(prefix):len(old) - len(suffix)]
    if not hand.startswith(label + b':'):
        sys.exit('%s: the replaced text does not start at the label' % sys.argv[3])
    open(sys.argv[4], 'wb').write(hand)
    print('%s: %d bytes of hand text (%d lines) -> %s' % (sys.argv[3], len(hand), hand.count(b'\n'), sys.argv[4]))


if __name__ == '__main__':
    main()
