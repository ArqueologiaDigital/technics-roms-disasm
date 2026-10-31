#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""hash_payloads.py -- the value ranges of each payload byte of the KN6000's three sound hash tables.

QUESTION ANSWERED: "which payload bytes of ToneKeyHash / ShortKeyHash / BankKeyHash (KN6000 v7.1,
gen_data_s.py profile kn6000 `hash_tables`) carry values, and what range does each take?"  The
named fields (gen_data_s.py HASH_PAYLOADS) come from the routines that read the payload; this
probe shows that the bytes no routine reads are constant (so writing them as one `pad` value
loses nothing) and gives each read byte's range, e.g. that ShortKeyHash's +0 / +1 / +2 are a
MIDI bank MSB, LSB and program (all < 0x80) and ToneKeyHash's +0 a u16 index below the tone count.

RUN (from kn7000/):  python3 notes/mn10300-formats-probes/hash_payloads.py
"""
import collections
import os
import struct

HERE = os.path.dirname(os.path.abspath(__file__))
ROM = os.path.normpath(os.path.join(HERE, "..", "..", "..", "kn6000", "baserom", "kn6000_program.rom"))
BASE = 0x4C000000
TABLES = [("ToneKeyHash", 0x4C3E8680, 4, 12), ("ShortKeyHash", 0x4C3E9850, 2, 6), ("BankKeyHash", 0x4C3EC6A0, 4, 4)]


def main():
    rom = open(ROM, "rb").read()
    u16 = lambda a: struct.unpack_from("<H", rom, a - BASE)[0]  # noqa: E731
    u32 = lambda a: struct.unpack_from("<I", rom, a - BASE)[0]  # noqa: E731
    for name, da, kb, pb in TABLES:
        mult, nb = u16(da), u16(da + 2)
        ents = []
        for i in range(nb):
            p = u32(da + 4 + 4 * i)
            while p:
                ents.append(p)
                p = u32(p)
        print(f"== {name}: {len(ents)} entries, payload {pb} bytes at entry + {4 + kb}")
        for k in range(pb):
            c = collections.Counter(rom[p - BASE + 4 + kb + k] for p in ents)
            vals = sorted(c)
            print(f"  +{k:<2d} {len(c):4d} distinct, {vals[0]:#04x}..{vals[-1]:#04x}"
                  + (f"  (always {vals[0]:#04x})" if len(c) == 1 else ""))
        if name == "ToneKeyHash":
            t = [struct.unpack_from("<H", rom, p - BASE + 8)[0] for p in ents]
            print(f"  u16 +0: {min(t)}..{max(t)}, {len(set(t))} distinct")


if __name__ == "__main__":
    main()
