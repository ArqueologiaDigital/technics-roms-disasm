#!/usr/bin/env python3
"""pattern_transpose.py -- how does an IC14 pattern note become the played note for the chord?

Question (kn5000-3qp): a lane's pattern note is written for C; when the accompaniment writes it into
the part's ring buffer, AccVoice_CorrectNote (v10 0xF5xxxx, accompaniment_engine.s) converts it for the
recognized chord (RAM 0x32D7 flags, 0x32D8 type, 0x32D9 root, 0x32DA bass root, copied from the
recognizer by AccChord_ReadAndStoreKeys).  This probe re-implements that conversion from the
firmware's own tables, read from the committed v10 dump:

  Note_PitchClassTable            0xE46142  128 B   note -> pitch class 0..11
  Rhythm_VelLookA_TableLookup_Table 0xE461C2 21 x 16 signed semitone deltas, indexed [row][pitch class]
  Rhythm_InstrMapTable_Default    0xF550CA  3 x 49  chord type -> row: +0 default (parts 16, 32),
                                                    +0x31 (_D4) part 8 (ACCOMP1), +0x62 part 4 (BASS)
  Rhythm_PitchShiftTable_Default  0xF5526F  2 x 49  chord type -> 0 none / 1 use ext1 / 2 use ext2
                                                    (0x91 notes); +0x31 for part 4 (BASS)
  AccTuning_ReadAndApplyOffset_Table 0xE49FC8 48 B  chord type -> family 0 major, 1 minor, 2 seventh,
                                                    3 dim7 (the "same family" fast path)
  Tbl_ChordTypeNames              0xEFF5B9  64 x 5  the chord-type names the LCD shows (SNS_LoadKeyAndChord)
  ChordRecog_IntervalMaskTable    0xEEAE44  2048 x {type, root offset}: what each type is recognized from

and the code path (v10 labels, symbols/maincpu_v10_symbols_reference.txt):
  AccMidi_ParseCommon / _ParseNoteOn -> ACC_EVENT (+2 = note), 0x3433 / 0x3434 = the 0x91 ext bytes;
  Rhythm_CheckVelocityThreshold: a NOTE (not a velocity) >= 0x78 sets 0x32F4 bit 4 = left untransposed;
  Rhythm_CrossVoiceCorrect (part 4 only), Rhythm_NoteRangeCheck;
  Rhythm_VelocityLookup_A (status 0x90) / Rhythm_VoiceMapLookup (status 0x91);
  Rhythm_TransposeNote (root shift, turnover, ceiling, bass floor).

Modes:
  --example NOTE STATUS EXT1 EXT2 PART TYPE ROOT [--bass B] [--turnover T] [--ceiling C] [--flags F]
        one note, step by step (ROOT and B counted 1 = C .. 12 = B, as the firmware stores them)
  --census     every note of the committed IC14 source (rhythm_data/patterns/*.s), played for each chord
               type 1..41 with root C: share of played pitch classes that are tones of the recognized chord
  --tables     print the chord-type -> row / selector / family / name table

Run from the repository root:
    python3 notes/open6-kn5000-d/accomp/probes/pattern_transpose.py --tables
    python3 notes/open6-kn5000-d/accomp/probes/pattern_transpose.py --census
    python3 notes/open6-kn5000-d/accomp/probes/pattern_transpose.py --example 64 0x91 0 0x11 16 6 3
Reads only committed files.
"""
import argparse
import collections
import glob
import re

BASE = 0xE00000
NOTE_PC = 0xE46142
ROWS = 0xE461C2
INSTR_MAP = 0xF550CA
PITCH_SHIFT = 0xF5526F
FAMILY = 0xE49FC8
NAMES = 0xEFF5B9
MASK = 0xEEAE44
PARTS = {'Bass': 4, 'Acc1': 8, 'Acc2': 16, 'Acc3': 32}


def s8(x):
    return x - 256 if x > 127 else x


class Rom:
    def __init__(self, path):
        self.b = open(path, 'rb').read()

    def rd(self, addr, n):
        return self.b[addr - BASE:addr - BASE + n]

    def load(self):
        self.pc = list(self.rd(NOTE_PC, 128))
        r = self.rd(ROWS, 21 * 16)
        self.rows = [[s8(x) for x in r[16 * i:16 * i + 16]] for i in range(21)]
        m = self.rd(INSTR_MAP, 147)
        self.imap = {'default': m[0:49], 'd4': m[49:98], 'bass': m[98:147]}
        p = self.rd(PITCH_SHIFT, 98)
        self.pshift = {'default': p[0:49], 'bass': p[49:98]}
        self.family = list(self.rd(FAMILY, 48))
        n = self.rd(NAMES, 64 * 5)
        self.names = [n[5 * i:5 * i + 5].replace(b'\x88', b'b').replace(b'\x8c', b'#').decode('latin-1').strip()
                      for i in range(64)]
        return self


