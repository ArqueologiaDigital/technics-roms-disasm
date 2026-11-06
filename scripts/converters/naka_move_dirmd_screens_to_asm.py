#!/usr/bin/env python3
r"""naka_move_dirmd_screens_to_asm.py -- give the 16 IvDirmdScreen records at the head of
gui_display_struct_data.c (and NakaWidget_seamplfo1's tail) to the asm, as NAKA_REC_ macro calls.

QUESTION ANSWERED
-----------------
"Why are the Viewable elements of slots 0x2F..0x3F untyped?" (register item N-2f640c1d).  The first
550 bytes of includes/gui_display_struct_data.c were framed as 16 34-byte "display parameter records"
(`gui_display_record_t display_records[16]`: screen_id, dram_addr, timer_interval, ...) plus a "17th
record header" (rec17_screen_id, rec17_dram_addr) -- 6 bytes early.  Read from offset 6 they are 16
IvDirmdScreen records (class 0x0160005A, naka_classes.h; 34 bytes: links, flag, rect 0,0 320x240,
colour, border, exit title, window RAM cell), the single elements of Viewable slots 0x30..0x3F
(NakaWidget_sefillpq1 .. NakaWidget_sewrtsnd, which kn5000_<tree>_program.s already labels at offset
6 + 34 k).  The 6 bytes before them (`a0 01 6c d5 03 00`) are the last 6 of NakaWidget_seamplfo1
(slot 0x2F, `exit` high word 0x01A0 and `window` 0x3D56C), whose first 28 bytes end
includes/gui_format_strings.s; the "17th header" is the last record's exit high word and window.

Every other IvDirmdScreen record of slots 0x20..0x2F is already a NAKA_REC_IvDirmdScreen call in
gui_format_strings.s, so these move to the asm too:
  * the C loses gui_display_record_t, display_records[16] and rec17_* (the blob starts 0x226 bytes
    later; its size 5161 -> 4611), and every `.incbin` of the blob after them moves by -0x226;
  * GUI_DisplayStructData (a label 6 bytes into NakaWidget_seamplfo1 that nothing references) goes;
  * seamplfo1's 6 tail bytes join its `.byte` rows at the end of gui_format_strings.s, and each of
    the 16 records becomes plain `.byte` rows of its own bytes under its label (the tree's reference
    ROM, at the address its ELF symbol has);
  * v7's C-divergence json entry for the blob (relocations only, all at offsets >= 1872) moves by -550;
then scripts/converters/naka_asm_records.py --apply writes each of the 17 records as one macro call
from the ROM bytes.  The image does not change (make gate).

RUN (repository root, built tree), per tree v10, v9, v7 (their C is the same file):
    python3 scripts/converters/naka_move_dirmd_screens_to_asm.py --tree v10
    make <tree's program ROM>
    python3 scripts/converters/naka_asm_records.py --tree v10 --apply
It refuses a tree it has already converted.
"""
import argparse
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.join(os.environ.get('HOME', ''), 'compartilhado', 'llvm-project', 'build', 'bin', 'llvm-nm')
SHIFT = 0x226                       # 6 + 16 * 34
NAMES = ['sefillpq1', 'sefilhpq1', 'sefill241', 'sefilh241', 'sefilbpf1', 'sefilbcf1', 'sefilfil2',
         'sefilenv1', 'sefilenv2', 'sefillfo1', 'sedigeff', 'sectr2', 'sectr3', 'secopy', 'sewrtmem',
         'sewrtsnd']
BIN = 'includes/generated/gui_display_struct_data.bin'


def rd(p):
    return open(p, 'rb').read().decode('latin-1')


def wr(p, t):
    open(p, 'wb').write(t.encode('latin-1'))


def sub1(pat, rep, text, what, flags=re.S):
    new, n = re.subn(pat, rep, text, count=1, flags=flags)
    if n != 1:
        sys.exit('naka_move_dirmd_screens_to_asm: pattern not found: ' + what)
    return new


def byte_rows(b, first_label=None):
    out = []
    for i in range(0, len(b), 16):
        row = ', '.join('0x%02x' % x for x in b[i:i + 16])
        out.append('\t.byte\t' + row)
    return out


