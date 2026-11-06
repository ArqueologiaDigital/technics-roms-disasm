#!/usr/bin/env python3
"""demo_title_column.py -- which titles can Demo_SelectEntry_DrawSecondary open?

QUESTION ANSWERED
  Demo_SelectEntry_DrawSecondary (demo/file_demo_proc.s) passes byte [2 * DEMO_CURRENT_SONG] of
  DemoSong_TitleCol to UI_ChangeTitleByIndex.  This reads the 23 title bytes of the demo order from the v10
  ROM (at the ELF's DemoSong_TitleCol) and prints them with their TITLE_ names (shared/event_codes.s): the
  set name_title_index_operands.py's COMPUTED_LOADS entry lists.
RUN (repository root, built v10 tree)
  python3 notes/kn5000-naka2-2026-11-06/probes/demo_title_column.py
"""
import os, re, subprocess
NM = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-nm')
out = subprocess.run([NM, '--defined-only', 'rebuilt_ROMs/kn5000_v10_program.llvm.elf'], capture_output=True,
                     text=True, check=True).stdout
sym = {f[2]: int(f[0], 16) for f in (l.split() for l in out.splitlines()) if len(f) == 3}
rom = open('original_ROMs/kn5000_v10_program.rom', 'rb').read()
a = sym['DemoSong_TitleCol'] - 0xE00000
names = {}
for ln in open('v10/maincpu/shared/event_codes.s', 'rb').read().decode('latin-1').split('\n'):
    m = re.match(r'^\.equ (TITLE_\w+), 0x1a0([0-9a-f]{4})\b', ln)
    if m:
        names.setdefault(int(m.group(2), 16), m.group(1))
col = [rom[a + 2 * k] for k in range(23)]
print('song : title byte')
for k, b in enumerate(col):
    print('%4d : 0x%02X %s' % (k, b, names.get(b, '?')))
print('distinct:', ', '.join('%s (0x%02X)' % (names.get(b, '?'), b) for b in sorted(set(col))))
