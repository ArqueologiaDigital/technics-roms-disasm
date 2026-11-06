#!/usr/bin/env python3
"""bass_name_tables.py TREE -- what the 64 work-RAM pointers after Naka_DrawbarReg_Table (the C's
ChordName_TypeRootTables) and the four 13-entry blocks they point at hold, read from TREE's ROM.

The reader is MainChordPre_AppendChordSuffix (kn5000_TREE_program.s): after the root name, the
chord-type name and "on" / blank it does
    lda xbc, (RAMPTRS:24); ld xbc, (xbc + 4*DISPLAY_CHORD_TYPE)
    ld xbc, (xbc + 4*DISPLAY_CHORD_ROOT); ld xbc, (xbc + 4*DISPLAY_CHORD_BASS); Strcat
so RAMPTRS[type] -> a 13-entry block [root] -> a 16-entry note-name table [bass] -> the bass name.
The RAM address is the operand of that `lda` (read from the source); the bytes are the work-RAM
image's (Boot_InitWorkRAM copies ROM WorkRamInit_Image.. to RAM 0x3D524..).  Prints, per tree: the
table's RAM address, which entry of Naka_DrawbarReg_Table each pointer names, and each block's entries
by the note-name table's label and its 13 names.
Needs: original_ROMs/kn5000_TREE_program.rom and symbols/maincpu_TREE_symbols_reference.txt.
RUN  python3 notes/v6v5-port2-2026-11-06/probes/bass_name_tables.py v6
"""
import re
import sys

tree = sys.argv[1]
rom = open('original_ROMs/kn5000_%s_program.rom' % tree, 'rb').read()
syms, inv = {}, {}
for ln in open('symbols/maincpu_%s_symbols_reference.txt' % tree):
    p = ln.split()
    if len(p) == 2 and not ln.startswith('#'):
        syms[p[0]] = int(p[1], 16)
        inv.setdefault(int(p[1], 16), p[0])
src = open('%s/maincpu/kn5000_%s_program.s' % (tree, tree), 'rb').read().decode('latin-1')
m = re.search(r'^MainChordPre_AppendChordSuffix:\n(?:.*\n){1,8}?\s*lda\s+xbc,\s*\((0x[0-9a-fA-F]+|\d+):24\)', src, re.M)
ramptrs = int(m.group(1), 0)
img, dest = syms['WorkRamInit_Image'], 0x3D524


def u32(a):
    o = a - 0xE00000
    return int.from_bytes(rom[o:o + 4], 'little')


def ram(a):          # a RAM address of the first image -> its ROM byte
    return a - dest + img


def cstr(a):
    o = a - 0xE00000
    return rom[o:rom.index(b'\0', o)].decode('latin-1')


tab = syms['Naka_DrawbarReg_Table']
tab_ram = tab - img + dest
print('%s: Naka_DrawbarReg_Table ROM 0x%06x = RAM 0x%05x; the reader\'s pointer array RAM 0x%05x = table + 0x%x'
      % (tree, tab, tab_ram, ramptrs, ramptrs - tab_ram))
ptr = [u32(ram(ramptrs) + 4 * k) for k in range(64)]
ent = [(p - tab_ram) // 4 if (p - tab_ram) % 4 == 0 and 0 <= p - tab_ram < 69 * 4 else None for p in ptr]
print('pointer [chord type] -> table entry:', ' '.join('%d:%s' % (k, e) for k, e in enumerate(ent)))
for blk in sorted(set(ent)):
    if blk is None:
        continue
    users = [k for k, e in enumerate(ent) if e == blk]
    print('block at entry %d (chord types %s):' % (blk, ' '.join(map(str, users))))
    for root in range(13):
        t = u32(tab + 4 * (blk + root))
        names = [cstr(u32(t + 4 * b)) for b in range(1, 13)]
        print('  root %2d  %-32s %s' % (root, inv.get(t, '0x%06x' % t), ' '.join('%-4s' % n.strip() for n in names)))
