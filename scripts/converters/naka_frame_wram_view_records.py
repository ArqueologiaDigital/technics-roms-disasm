#!/usr/bin/env python3
r"""naka_frame_wram_view_records.py -- give the 13 work-RAM view records of WorkRamInit_Image labels of their own.

QUESTION ANSWERED
-----------------
"Which bytes of the work-RAM image are the 13 Viewable elements whose records live in DRAM?"  Three Viewable
tables (slot 0xB5 CmpRealScreen, 0xB8 CmpNcpScreen, 0xB9 S2CScreen: the composer's real-time record, note copy
and sequencer-to-composer pages) register 13 elements at DRAM addresses 0x3D7B4..0x3D991.  Boot_InitWorkRAM
(boot/system_handlers.s) copies WorkRamInit_Image to DRAM 0x3D524 at reset, so each record's power-on bytes are
the image bytes at the same offset (scripts/analysis/naka_gui_model.py, work_ram_images).  The image held them as
anonymous 16-byte `.byte` rows.  This splits those rows at the 13 record addresses, under one label per record,
so that `naka_asm_records.py --apply` can write each as its NAKA_REC_<Class> macro call, and
naka_gui_symbolize.py names the elements of the three enums from the labels (OBJ_s0B5_e24 ->
OBJ_CmpRealScreen_AcCmpRecBox ...).

Each record's size is the class's allsize, read from the tree's own ROM (nakarest_objtab_map), and the script
refuses unless the records tile 0x3D7B4..0x3D992 exactly, the class id at each record start is the one expected,
and the rewritten rows hold the same bytes.

RUN (repository root, built tree)
    python3 scripts/converters/naka_frame_wram_view_records.py --tree v10 [--check]
    (then: naka_asm_records.py --tree <t> --gen, make, naka_asm_records.py --tree <t> --apply)
"""
import argparse
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'analysis'))
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'generators'))
import nakarest_objtab_map as O          # noqa: E402
import naka_gui_model as G               # noqa: E402

# (DRAM address, label, Viewable slot, element, class); names follow their siblings' <Screen>_<Class>[_n]
RECORDS = (
    (0x3D7B4, 'CmpRealScreen_AcCmpRecBox', 0xB5, 24, 'AcCmpRecBox'),
    (0x3D7DA, 'CmpRealScreen_AcCmpRecBox_2', 0xB5, 25, 'AcCmpRecBox'),
    (0x3D800, 'CmpRealScreen_AcCmpRecBox_3', 0xB5, 26, 'AcCmpRecBox'),
    (0x3D826, 'CmpRealScreen_AcCmpRecBox_4', 0xB5, 27, 'AcCmpRecBox'),
    (0x3D84C, 'CmpRealScreen_AcCmpRecBox_5', 0xB5, 28, 'AcCmpRecBox'),
    (0x3D872, 'CmpNcpScreen_PsCmpCpFPtnBox', 0xB8, 18, 'PsCmpCpFPtnBox'),
    (0x3D896, 'CmpNcpScreen_PsNameMemBox', 0xB8, 26, 'PsNameMemBox'),
    (0x3D8BA, 'CmpNcpScreen_AcMemNoBox', 0xB8, 27, 'AcMemNoBox'),
    (0x3D8DE, 'CmpNcpScreen_PsCmpCpFGrpBox', 0xB8, 30, 'PsCmpCpFGrpBox'),
    (0x3D902, 'CmpNcpScreen_PsCmpCpFVariBox', 0xB8, 31, 'PsCmpCpFVariBox'),
    (0x3D926, 'S2CScreen_PsS2cTransBox', 0xB9, 24, 'PsS2cTransBox'),
    (0x3D94A, 'S2CScreen_PsS2cFmeasBox', 0xB9, 28, 'PsS2cFmeasBox'),
    (0x3D96E, 'S2CScreen_PsS2cLmeasBox', 0xB9, 31, 'PsS2cLmeasBox'),
)
START, END = 0x3D7B4, 0x3D992
ROW = re.compile(r'^\t\.byte ([^;]*?)\s*; RAM 0x([0-9A-Fa-f]+)\s*$')


def read(p):
    return open(p, 'rb').read().decode('latin-1')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', default='v10')
    ap.add_argument('--check', action='store_true', help='report only')
    a = ap.parse_args()
    m = O.Map(a.tree)
    # the records must tile the range, with the classes the view tables say
    at = START
    for ram, lab, slot, k, cls in RECORDS:
        if ram != at:
            sys.exit('%s: %s at 0x%X, expected 0x%X' % (a.tree, lab, ram, at))
        if m.entries(m.by_slot[slot])[k] != ram:
            sys.exit('%s: slot 0x%X element %d is not 0x%X' % (a.tree, slot, k, ram))
        rom = G.rom_image_of(ram, a.tree)
        c = m.record_class(rom)
        if not c or c['name'] != cls:
            sys.exit('%s: 0x%X (ROM 0x%X) is not a %s record' % (a.tree, ram, rom, cls))
        at += c['allsize']
    if at != END:
        sys.exit('%s: the records end at 0x%X, not 0x%X' % (a.tree, at, END))
    p = [x for x in glob.glob(os.path.join(ROOT, a.tree, 'maincpu', '**', '*.s'), recursive=True)
         if re.search(r'^WorkRamInit_Image:', read(x), re.M)][0]
    L = read(p).split('\n')
    if any(re.match(r'^%s:' % RECORDS[0][1], l) for l in L):
        print('%s: already framed' % a.tree)
        return
    first = [i for i, l in enumerate(L) if ROW.match(l) and int(ROW.match(l).group(2), 16) == START]
    if len(first) != 1:
        sys.exit('%s: no single row starts at RAM 0x%X' % (a.tree, START))
    i = j = first[0]
    data, ram = [], START
    while ram < END:
        mm = ROW.match(L[j])
        if not mm or int(mm.group(2), 16) != ram:
            sys.exit('%s: line %d is not the row of RAM 0x%X' % (a.tree, j + 1, ram))
        vals = [int(v, 0) for v in mm.group(1).split(',')]
        data += vals
        ram += len(vals)
        j += 1
    if ram != END:
        sys.exit('%s: the rows end at 0x%X, not 0x%X' % (a.tree, ram, END))
    rom0 = G.rom_image_of(START, a.tree) - 0xE00000
    if bytes(data) != m.rom[rom0:rom0 + END - START]:
        sys.exit('%s: the rows do not hold the ROM bytes' % a.tree)
    new = []
    for n, (ram, lab, slot, k, cls) in enumerate(RECORDS):
        nxt = RECORDS[n + 1][0] if n + 1 < len(RECORDS) else END
        new.append('%s:' % lab)
        new.append('; RAM 0x%X: Viewable slot 0x%X element %d, class %s, a record that lives in DRAM (its view-table entry '
                   'is the DRAM address)' % (ram, slot, k, cls))
        rec = data[ram - START:nxt - START]
        for o in range(0, len(rec), 16):
            new.append('\t.byte ' + ', '.join('0x%02x' % v for v in rec[o:o + 16]))
    if a.check:
        print('%s: %s lines %d-%d would become %d lines' % (a.tree, os.path.relpath(p, ROOT), i + 1, j, len(new)))
        return
    L[i:j] = new
    open(p, 'wb').write('\n'.join(L).encode('latin-1'))
    print('%s: framed %d work-RAM view records in %s' % (a.tree, len(RECORDS), os.path.relpath(p, ROOT)))


if __name__ == '__main__':
    main()
