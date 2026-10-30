#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""hash_chains.py -- check a multiplicative hash table of a sibling's program image.

QUESTION IT ANSWERS
  "Is the {u16 mult, u16 nbuckets} at DESC, followed by nbuckets bucket pointers, a hash table
   whose chains {u32 next, key, payload} hold every key in bucket key * mult % nbuckets, and are
   its entries back to back with one size?"  (KN6000: ToneKeyHash 0x4C3E8680 key 4 bytes,
   ShortKeyHash 0x4C3E9850 key 2, BankKeyHash 0x4C3EC6A0 key 4; gen_data_s.py hash_tables().)
   Prints mult, nbuckets, entry count, first / last entry, the entry spacing and the number of
   keys in the wrong bucket (0 = the table checks).

RUN (from the repository root, after `make -C kn6000 baserom`):
  python3 kn6000/notes/siblings-data-final-probes/hash_chains.py kn6000/baserom/kn6000_program.rom 0x4C000000 0x4C3E8680 4
"""
import collections
import struct
import sys


def main():
    rom = open(sys.argv[1], "rb").read()
    base, desc, kb = int(sys.argv[2], 0), int(sys.argv[3], 0), int(sys.argv[4])
    u32 = lambda a: struct.unpack_from("<I", rom, a - base)[0]  # noqa: E731
    u16 = lambda a: struct.unpack_from("<H", rom, a - base)[0]  # noqa: E731
    mult, nb = u16(desc), u16(desc + 2)
    ents, bad = [], 0
    for i in range(nb):
        p = u32(desc + 4 + 4 * i)
        while p:
            k = u32(p + 4) if kb == 4 else u16(p + 4)
            bad += (k * mult) % nb != i
            ents.append(p)
            p = u32(p)
    ents.sort()
    gaps = collections.Counter(b - a for a, b in zip(ents, ents[1:]))
    print(f"mult {mult}, nbuckets {nb}, entries {len(ents)}, 0x{ents[0]:08X}..0x{ents[-1]:08X}, "
          f"spacing {gaps.most_common(3)}, keys in the wrong bucket {bad}")


if __name__ == "__main__":
    main()
