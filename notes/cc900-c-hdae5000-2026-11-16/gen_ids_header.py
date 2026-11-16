#!/usr/bin/env python3
"""Write C #defines for the HD-AE5000's UI object ids and event codes, so the C can name them as the tree does.

QUESTION ANSWERED / WHY: the hand source spells `ld xwa, HDAE5000_OBJ_CP_FD_LIST` / `ld xbc, EVT_DRAW`; the C should
say the same.  Event codes (`EVT_*`, `NAKA_*`, `TITLE_*`) are `.equ` lines of hdae5000/shared/event_codes.s; UI object
ids are computed by the `_ui_new` macro (hdae5000/shared/naka_ui_macros.s, 0x7f0000 + n), so they are read from the
built image's symbol table (llvm-nm of rebuilt_ROMs/hd-ae5000_v2_06i.llvm.elf; `make` builds it).

    python3 -B notes/cc900-c-hdae5000-2026-11-16/gen_ids_header.py ELF > OUT.h

Object ids are written OBJ_<name>, without the tree's HDAE5000_ prefix.  Names longer than 31 characters are left out (cc900 keeps 31; two long names could collide): the C writes those
values as numbers.
"""
import os, re, subprocess, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
NM = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-nm')
EQU = re.compile(r'^\s*\.equ\s+((?:EVT|NAKA|TITLE)_\w+),\s*(0x[0-9a-fA-F]+|\d+)\b')


def main():
    print('/* HD-AE5000 UI object ids and event codes (gen_ids_header.py) */')
    seen = set()
    for l in open(os.path.join(REPO, 'hdae5000', 'shared', 'event_codes.s'), encoding='latin-1'):
        m = EQU.match(l)
        if m and m.group(1) not in seen and len(m.group(1)) <= 31:
            seen.add(m.group(1))
            print('#define %s 0x%xL' % (m.group(1), int(m.group(2), 0)))
    out = subprocess.run([NM, sys.argv[1]], capture_output=True, text=True, check=True).stdout
    for l in sorted(out.splitlines(), key=lambda l: l.split()[-1]):
        f = l.split()
        if len(f) == 3 and f[1] == 'a' and f[2].startswith('HDAE5000_OBJ_') and len(f[2]) - 9 <= 31:
            print('#define %s 0x%xL' % (f[2][9:], int(f[0], 16)))     # OBJ_<name>: the HDAE5000_ prefix dropped


if __name__ == '__main__':
    main()
