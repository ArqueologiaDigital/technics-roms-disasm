#!/usr/bin/env python3
r"""gen_title_mode_index_equs.py -- TT_* / MD_* index constants for the code that opens a title or a
mode by number.

QUESTION ANSWERED
-----------------
"How should `ldw wa, 0x61` before `call UI_ChangeTitleByIndex` be spelled?"  The title routines
take the title's INDEX (TITLE_PS + A is the id they post) and UI_ChangeModeByIndex takes a mode
index (NAKA_MODE_MD_PS + A).  The firmware's own names for those indices are the strings RegTitle
and RegMode register ("TT_DKLD", "MD_DISK"), so for every `.equ TITLE_X, 0x1a0nnnn` this writes
`.equ TT_X, 0xnn` and for every `.equ NAKA_MODE_MD_X, 0x180nnnn` it writes `.equ MD_X, 0xnn`, in
a delimited block at the end of each main-CPU tree's shared/event_codes.s.

RUN (repository root)
    python3 scripts/generators/gen_title_mode_index_equs.py           # write v10 v9 v7 v6 v5
    python3 scripts/generators/gen_title_mode_index_equs.py --check   # exit 1 if a block is stale
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ['v10', 'v9', 'v7', 'v6', 'v5']
BEGIN = '; ---- BEGIN title / mode index constants (scripts/generators/gen_title_mode_index_equs.py) ----'
END = '; ---- END title / mode index constants ----'


def block(text):
    out = [BEGIN,
           '; TT_X = TITLE_X - TITLE_PS: the index UI_ChangeTitleByIndex / UI_InterruptTitleByIndex take',
           '; in A.  MD_X = NAKA_MODE_MD_X - NAKA_MODE_MD_PS: the index UI_ChangeModeByIndex takes.']
    seen = set()
    for m in re.finditer(r'^\.equ TITLE_(\w+), 0x1a0([0-9a-f]{4})\b', text, re.M):
        n = 'TT_' + m.group(1)
        if n not in seen:
            seen.add(n)
            out.append('.equ %s, 0x%x' % (n, int(m.group(2), 16)))
    for m in re.finditer(r'^\.equ NAKA_MODE_(MD_\w+), 0x180([0-9a-f]{4})\b', text, re.M):
        if m.group(1) not in seen:
            seen.add(m.group(1))
            out.append('.equ %s, 0x%x' % (m.group(1), int(m.group(2), 16)))
    out.append(END)
    return '\n'.join(out) + '\n'


def main():
    check = '--check' in sys.argv
    stale = 0
    for t in TREES:
        p = os.path.join(ROOT, t, 'maincpu', 'shared', 'event_codes.s')
        cur = open(p, 'rb').read().decode('latin-1')
        base = cur
        if BEGIN in cur:
            base = cur[:cur.index(BEGIN)] + cur[cur.index(END) + len(END) + 1:]
        new = base.rstrip('\n') + '\n\n' + block(base)
        if new != cur:
            if check:
                print('STALE: %s' % os.path.relpath(p, ROOT))
                stale += 1
            else:
                open(p, 'wb').write(new.encode('latin-1'))
                print('wrote %s' % os.path.relpath(p, ROOT))
    if check:
        print('gen_title_mode_index_equs: %s' % ('%d stale' % stale if stale else 'up to date'))
        sys.exit(1 if stale else 0)


if __name__ == '__main__':
    main()
