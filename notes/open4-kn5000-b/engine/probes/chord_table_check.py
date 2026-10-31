#!/usr/bin/env python3
"""chord_table_check.py -- what do the fingered-chord recognition tables mean?

Question: ChordRecog_IntervalMaskTable (2048 x {u8, u8}) is indexed by the 11-bit interval mask that
Voice_ComputeNoteBitPosition builds (bit 11 - i set for a held note i semitones above the reference
note, bit 11 = the reference itself, dropped by `and hl, 0x7ff`).  Is entry byte +0 the chord TYPE
(1-based index into ChordTables_TypeIntervals) and byte +1 bits 0-6 the ROOT OFFSET in semitones above
the reference (NoteDisplay_FoundEntry: root = NoteToPitchClass[ref + offset])?

The check: for every non-zero entry, the chord type's interval set moved up by the root offset must be
the pitch-class set of the mask (exact), or a subset / superset of it (an incomplete or extended
fingering).  It also prints the 41 chord types with their intervals and a conventional name, and the
NoteMask9_ClassTable value histogram.

Run (from the repository root, reads the committed v10 dump):
    python3 notes/open4-kn5000-b/engine/probes/chord_table_check.py [--rom original_ROMs/kn5000_v10_program.rom]
        [--types] [--entries]
Addresses are v10/v9 (both trees link the tables at the same addresses; v7 links the type tables at
0xFE9B7A, `--chord-tables 0xfe9b7a`).
"""
import argparse
import collections

BASE = 0xE00000

# A conventional spelling of each interval set (semitones above the root).  The firmware has no
# name table for these: the names are the usual chord-symbol names of the interval sets.
NAMES = {
    (0, 4, 7): 'M', (0, 4, 7, 10): '7', (0, 4, 7, 11): 'M7', (0, 4, 8): 'aug', (0, 3, 7): 'm',
    (0, 3, 7, 10): 'm7', (0, 3, 6, 9): 'dim7', (0, 3, 6, 10): 'm7b5', (0, 3, 7, 11): 'mM7',
    (0, 5, 7, 10): '7sus4', (0, 4, 7, 9): '6', (0, 4, 8, 10): '7#5 (aug7)', (0, 4, 6): 'b5 (M-5)',
    (0, 4, 6, 10): '7b5', (0, 2, 4, 7, 10): '9', (0, 1, 4, 7, 10): '7b9',
    (0, 2, 4, 7, 11): 'M7(9)', (0, 2, 4, 7, 9): '6(9)', (0, 3, 7, 9): 'm6',
    (0, 3, 6): 'dim', (0, 2, 3, 7, 10): 'm7(9)', (0, 2, 3, 7, 9): 'm6(9)', (0, 5, 7): 'sus4',
    (0, 3, 4, 7, 10): '7#9', (0, 4, 6, 11): 'M7b5', (0, 4, 8, 11): 'M7#5', (0, 3, 6, 11): 'mM7b5',
    (0, 4, 9, 10): '7(13)', (0, 2, 4, 7): 'add9', (0, 2, 3, 7): 'madd9',
}


def pcset(xs):
    return tuple(sorted(set(x % 12 for x in xs)))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', default='original_ROMs/kn5000_v10_program.rom')
    ap.add_argument('--mask-table', type=lambda s: int(s, 0), default=0xEEAE44)
    ap.add_argument('--class-table', type=lambda s: int(s, 0), default=0xEEBE44)
    ap.add_argument('--chord-tables', type=lambda s: int(s, 0), default=0xFEA349)
    ap.add_argument('--types', action='store_true', help='print the chord-type table')
    ap.add_argument('--entries', action='store_true', help='print every non-zero mask entry')
    a = ap.parse_args()
    rom = open(a.rom, 'rb').read()

    def rd(addr, n):
        return rom[addr - BASE:addr - BASE + n]

    ct = a.chord_tables
    counts = rd(ct + 0x91, 41)
    ivs = rd(ct + 0xBA, 41 * 4)
    types = {}
    for t in range(1, 42):
        rec = ivs[(t - 1) * 4:(t - 1) * 4 + 4]
        n = counts[t - 1]
        types[t] = (n, tuple(rec[:n]), pcset((0,) + tuple(rec[:n])) if any(rec) or t == 1 else ())
    if a.types:
        print('type  notes  intervals      pc-set         name')
        for t, (n, rec, s) in types.items():
            print('%4d  %5d  %-13s  %-13s  %s' % (t, n, ','.join(map(str, rec)), ','.join(map(str, s)),
                                                   NAMES.get(s, '(all zero)' if not any(rec) else '?')))

    tab = rd(a.mask_table, 4096)
    tally = collections.Counter()
    flagged = collections.Counter()
    bad = []
    for idx in range(2048):
        t, b1 = tab[2 * idx], tab[2 * idx + 1]
        if t == 0:
            continue
        off, flag = b1 & 0x7F, b1 >> 7
        held = pcset([0] + [11 - k for k in range(11) if idx >> k & 1])
        if t not in types or not types[t][2]:
            tally['type out of range / empty'] += 1
            bad.append((idx, t, off))
            continue
        chord = pcset([off] + [off + x for x in types[t][2]])
        if chord == held:
            kind = 'exact'
        elif set(chord) < set(held):
            kind = 'chord is a subset of the held notes'
        elif set(held) < set(chord):
            kind = 'held notes are a subset of the chord'
        else:
            kind = 'MISMATCH'
            bad.append((idx, t, off))
        tally[kind] += 1
        flagged[(kind, flag)] += 1
        if a.entries:
            print('mask 0x%03x held %-22s -> type %2d %-14s root +%2d flag %d  %s' % (
                idx, ','.join(map(str, held)), t, NAMES.get(types[t][2], '?'), off, flag, kind))
    print('non-zero entries: %d' % sum(tally.values()))
    for k, v in tally.most_common():
        print('  %-40s %d' % (k, v))
    for (k, f), v in sorted(flagged.items()):
        print('  flag bit7=%d  %-38s %d' % (f, k, v))
    if bad:
        print('first unexplained entries:', ', '.join('0x%03x(t%d,+%d)' % b for b in bad[:12]))

    c9 = rd(a.class_table, 512)
    print('NoteMask9_ClassTable values:', dict(sorted(collections.Counter(c9).items())))


if __name__ == '__main__':
    main()
