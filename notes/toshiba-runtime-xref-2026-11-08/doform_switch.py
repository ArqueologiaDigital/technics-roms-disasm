#!/usr/bin/env python3
"""How big is each build's __doprnt?  Its case table, compared across the firmware and the three runtime builds.

usage: python3 -I -B doform_switch.py > results/doform_switch.txt
__doprnt (member __doform_c) begins its f_const section with 22 little-endian 16-bit offsets into its own code:
the targets of its conversion-character switch.  Code added or removed before a case target moves that offset, so
the differences between two tables say where, and by how many bytes, the two builds of __doprnt differ.  The
firmware's table is main CPU v10's `Sprintf_TypeSwitch` (0xeed878), read from the linked ELF like xref_runtime.py;
the HD-AE5000's `__doprnt` has no exact or near match, so only the main CPU is read.  Prints the four tables and the
firmware's difference from each build.
"""
import os, sys, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ieee695, xref_runtime as X

N = 22
FW = ('maincpu v10', 0xeed878)

def lib_table(path):
    for m in ieee695.library(open(path, 'rb').read()):
        if m.name != '__doform_c': continue
        for i, s in (m.sections.items() if isinstance(m.sections, dict) else enumerate(m.sections)):
            if s.get('name') == 'f_const':
                c = m.code(i)
                return list(struct.unpack('<%dH' % N, bytes(x if isinstance(x, int) and 0 <= x < 256 else 0
                                                             for x in c[:2 * N])))
    return None

def fw_table():
    elf = [i for i in X.IMAGES if i[0] == FW[0]][0][2]
    for va, data in X.segments(elf):
        if va <= FW[1] < va + len(data):
            return list(struct.unpack('<%dH' % N, data[FW[1] - va:FW[1] - va + 2 * N]))

def main():
    libs = {'1997': X.V423 + '/C900ML.LIB', '2003': X.IDE + '/c900ml.lib', '2008': X.V110 + '/c900ml.lib'}
    fw = fw_table()
    print('%-8s %s' % ('firmware', ' '.join('%4d' % v for v in fw)))
    for y, p in libs.items():
        t = lib_table(p)
        if t is None: print('%-8s (no __doform_c f_const)' % y); continue
        print('%-8s %s' % (y, ' '.join('%4d' % v for v in t)))
        print('%-8s %s' % ('fw-' + y, ' '.join('%+4d' % (a - b) for a, b in zip(fw, t))))

main()
