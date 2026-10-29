#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""Walk program 941's parameter-id trie (ResourceIdTrie, read by library func_4C01BB1A) and print,
for every record, where the parameter lives.

Question answered: which byte (block, offset, mask, shift) of the live panel record a parameter id
reads and writes.  GetM3Em_entry (lib 0x4C014948) looks the 24-bit id up; a record of type 0 is
handled by func_4C015602, which dispatches on the kind word at +6 and reads the byte through
func_4C01F153(block = rec+0x0C or the id's top byte, offset = rec+0x0D, mask = rec+0x0E), then
shifts right by rec+0x0F.  Blocks are pointers in the table at 0x4858D44C (func_4C021040).

The KN6000 v7.1 program (kn6000/baserom/kn6000_program.rom, mapped at 0x4C000000) has the same
design: its walker (0x4C02CA6A) names the root 0x4C1935DC, its func_4C021040 twin (0x4C031C94) the
block table 0x4C195520 (found by matching the KN7000 routines' bytes; this script's --model kn6000).

usage: m3em_param_map.py PROGRAM_ROM [--model kn7000|kn6000] [--blocks] [--table]
  --table prints one row per record of type 0: id, block, offset, mask, shift, min, max, kind.
"""
import struct, sys

MODELS = {'kn7000': (0x48400000, 0x4858B424, 0x4858D44C), 'kn6000': (0x4C000000, 0x4C1935DC, 0x4C195520)}

def main():
    rom = open(sys.argv[1], 'rb').read()
    model = sys.argv[sys.argv.index('--model') + 1] if '--model' in sys.argv else 'kn7000'
    BASE, TRIE, BLOCKS = MODELS[model]
    u32 = lambda a: struct.unpack_from('<I', rom, a - BASE)[0]
    u16 = lambda a: struct.unpack_from('<H', rom, a - BASE)[0]
    u8 = lambda a: rom[a - BASE]
    if '--blocks' in sys.argv:
        for i in range(0x69):
            print('block %02x %08x' % (i, u32(BLOCKS + 4 * i)))
        return
    recs = {}
    def walk(node, shift, prefix, count=16):
        for n in range(count):
            e = node + n * 8
            p = u32(e)
            if p == 0:
                continue
            if u8(e + 4) == 0:
                recs[p] = u32(p)
            elif shift > 0:
                walk(p, shift - 4, prefix | (n << shift), u8(e + 5))
    walk(TRIE, 20, 0)
    for p in sorted(recs, key=lambda p: recs[p]):
        rid = recs[p]
        typ, kind, w8, wa = u16(p + 4), u16(p + 6), u16(p + 8), u16(p + 10)
        b = rom[p - BASE + 12: p - BASE + 16]
        if '--table' in sys.argv:
            if typ == 0:
                print('%06x %02x %02x %02x %d %d %d %02x' % (rid, b[0], b[1], b[2], b[3], w8, wa, kind))
            continue
        print('%06x rec=%08x type=%d kind=%02x w8=%04x wa=%04x blk=%02x off=%02x mask=%02x sh=%d  %s' % (
            rid, p, typ, kind, w8, wa, b[0], b[1], b[2], b[3], rom[p - BASE + 16: p - BASE + 24].hex()))

main()