def correct_note(rom, note, status, ext1, ext2, part, ctype, root, bass=None, turnover=8, ceiling=127,
                 flags=0, chord_changed=False, intro_lanes=False, trace=None):
    """AccVoice_CorrectNote -> Rhythm_VelocityLookup_A / Rhythm_VoiceMapLookup -> Rhythm_TransposeNote."""
    if bass is None:
        bass = root                                   # AccChord_ReadAndStoreKeys: no on-bass bit -> bass = root
    t = trace if trace is not None else []
    bit3 = part == 4                                  # AccCh1_NoteOnEntry (BASS): 0x32F4 bit 3
    bit2 = part == 8                                  # AccCh2_NoteOnEntry (ACCOMP1): 0x32F4 bit 2
    bit4 = note >= 0x78                               # Rhythm_CheckVelocityThreshold (parts 4..32)
    a = note
    floor = None
    if not bit4:
        if bit3 and ((flags & 3) or (not intro_lanes and chord_changed)):   # Rhythm_CrossVoiceCorrect
            floor = (a + turnover + 1 - 12) & 0xFF
            a = a - rom.pc[a]
            ext1 = ext2 = 0
            t.append('CrossVoiceCorrect: bass to the C of its octave (%d), floor %d' % (a, floor))
        if flags & 1:                                 # Rhythm_NoteRangeCheck
            a = a - rom.pc[a]
            ext1 = ext2 = 0
            t.append('NoteRangeCheck (flags bit 0): to the C of its octave (%d)' % a)
    if ctype == 0:
        t.append('chord type 0: note 0')
        return 0
    if bit4:
        t.append('note >= 0x78: not transposed')
        return a
    L = ctype if ctype < 0x30 else 0
    if status == 0x91:                                # Rhythm_VoiceMapLookup
        sel = rom.pshift['bass' if bit3 else 'default'][L]
        if sel:
            h = ext1 if sel == 1 else ext2
            if h & 0x20:
                t.append('ext%d = 0x%02x: bit 5, note dropped (0)' % (sel, h))
                return 0
            d = -(h & 15) if h & 0x10 else (h & 15)
            a += d
            t.append('ext%d = 0x%02x: %+d -> %d' % (sel, h, d, a))
        else:
            t.append('selector 0: ext bytes not used')
    variant = 'bass' if bit3 else ('d4' if bit2 else 'default')
    row = rom.imap[variant][L]
    w = a + rom.rows[row][rom.pc[a & 0x7F]]
    t.append('row %d of the %s map, pitch class %d: %+d -> %d' % (row, variant, rom.pc[a & 0x7F],
                                                                  rom.rows[row][rom.pc[a & 0x7F]], w))
    # Rhythm_TransposeNote
    r = bass if bit3 else root
    if r == 0:
        t.append('root 0: note 0')
        return 0
    s = r - 1
    if s > turnover:
        s -= 12
    w = (w + s) & 0xFF
    if s >= 0 and w & 0x80:
        w = (w - 12) & 0xFF
    if s < 0 and w & 0x80:
        w = (w + 12) & 0xFF
    t.append('root shift %+d (turnover %d) -> %d' % (s, turnover, w))
    if ceiling >= 12:
        while w >= ceiling:
            w -= 12
    if floor is not None and w < floor:
        w += 12
        t.append('below the bass floor: +12 -> %d' % w)
    return w


def recognized_sets(rom):
    """Per chord type: union of the pitch-class sets (relative to the root) it is recognized from, entries
    with bit 7 of the offset byte clear (the exact / subset matches of engine/probes/chord_table_check.py)."""
    tab = rom.rd(MASK, 4096)
    sets = collections.defaultdict(set)
    approx = collections.defaultdict(set)
    for idx in range(2048):
        t, b1 = tab[2 * idx], tab[2 * idx + 1]
        if not t:
            continue
        off = b1 & 0x7F
        held = [0] + [11 - k for k in range(11) if idx >> k & 1]
        (approx if b1 & 0x80 else sets)[t].update((h - off) % 12 for h in held)
    for t in approx:                                  # types 11 (6) and 19 (m6) have only bit-7 entries
        if t not in sets:
            sets[t] = approx[t]
    return sets


