#!/usr/bin/env python3
"""chord_types_29_30.py -- chord types 29 and 30 voice like 12 and 28: what tells them apart?

QUESTION IT ANSWERS
  ChordTables_TypeIntervals (v10 0xFEA403, 4 bytes per type) has the same record for types 12 and 29
  (00 04 08 0A) and for 28 and 30 (00 04 09 0A) (notes-errors-2026-10-31 row 10).  This lists every entry of
  ChordRecog_IntervalMaskTable (v10 0xEEAE44, 2,048 x {type, root offset | 0x80 approx}) that gives one of the
  four types, as the held pitch classes relative to the chord's root, so the held sets show which chord each
  type stands for.  Measured 2026-11-02: type 12 only 0 4 8 10; type 29 sets with a 9th (0 2 4 8 10, ...);
  type 28 0 4 9 10 and supersets with 2 / 7; type 30 every set holds a flat 9th (0 1 4 9 10, ...).

RUN (repository root)
  python3 notes/misc2-2026-11-02/probes/chord_types_29_30.py [original_ROMs/kn5000_v10_program.rom]
"""
import collections
import sys

TABLE = 0xEEAE44 - 0xE00000      # ChordRecog_IntervalMaskTable (v10 / v9)


def main():
    rom = open(sys.argv[1] if len(sys.argv) > 1 else "original_ROMs/kn5000_v10_program.rom", "rb").read()
    held = collections.defaultdict(list)
    for m in range(2048):
        t, o = rom[TABLE + 2 * m], rom[TABLE + 2 * m + 1]
        if t in (12, 29, 28, 30):
            mask = m | 0x800                         # bit 11 = the reference note, dropped by `and hl, 0x7ff`
            notes = [i for i in range(12) if mask >> (11 - i) & 1]
            rel = sorted((n - (o & 0x7F)) % 12 for n in notes)
            held[t].append(" ".join(map(str, rel)) + (" (approx)" if o & 0x80 else ""))
    for t in (12, 29, 28, 30):
        print("type %d, %d entries: %s" % (t, len(held[t]), "; ".join(sorted(set(held[t])))))


if __name__ == "__main__":
    main()
