#!/usr/bin/env python3
"""Which drawing primitives does each widget class procedure call?  (kn5000-5dc)

For every `<Class>Proc:` label in a main-CPU tree, the routine is taken to run from that
label to the next `<Something>Proc:` label in the same file (the compiled procs are laid out
one after another, with their case labels and helpers in between).  Every
call / calr / jp / jrl target in that span is listed; targets that are drawing primitives
or base-class procs are kept:
  Draw*, ColorBlit*, MovePixels, Fill*, Vram*/VRAM_*, GetClient*, GetBoxCenter, CalcTotalWidth,
  GetCharHeight, SetChangeRect, UpdateScreen, ChangePalette, ChangeWall*, and *Proc.
The span rule over-collects for a proc followed by unrelated helpers before the next proc,
so read the source for the EVT_DRAW path itself; the README quotes it per class.

Usage:
  python3 notes/open4-kn5000-b/display/probes/widget_paint_calls.py [tree] [Proc ...]
  (tree defaults to v10; with no procs, every proc is listed)
"""
import glob
import re
import sys

PRIM = re.compile(r'^(Draw\w*|ColorBlit\w*|MovePixels|Fill\w*|Vram\w*|VRAM_\w*|GetClient\w*|GetBoxCenter|'
                  r'CalcTotalWidth|GetCharHeight|SetChangeRect|UpdateScreen|ChangePalette|ChangeWall\w*|\w+Proc)$')
CALL = re.compile(r'^\s*(call|calr|jp|jrl)\s+(?:t,\s*)?([A-Za-z_]\w*)\s*(;.*)?$')
PROC = re.compile(r'^([A-Za-z]\w*Proc):')


def scan(tree):
    out = {}
    for path in sorted(glob.glob(f'{tree}/maincpu/**/*.s', recursive=True)):
        cur = None
        for n, line in enumerate(open(path, 'rb').read().decode('latin-1').splitlines(), 1):
            m = PROC.match(line)
            if m:
                cur = m.group(1)
                out.setdefault(cur, (path, n, []))
                continue
            if cur:
                m = CALL.match(line)
                if m and PRIM.match(m.group(2)) and m.group(2) != cur:
                    lst = out[cur][2]
                    if m.group(2) not in lst:
                        lst.append(m.group(2))
    return out


def main():
    args = sys.argv[1:]
    tree = args.pop(0) if args and re.match(r'^v\d+$', args[0]) else 'v10'
    res = scan(tree)
    for proc in (args or sorted(res)):
        if proc not in res:
            print(f'{proc}: not found')
            continue
        path, n, calls = res[proc]
        print(f'{proc} ({path}:{n}): {", ".join(calls) or "-"}')


if __name__ == '__main__':
    main()
