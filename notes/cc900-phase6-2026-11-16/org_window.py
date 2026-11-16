#!/usr/bin/env python3
"""org_window.py TREE_DIR TOP.s FILE.s:LINE

Which source files lie between the failing `.org` FILE.s:LINE and the `.org` before it,
in the assembler's include order?  A splice that grew a function moves every byte after
it; the first `.org` that cannot go backwards names the window, and the culprits are the
files (and their spliced-in cc900 includes) inside that window.

Prints the include-ordered files of the window, each marked with `M` when git reports it
modified.  Reads every .s as bytes (the tree's .ascii lines hold non-UTF-8 bytes).
"""
import re
import subprocess
import sys
from pathlib import Path

INC = re.compile(rb'^\s*\.include\s+"([^"]+)"')
ORG = re.compile(rb'^\s*\.org\b')


def walk(root, rel, out):
    path = root / rel
    for no, line in enumerate(path.read_bytes().split(b'\n'), 1):
        m = INC.match(line)
        if m:
            inc = m.group(1).decode()
            if (root / inc).exists():
                out.append(('enter', inc, 0))
                walk(root, inc, out)
                out.append(('leave', inc, 0))
            else:
                out.append(('missing', inc, no))
        elif ORG.match(line):
            out.append(('org', rel, no))


def main():
    root, top, target = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
    tfile, tline = target.rsplit(':', 1)
    events = []
    walk(root, top, events)
    idx = next(i for i, e in enumerate(events) if e[0] == 'org' and e[1] == tfile and e[2] == int(tline))
    start = max((i for i, e in enumerate(events[:idx]) if e[0] == 'org'), default=0)
    mod = set(subprocess.run(['git', 'diff', '--name-only', 'HEAD', '--', str(root)],
                             capture_output=True, text=True).stdout.split())
    print('previous .org:', events[start][1:], ' failing .org:', events[idx][1:])
    seen = []
    for kind, rel, no in events[start:idx + 1]:
        if kind in ('enter', 'org') and rel not in seen:
            seen.append(rel)
    for rel in seen:
        full = str(root / rel)
        print(('M ' if full in mod else '  ') + rel)


if __name__ == '__main__':
    main()