def pattern_notes():
    part = None
    for f in sorted(glob.glob('rhythm_data/patterns/bank_*.s')):
        for line in open(f, 'rb'):
            m = re.match(rb'^Trk_\w+?_[NV]_(\w+)_S\d+:', line)
            if m:
                part = m.group(1).decode()
                continue
            m = re.match(rb'\s+(note2?)\s+(.*)', line)
            if m and part in PARTS:
                a = [int(x, 0) for x in m.group(2).split(b',')]
                yield part, (0x91 if m.group(1) == b'note2' else 0x90), a[1], (a[5] if len(a) > 5 else 0), \
                    (a[6] if len(a) > 6 else 0)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', default='original_ROMs/kn5000_v10_program.rom')
    ap.add_argument('--tables', action='store_true')
    ap.add_argument('--census', action='store_true')
    ap.add_argument('--example', nargs=7, metavar=('NOTE', 'STATUS', 'EXT1', 'EXT2', 'PART', 'TYPE', 'ROOT'))
    ap.add_argument('--bass', type=int)
    ap.add_argument('--turnover', type=int, default=8)
    ap.add_argument('--ceiling', type=int, default=127)
    ap.add_argument('--flags', type=lambda s: int(s, 0), default=0)
    ap.add_argument('--chord-changed', action='store_true')
    a = ap.parse_args()
    rom = Rom(a.rom).load()
    if a.tables:
        sets = recognized_sets(rom)
        print('type  name   family  row(def/ACC1/BASS)  sel(def/BASS)  recognized from (rel. to root)')
        for t in range(1, 42):
            print('%4d  %-6s %6d  %4d %4d %4d       %3d %3d       %s' % (
                t, rom.names[t] or '(M)', rom.family[t], rom.imap['default'][t], rom.imap['d4'][t],
                rom.imap['bass'][t], rom.pshift['default'][t], rom.pshift['bass'][t],
                ','.join(map(str, sorted(sets[t])))))
        print('\nrows (pitch class 0..11 deltas):')
        for i, r in enumerate(rom.rows):
            print('%3d  %s' % (i, ' '.join('%+d' % x if x else ' .' for x in r[:12])))
    if a.example:
        v = [int(x, 0) for x in a.example]
        tr = []
        out = correct_note(rom, v[0], v[1], v[2], v[3], v[4], v[5], v[6], bass=a.bass, turnover=a.turnover,
                           ceiling=a.ceiling, flags=a.flags, chord_changed=a.chord_changed, trace=tr)
        print('note %d (status 0x%02x, ext 0x%02x 0x%02x), part %d, chord type %d %s, root %d:' % (
            v[0], v[1], v[2], v[3], v[4], v[5], rom.names[v[5]] or '(M)', v[6]))
        for x in tr:
            print('   ' + x)
        print('-> played note %d' % out)
    if a.census:
        sets = recognized_sets(rom)
        notes = collections.Counter(pattern_notes())
        total = sum(notes.values())
        print('pattern notes of parts 4..32 in rhythm_data/: %d (%d distinct)' % (total, len(notes)))
        print('share of played notes (parts 4..32, notes < 0x78) whose pitch class is a tone the chord type is')
        print('recognized from; "root only" = the same notes moved by the root alone, no chord-type conversion')
        print('type  name    converted  root only   Bass    Acc1    Acc2    Acc3   dropped')
        for t in range(1, 42):
            hit = collections.Counter()
            tot = collections.Counter()
            base = 0
            drop = 0
            for (part, st, key, e1, e2), n in notes.items():
                if key >= 0x78:
                    continue
                o = correct_note(rom, key, st, e1, e2, PARTS[part], t, 1)
                if o == 0:
                    drop += n
                    continue
                tot[part] += n
                if o % 12 in sets[t]:
                    hit[part] += n
                if key % 12 in sets[t]:
                    base += n
            allh, allt = sum(hit.values()), sum(tot.values())
            print('%4d  %-6s  %6.2f %%   %6.2f %%  %s  %d' % (
                t, rom.names[t] or '(M)', 100.0 * allh / allt, 100.0 * base / allt,
                '  '.join('%5.1f%%' % (100.0 * hit[p] / tot[p]) for p in PARTS), drop))


if __name__ == '__main__':
    main()