def symbols(tree):
    elf = os.path.join(ROOT, 'rebuilt_ROMs', 'kn5000_%s_program.llvm.elf' % tree)
    out = subprocess.run([NM, '--defined-only', elf], capture_output=True, text=True, check=True).stdout
    return {f[2]: int(f[0], 16) for f in (l.split() for l in out.split('\n')) if len(f) == 3}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True, choices=['v10', 'v9', 'v7'])
    a = ap.parse_args()
    t = a.tree
    mc = os.path.join(ROOT, t, 'maincpu')
    c_p = os.path.join(mc, 'includes', 'gui_display_struct_data.c')
    s_p = os.path.join(mc, 'kn5000_%s_program.s' % t)
    f_p = os.path.join(mc, 'includes', 'gui_format_strings.s')
    rom = open(os.path.join(ROOT, 'original_ROMs', 'kn5000_%s_program.rom' % t), 'rb').read()
    ct, st, ft = rd(c_p), rd(s_p), rd(f_p)
    if 'gui_display_record_t' not in ct:
        sys.exit('naka_move_dirmd_screens_to_asm: %s already converted' % t)
    sym = symbols(t)
    base = sym['GUI_DisplayStructData']

    # 1. the C: no display records, no 17th header; the blob starts 0x226 bytes later
    ct = sub1(r'/\* -- Display parameter record \(34 bytes\) -+ \*/\n.*?"gui_display_record_t must be exactly 34 bytes"\);\n\n',
              '', ct, 'typedef')
    ct = sub1(r'    gui_display_record_t display_records\[16\];[^\n]*\n    uint16_t rec17_screen_id;[^\n]*\n'
              r'    uint32_t rec17_dram_addr;[^\n]*\n', '', ct, 'members')
    ct = sub1(r'    /\* --- 16 Display Parameter Records -+ \*/\n    \.display_records = \{\n.*?\n    \},\n\n'
              r'    /\* --- 17th Record Header -+ \*/\n    \.rec17_screen_id = 0x01A0,\n    \.rec17_dram_addr = 0x[0-9A-F]+,\n\n',
              '', ct, 'initializers')
    ct = sub1(r'sizeof\(gui_display_struct_data_t\) == 5161,\n    "gui_display_struct_data_t must be exactly 5161 bytes"',
              'sizeof(gui_display_struct_data_t) == 4611,\n    "gui_display_struct_data_t must be exactly 4611 bytes"',
              ct, 'size assert')
    ct = sub1(r' \* ROM address: 0xE0CFDE - 0xE0E406 \(5161 bytes\)\n \* Label: GUI_DisplayStructData\n',
              ' * ROM address: 0xE0D004 - 0xE0E406 (4611 bytes; v10 addresses)\n'
              ' * Label: Scoop_ViewableTable_020 (the first of the 8-byte Viewable parameter blocks)\n'
              ' *\n'
              ' * Until 2026-11-06 this blob began 0x226 bytes earlier, with 16 "display parameter records" and\n'
              ' * a "17th record header" framed 6 bytes early: they were the 16 IvDirmdScreen records of Viewable\n'
              ' * slots 0x30..0x3F and the tail of NakaWidget_seamplfo1, now NAKA_REC_IvDirmdScreen calls in\n'
              ' * kn5000_<tree>_program.s and includes/gui_format_strings.s\n'
              ' * (scripts/converters/naka_move_dirmd_screens_to_asm.py).\n', ct, 'header')
    ct = sub1(r' \*   - 16 display parameter records defining SE screen viewport properties\n'
              r' \*   - 17th record header with DRAM address for SE master screen table\n', '', ct, 'header list')

    # 2. the program file: the 16 records as plain rows, the later slices moved
    lines = st.split('\n')
    i0 = next(i for i, l in enumerate(lines) if l.startswith('GUI_DisplayStructData:\t.incbin'))
    assert lines[i0 - 2] == '; purpose not established.' and lines[i0 - 1].startswith('; tried: '), lines[i0 - 2:i0]
    new = []
    for k, n in enumerate(NAMES):
        lab = 'NakaWidget_' + n
        want = '%s:\t.incbin "%s", 0x%X, 0x22' % (lab, BIN, 6 + 34 * k)
        assert lines[i0 + 1 + k] .replace('\t\t', '\t') == want, (lines[i0 + 1 + k], want)
        a0 = sym[lab]
        assert a0 == base + 6 + 34 * k
        rows = byte_rows(rom[a0 - 0xE00000:a0 - 0xE00000 + 34])
        new += [lab + ':'] + rows
    lines[i0 - 2:i0 + 17] = new
    st = '\n'.join(lines)
    moved = [0]

    def shift(m):
        off = int(m.group(1), 16)
        assert off >= SHIFT, off
        moved[0] += 1
        return '"%s", 0x%X,' % (BIN, off - SHIFT)
    st = re.sub(r'"includes/generated/gui_display_struct_data\.bin", 0x([0-9A-Fa-f]+),', shift, st)

    # 3. seamplfo1's tail joins its rows
    tail = rom[base - 0xE00000:base - 0xE00000 + 6]
    assert tail[:2] == b'\xa0\x01', tail
    assert ft.rstrip('\n').split('\n')[-2].startswith('NakaWidget_seamplfo1:'), 'seamplfo1 is not last'
    ft = ft.rstrip('\n') + '\n' + byte_rows(tail)[0] + '\n'

    wr(c_p, ct)
    wr(s_p, st)
    wr(f_p, ft)

    # 4. v7's relocations of the blob
    if t == 'v7':
        jp = os.path.join(mc, 'includes', 'v7_c_divergence.json')
        jt = rd(jp)
        d = json.loads(jt)
        e = d['gui_display_struct_data.bin']
        assert e['raw'] == {} and e['size'] == 5161 and min(o for o, _ in e['reloc']) >= SHIFT
        m = re.search(r'"gui_display_struct_data\.bin":\s*\{.*?"size":\s*5161\s*\}', jt, re.S)
        old = m.group(0)
        body = re.sub(r'\[(\d+),(\s*)(-?\d+)\]', lambda q: '[%d,%s%s]' % (int(q.group(1)) - SHIFT, q.group(2), q.group(3)), old)
        body = re.sub(r'("size":\s*)5161', r'\g<1>4611', body)
        jt = jt.replace(old, body)
        d2 = json.loads(jt)
        assert d2['gui_display_struct_data.bin']['size'] == 4611
        assert [o + SHIFT for o, _ in d2['gui_display_struct_data.bin']['reloc']] == [o for o, _ in e['reloc']]
        wr(jp, jt)
    print('naka_move_dirmd_screens_to_asm %s: 16 records + seamplfo1 tail to the asm, %d blob .incbin offsets moved'
          % (t, moved[0]))


if __name__ == '__main__':
    main()
