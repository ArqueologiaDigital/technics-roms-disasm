# Sub-lane `accomp` of lane kn5000-d (wave 6, 2026-11-02): pattern transposition and SYNCHRO

Issues: **kn5000-3qp** (how a rhythm-ROM pattern note becomes the played note for the recognized chord; the voicing
source of chord types 31-39; the chord mode that uses `NoteMask9_ClassTable`) and **kn5000-rzg** (SYNCHRO & BREAK
while running, synchro stop, where the accompaniment stops after an ENDING).

Addresses are v10 main-CPU addresses (`symbols/maincpu_v10_symbols_reference.txt`); the routines are in
`v10/maincpu/sequencer/` unless another file is named.  Labels are the ones in the tree today; the names this lane
proposes are in `rename_accomp.sed` (not applied) and the RAM names in `ram-names-accomp.txt` (input for
`scripts/tools/add_kn5000_ram_names.py`, not applied).  Probe: `probes/pattern_transpose.py` (`probes/README.md`).
Statements without a tag are read from the code; `[INFERENCE]` marks the rest.

---

## A. kn5000-3qp: from pattern note to played note

### A1. Where the conversion happens

A pattern note is converted once, when the lane engine writes it into its part's ring buffer, and again for every
buffered or sounding note when the chord changes.

1. `AccMidi_ParseCommon` (0xF56EED) reads a 0x90 / 0x91 event into `ACC_EVENT` (+0 status, +1 tick, +2 note,
   +3 velocity, +4/+5 duration).  `AccMidi_ParseNoteOn` (0xF56EC0) stores a 0x91 note's two extra bytes in RAM
   0x3433 / 0x3434 (named `ACC_EVENT_EXT1` / `_EXT2` in `ram-names-accomp.txt`).  For parts 4..32 the parser calls
   `Rhythm_CheckVelocityThreshold` (0xF54FA7) on the **note** byte: a note of 0x78 or more sets 0x32F4 bit 4 and
   is played as written.  The routine's name is wrong (it never sees a velocity).  IC14 has 137 such notes, all in
   part 16.
2. `AccMidi_DispatchPerPart` hands the drum parts 1 and 2 to `AccBuf_WriteNoteEvent`, which copies the note
   unchanged.  Parts 4, 8, 16 and 32 go to `AccCh1..4_NoteOnEntry` (0xF57686, 0xF57A13, ...), which load the part's
   turnover and ceiling (IC14 `part_sound` +5 / +6, `ACC_CH_TURNOVER` / `ACC_CH_CEILING`) and set 0x32F4 bit 3 for
   part 4 (BASS) or bit 2 for part 8 (ACCOMP1), neither for parts 16 / 32.  Then `AccBuf_WriteExtendedEvent`
   (0xF57704) writes the ring record and converts the note through `AccVoice_CorrectNote` (0xF577C9).
3. The ring record keeps the pattern note: 0x90 records are 7 bytes {status, tick, **played note**, velocity,
   duration lo, duration hi, **pattern note**}, 0x91 records 9 bytes (ext1 and ext2 before the pattern note).
4. On a chord change `Rhythm_CompareAndTrigger` (0xF54C22) compares the chord with the one the buffers were
   converted for (0x32DF..0x32E1) and runs `Rhythm_NoteOnAfterSetup_A/B/C`: `RhythmEvt_FullProcess` (0xF54ED8)
   converts every buffered record again from its pattern note, and `Rhythm_ValidateAndSend` (0xF554B1) does the same
   for the eight sounding notes per part (9-byte records at 0x30F4 / 0x313C / 0x3184 / 0x31CC) and re-sends them.
   Only for style numbers 0xF0 and up, for a part that plays no intro, fill-in or ending, and when the old and new
   chord have the same family (below), a fast path
   (`RhythmEvt_IterateNoteOn`, `Rhythm_MatchedPhrase`, `Rhythm_VelocityCompute`) converts without the ext shift.

The chord itself is copied by `AccChord_ReadAndStoreKeys` (smf_event_processor.s) into 0x32D7 flags, 0x32D8 type,
0x32D9 root (1 = C .. 12 = B) and 0x32DA bass root (= the root unless flags bit 1, the on-bass chord).  While 0x2308
is set (`AccompValidate_StoreResult`, sequencer_engine.s) it comes from 0x2300..0x2306 instead [INFERENCE: a song's
chord data].  During an ENDING a released chord (type 0) is replaced by the previous tick's (0x32DC..0x32DE).

### A2. The conversion (`AccVoice_CorrectNote`)

The patterns are written for **C major** (C, E and G, with A, B and D as colour notes; `--census` below).  For note
N of part P and chord {type T, root R, bass B, flags F}:

1. **Fixed notes.**  N >= 0x78: played as written (0x32F4 bit 4).
2. **Bass to the root** (part 4 only, `Rhythm_CrossVoiceCorrect`, 0xF54FDB).  When F bit 0 or bit 1 is set, or
   when no intro plays and the chord has just changed (0x32F3 bit 5, `AccChord_CompareAndSetDirty`), N becomes the C
   of its octave (`N - Note_PitchClassTable[N]`), ext1 / ext2 are cleared, and a floor
   `N + turnover + 1 - 12` is kept in 0x332E (flag 0x332D bit 0).  So the first bass note after every chord change,
   and every bass note of an on-bass chord, plays the (bass) root.  0x32F3 bit 5 is cleared after the first bass note.
3. **Root only** (`Rhythm_NoteRangeCheck`, 0xF55030): with F bit 0, every note of parts 4..32 becomes the C of its
   octave.  No code of the v10 recognizer sets `CHORD_FLAGS` bit 0; it can reach 0x32D7 only through the 0x2306
   override [INFERENCE].
4. **No chord.**  T = 0 (tested first, so fixed notes too), or R = 0 (B for the bass): the note becomes 0.
5. **ext shift** (0x91 notes only, `Rhythm_VoiceMapLookup`, 0xF551BD).  `Rhythm_PitchShiftTable_Default`[T]
   (`+0x31` for the bass) selects 0 = none, 1 = ext1, 2 = ext2.  The selected byte moves N by its low nibble, down
   when bit 4 is set; bit 5 drops the note (0).  No IC14 note uses bit 5.
6. **Chord-type row** (`Rhythm_VelocityLookup_A`, 0xF55053, for 0x90 notes; the second half of
   `Rhythm_VoiceMapLookup` for 0x91).  `Rhythm_InstrMapTable_Default`[T] gives a row of
   `Rhythm_VelLookA_TableLookup_Table` (21 rows x 16 signed bytes, C data at 0xE461C2); N moves by
   row[pitch class of N].  Part 8 uses the `_D4` variant (+0x31), part 4 the `+0x62` variant (identical to the
   default).  T of 0x30 or more reads entry 0.
7. **Root shift** (`Rhythm_TransposeNote`, 0xF5515D).  s = R - 1 (B - 1 for the bass); s above the part's turnover
   becomes s - 12.  N += s, an octave back if that leaves 0..127.  When the ceiling is 12 or more, N drops by octaves
   while N >= ceiling.  With the bass floor set, N below 0x332E is raised an octave.

IC14's turnovers are 6 for BASS and 8 for ACCOMP1-3 in 3,228 of the 3,232 sound records (2 in the other four), its
ceilings 127 (`rhythm_data/style_records.s`).  So the bass
moves up for roots C..F# and down for G..B; the chords move up for C..G# and down for A..B.

The ext bytes are the per-note rules.  Over all 95,112 0x91 notes of IC14 (`--census` source):

| byte | role                        | commonest rules (pattern note -> note before the row)                                   |
|------|-----------------------------|-----------------------------------------------------------------------------------------|
| ext1 | seventh family (selector 1) | E->E 39,993; G->Bb 12,991; C->Bb 11,571; B->Bb 6,902; A->Bb 6,568; A->A 5,662           |
| ext2 | minor family (selector 2)   | E->Eb 39,731; G->G 13,094; C->C 11,748; A->Ab 5,543; B->B 4,216; A->G 4,136; B->C 1,983 |

So ext1 says which note becomes the minor seventh and ext2 which notes move for a minor third; the row then turns
that C7 / Cm form into the chord type (M7: Bb -> B; dim: everything to C Eb Gb A; and so on).

### A3. The chord-type table, from the firmware's own tables

`python3 notes/open6-kn5000-d/accomp/probes/pattern_transpose.py --tables`.  The name is the firmware's own
(`Tbl_ChordTypeNames`, 0xEFF5B9, 64 x 5 LCD characters, read by `SNS_LoadKeyAndChord`; 0x88 = flat, 0x8C = sharp;
the same names in reverse order are the `ChordTypeStr_*` strings at 0xED006A).  "Family" is
`AccTuning_ReadAndApplyOffset_Table` (0xE49FC8; 0 major, 1 minor, 2 seventh, 3 dim7).  Row and selector are
explained in A2.  "Recognized from" is the union of the pitch-class sets `ChordRecog_IntervalMaskTable` maps to the
type, relative to the root.

| type | name  | family | row (16/32, 8, 4) | ext sel (default, bass) | recognized from |
|------|-------|--------|-------------------|-------------------------|-----------------|
| 1    | (M)   | 0      | 0 0 0             | 0 0                     | 0,4,7           |
| 2    | 7     | 2      | 0 0 0             | 1 1                     | 0,4,7,10        |
| 3    | Maj7  | 2      | 1 1 1             | 1 1                     | 0,4,7,11        |
| 4    | aug   | 0      | 5 5 5             | 0 1                     | 0,4,8           |
| 5    | min   | 1      | 0 0 0             | 2 2                     | 0,3,7           |
| 6    | min7  | 2      | 3 3 3             | 1 1                     | 0,3,7,10        |
| 7    | dim   | 3      | 9 9 9             | 1 1                     | 0,3,6,9         |
| 8    | m7b5  | 1      | 10 10 10          | 2 2                     | 0,3,6,10        |
| 9    | mM7   | 2      | 7 7 7             | 1 1                     | 0,3,7,11        |
| 10   | 7sus4 | 2      | 4 4 4             | 1 1                     | 0,5,7,10        |
| 11   | 6     | 2      | 2 2 2             | 1 1                     | 0,4,7,9         |
| 12   | aug7  | 2      | 5 5 5             | 1 1                     | 0,4,8,10        |
| 13   | b5    | 0      | 6 6 6             | 0 0                     | 0,4,6           |
| 14   | 7 b5  | 2      | 6 6 6             | 1 1                     | 0,4,6,10        |
| 15   | 79    | 2      | 0 11 0            | 1 1                     | 0,2,4,7,10      |
| 16   | 7 b9  | 2      | 0 12 0            | 1 1                     | 0,1,4,7,10      |
| 17   | M79   | 2      | 1 14 1            | 1 1                     | 0,2,4,7,11      |
| 18   | 69    | 2      | 2 15 2            | 1 1                     | 0,2,4,7,9       |
| 19   | m6    | 2      | 8 8 8             | 1 1                     | 0,3,7,9         |
| 20   | m b5  | 1      | 10 10 10          | 2 2                     | 0,3,6           |
| 21   | m79   | 2      | 3 16 3            | 1 1                     | 0,2,3,7,10      |
| 22   | m69   | 2      | 8 17 8            | 1 1                     | 0,2,3,7,9       |
| 23   | sus4  | 0      | 4 4 4             | 0 0                     | 0,5,7           |
| 24   | 7 #9  | 2      | 0 13 0            | 1 1                     | 0,3,4,7,10      |
| 25   | M7b5  | 2      | 18 18 18          | 1 1                     | 0,4,6,11        |
| 26   | M7#5  | 2      | 19 19 19          | 1 1                     | 0,4,8,11        |
| 27   | mM7b5 | 2      | 20 20 20          | 1 1                     | 0,3,6,11        |
| 28   | 13    | 2      | 0 0 0             | 1 1                     | 0,2,4,7,9,10    |
| 29   | 9#5   | 0      | 5 5 5             | 0 1                     | 0,2,4,8,10      |
| 30   | b9 13 | 2      | 0 12 0            | 1 1                     | 0,1,4,7,9,10    |
| 31   | #9 13 | 2      | 0 13 0            | 1 1                     | 0,3,4,7,9,10    |
| 32   | b13   | 2      | 5 5 5             | 1 1                     | 0,2,4,7,8,10    |
| 33   | b9b13 | 2      | 0 12 0            | 1 1                     | 0,1,4,7,8,10    |
| 34   | #9b13 | 2      | 0 13 0            | 1 1                     | 0,3,4,7,8,10    |
| 35   | 13    | 2      | 1 1 1             | 1 1                     | 0,2,4,7,9,11    |
| 36   | b13   | 2      | 1 1 1             | 1 1                     | 0,2,4,7,8,11    |
| 37   | 7 #11 | 2      | 6 6 6             | 1 1                     | 0,4,6,7,10      |
| 38   | m7 11 | 2      | 4 4 4             | 1 1                     | 0,3,5,7,10      |
| 39   | +7#11 | 2      | 5 5 5             | 1 1                     | 0,4,6,8,10      |
| 40   | add9  | 0      | 0 11 0            | 0 0                     | 0,2,4,7         |
| 41   | madd9 | 1      | 0 16 0            | 2 2                     | 0,2,3,7         |

Types 35 and 36 carry the same LCD name as 28 and 32 but are the major-seventh forms (M7(13), M7(b13)): row 1 turns
Bb into B and they are recognized from sets with 11, not 10.

The 21 rows (semitone moves per pitch class C..B; `.` = 0):

| row | C  | Db | D  | Eb | E  | F  | Gb | G  | Ab | A  | Bb | B  | effect                           |
|-----|----|----|----|----|----|----|----|----|----|----|----|----|----------------------------------|
| 0   | .  | .  | .  | .  | .  | .  | .  | .  | .  | .  | .  | .  | none                             |
| 1   | .  | .  | .  | .  | .  | .  | .  | .  | .  | .  | +1 | .  | Bb -> B (major seventh)          |
| 2   | .  | .  | .  | .  | .  | .  | .  | .  | .  | .  | -1 | .  | Bb -> A (sixth)                  |
| 3   | .  | .  | .  | .  | -1 | .  | .  | .  | .  | .  | .  | .  | E -> Eb (minor third)            |
| 4   | .  | .  | .  | +1 | +1 | .  | .  | .  | .  | .  | .  | .  | Eb, E -> E, F (sus4)             |
| 5   | .  | .  | .  | .  | .  | .  | .  | +1 | .  | .  | .  | .  | G -> G# (#5)                     |
| 6   | .  | .  | .  | .  | .  | .  | .  | -1 | .  | .  | .  | .  | G -> Gb (b5)                     |
| 7   | .  | .  | .  | .  | -1 | .  | .  | .  | .  | .  | +1 | .  | mM7                              |
| 8   | .  | .  | .  | .  | -1 | .  | .  | .  | .  | .  | -1 | .  | m6                               |
| 9   | .  | -1 | -2 | .  | -1 | -2 | .  | -1 | +1 | .  | -1 | +1 | every note to C Eb Gb A (dim7)   |
| 10  | .  | -1 | -2 | .  | -1 | -2 | .  | -1 | -2 | +1 | .  | -1 | every note to C Eb Gb Bb (m7b5)  |
| 11  | +2 | .  | .  | .  | .  | .  | .  | .  | .  | .  | .  | .  | C -> D (9th instead of the root) |
| 12  | +1 | .  | .  | .  | .  | .  | .  | .  | .  | .  | .  | .  | C -> Db (b9)                     |
| 13  | +3 | .  | .  | .  | .  | .  | .  | .  | .  | .  | .  | .  | C -> D# (#9)                     |
| 14  | +2 | .  | .  | .  | .  | .  | .  | .  | .  | .  | +1 | .  | M7(9)                            |
| 15  | +2 | .  | .  | .  | .  | .  | .  | .  | .  | .  | -1 | .  | 6(9)                             |
| 16  | +2 | .  | .  | .  | -1 | .  | .  | .  | .  | .  | .  | .  | m7(9)                            |
| 17  | +2 | .  | .  | .  | -1 | .  | .  | .  | .  | .  | -1 | .  | m6(9)                            |
| 18  | .  | .  | .  | .  | .  | .  | .  | -1 | .  | .  | +1 | .  | M7(b5)                           |
| 19  | .  | .  | .  | .  | .  | .  | .  | +1 | .  | .  | +1 | .  | M7(#5)                           |
| 20  | .  | .  | .  | .  | -1 | .  | .  | -1 | .  | .  | +1 | .  | mM7(b5)                          |

Rows 11-17 are used only by part 8 (ACCOMP1): that part plays the chord's tension in place of the root; the other
parts play the tension chord's four-note body.

**Evidence that this is the firmware's meaning** (`--census`, 245,470 notes of parts 4..32, root C): for every type
that has a conversion, the share of played pitch classes that are tones the type is recognized from rises, never
falls (min 57.5 % -> 77.8 %, m7b5 35.0 % -> 100 %, dim 39.5 % -> 100 %, 7 74.9 % -> 81.2 %, M7#5 52.0 % -> 82.8 %;
the unconverted major patterns themselves are 72.9 %, the rest being passing and colour notes).  The full list is
in `probes/README.md`.

### A4. Worked examples (`--example`, `probes/README.md`)

| pattern note           | part         | chord            | steps                                        | played |
|------------------------|--------------|------------------|----------------------------------------------|--------|
| E4 (64), 0x91, ext2 11 | 16 (ACCOMP2) | Dm7 (6, root 3)  | ext1 0; row 3: -1 (Eb); +2                   | F4 65  |
| E4 (64), 0x91, ext2 11 | 16           | G7 (2, root 8)   | ext1 0; row 0; +7                            | B4 71  |
| G1 (31), 0x90          | 4 (BASS)     | C/E on-bass      | to C1 (24), floor 26; row 0; bass root E: +4 | E1 28  |
| C4 (60), 0x90          | 8 (ACCOMP1)  | A9 (15, root 10) | row 11: +2 (D); root A = 9 > turnover 8: -3  | B3 59  |

### A5. Types 31-39: where their notes come from

They have no voicing problem in the accompaniment: A2-A3 convert the patterns for them through the same row and
selector tables as every other type (for example 32 b13 uses row 5, G -> Ab, in every part, and 33 b9b13 row 12,
C -> Db, in ACCOMP1).  The zero rows of `ChordTables_TypeIntervals` (0xFEA403) matter only to the readers of
`Chord_Tables`' voicing: the builders at `VoiceSlot_IterateAlloc_Block` (0xFEA201) and its twins, which fill 0xCEF1
(count) / 0xCEF2.. (notes).  Their reader is the sequencer's step entry
(`VoiceCtrl_ParamSetupBytecode_Tbl4_Sub`, 0xEFB8D3, display/scoop_display.s), which writes those notes as 0x90
records with the chord name at 0x0D6D / 0x0D6E (the `SNS_LoadKeyAndChord` display).  For types 31-39 that voicing
is four times the root [INFERENCE: only the step-entry consumer was traced; the builders' callers were not].

### A6. `NoteMask9_ClassTable` and the AUTO PLAY CHORD modes

`Voice_CheckAndResetSlotState`'s dispatcher (`NullRet2_TestBit24`, 0xFE96B4, audio/note_voice_mapping.s) picks the
live recognizer from RAM 0xC596, which `AudioInit_*` (audio/audioinit_routines.s) sets from `PANEL_STYLE+3` through
`ParamEdit_WordTable` (0xEE8E28: 1 -> bit 0, 2 -> bit 1, 3 -> bit 2, +8 -> bit 4).  The AUTO PLAY CHORD dialog
(widget strings at 0xE1B380, 0xE1B3C4, 0xE1B404, 0xE1B442) offers ONE FINGER = 1, FINGERED = 2, PIANIST = 3.  `CHORD_FLAGS` bit 6
(recognize at once) and 0xC598 bit 1 also send the dispatcher down the FINGERED path.

| 0xC596 bit (PANEL_STYLE+3) | recognizer                                                                                                      |
|----------------------------|-----------------------------------------------------------------------------------------------------------------|
| bit 0 (1, ONE FINGER)      | `EffectState_Dispatch_Block3` (0xFE96F6): `VoiceSlot_StoreParams_LoadReg3` key rules                            |
| bit 1 (2, FINGERED)        | `PitchCalc_Return_Block` (0xFE9956) -> `Voice_UpdateNoteBitmap` -> `NoteMask9_ClassTable`                       |
| bit 2 (3, PIANIST)         | `VoiceSlot_LoadResult_Block3` (0xFE9A9C) -> `Voice_LookupNoteAndComputePitch` -> `ChordRecog_IntervalMaskTable` |
| none of them               | as FINGERED                                                                                                     |

[INFERENCE] the mapping of the three dialog entries to PANEL_STYLE+3 values 1-3: the dialog's radio values and
`ParamEdit_WordTable`'s order agree, the widget-to-record link was not traced.

`ComputeNoteBitPositi_StoreDRAM` (0xFE98B8) is a root-rotation search: it takes each held note in turn as the root
(rotating the 12-bit interval mask until bit 11 is set) and looks the low 9 bits up in `NoteMask9_ClassTable`
(512 bytes at 0xEEBE44, values 1..27).  Only masks with no note 1 or 2 semitones above the root qualify; with all
notes counted, bit 9 (the 9th) set and the first root candidate, a value of 1 (M) becomes type 40 add9 and 5 (m)
type 41 madd9.  Of its 25
non-zero entries 22 agree with `ChordRecog_IntervalMaskTable` at root offset 0, 2 differ (0x042, 0x0A1) and one
(0x101, mM7 without fifth) exists only here.  So FINGERED knows types 1-27, 40 and 41; the tension types 28-39 are
recognized only in PIANIST mode.  `NoteDisplay_StoreAndDispatch` (0xFEA6D8, mode E = 2, three callers in the
sequencer) uses the same 9-bit path on a caller-supplied note list.

### A7. Corrections to earlier notes and to the site

- **engine/README.md (notes-errors row 10).**  Types 12 / 29 and 28 / 30 do have identical interval rows in the ROM
  (checked, `ChordTables_TypeIntervals`), but they are different chords: the firmware's names are 29 "9#5" and
  30 "b9 13" (`Tbl_ChordTypeNames`), and the recognition sets agree (0,2,4,8,10 and 0,1,4,7,9,10).  Their voicing
  rows are four-note subsets (aug7 and 7(13)).  The firmware **does** store chord names.  Corrected in
  `notes/open4-kn5000-b/engine/README.md`.
- `Note_PitchClassTable` (0xE46142) **is** used by the transposition: it is the note -> pitch-class map of steps 2,
  3 and 6 (`Rhythm_InstrBaseLookup`).  The tracker text and the site's Research Needed item say it is not.
- The site's "Rhythm Note Dispatch" table describes `Rhythm_NoteRangeCheck` as "Validate note is in playable
  range"; it is step 3 (root only).

### A8. Left open

- What sets `CHORD_FLAGS` / 0x32D7 bit 0 (no setter in the v10 recognizer; the 0x2306 override is the only path
  found).  Next step: trace the writers of 0x2306 (sequencer_engine.s `BitMapOut_*` / `NoteDisplay_*` callers).
- `Rhythm_TransposeWithMod` (0xF55AD0, called through `AccompSeq_CheckVelFlags*`, accompseq_routines.s) is a second
  converter with its own ext bytes (0x7E5A / 0x7E5B -> 0x33E6 / 0x33E7), the ACCOMP1 row map and no turnover; its
  caller (the composer / accompaniment sequencer) was not traced.
- The fast path's tables (`Rhythm_VelocityTable_A`) differ from the full path's only at type 7 (row 0 instead of 9);
  whether that is a firmware bug was not checked on hardware.

---

## B. kn5000-rzg: SYNCHRO & BREAK, synchro stop, the end of an ending

### B1. The button

`PanelButton_SynchroBreak` (0xFC5B91, audio/audio_control_engine.s; panel action `{0x48, 5, 5, 0x40}` in
`naka_extension_device.c`) posts the record-0x48 field-5 bit-1 switch event, except in modes 16 and 19.
`AccStyleCtl_SynchroButton` (0xF59CD9) toggles `PANEL_STYLE+5` bit 1 (the SYNCHRO LED) **in every transport state**
and echoes it to MIDI.  There is no separate BREAK action: the bit only arms the logic below, which acts on chord
keys.  Besides the button only `AccAutoPlay_Disable` (0xF5ABF3, called by `AccAutoPlay_PeriodicCheck` as soon as a
song track plays or records) clears it, so SYNCHRO stays lit after a synchro start.

### B2. The chord-key logic (`AccAutoPlay_*`, accompaniment_engine.s)

Every key event goes through `NoteOn_EntryPoint` (0xFE0245, audio/note_voice_mapping.s):
- key down, per sounding entry: `AccAutoPlay_NoteDispatch` (0xF5A82A) -> `AccAutoPlay_SplitDetect` decides whether the
  key is in the chord zone; 0x3498 bit 0 = a chord-zone key went down, bit 7 = a key went down in this pass;
- `AccAutoPlay_ZoneTrack` (0xF5A932) keeps the count of held chord-zone keys: 0x349C now, 0x349A before;
- then `AccAutoPlay_StateMachine` (0xF5A9B9) -> `AccAutoPlay_TriggerCheck` (0xF5A9FC).

`AccAutoPlay_SetConfig` (0xF5AAFB) recomputes 0x346D bit 7, "synchro allowed": SYNCHRO lit, an AUTO PLAY CHORD mode
on (`PANEL_STYLE+3` low bits 1-3, bit 3 clear) and no song recording, playing or composer recording.

| event                                               | condition                        | action                                                                                                                                                                                                                                    |
|-----------------------------------------------------|----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| first chord-zone key (0x3499 bit 0 clear)           | allowed, accompaniment stopped   | `AccAutoPlay_Configure` -> action 0xA0, `AccAutoPlay_SubModeA` -> 0x346D bit 2; `AccAutoPlay_ActionDispatch` -> `AccPlayMode_StartAccPlayFull` (0xF5AFD8): ACC and PLAY transports = 1, positions cleared, marker 0x85: **synchro start** |
| same                                                | allowed, stop pending (12)       | `AccAutoPlay_SubModeA`: clears bit 3 of `PLAY_TRANSPORT_STATE` and `ACC_TRANSPORT_STATE`: the stop is cancelled                                                                                                                           |
| same                                                | stopped, 0x3283 bits 0 and 1 set | 0x346D bit 0: `AccAutoPlay_DeferredAction` (main loop) starts it later                                                                                                                                                                    |
| all chord-zone keys released (0x349C 0, 0x349A not) | allowed, accompaniment running   | `AccAutoPlay_SeqHandoff` (0xF5ACB6) -> `AccPlayMode_StopToSync2` (0xF5AF3C): PLAY = 12 (stops at the next 24-tick boundary, `INTTR4_MetroBeat_Check`), ACC = 12, marker 0x86: **synchro stop**                                            |

So:
- **SYNCHRO** while stopped: the next chord starts the accompaniment from the top of the pattern.
- **SYNCHRO & BREAK while running** lights the same bit.  From then on, releasing every chord-zone key stops the
  accompaniment within a sixteenth (a break), and the next chord starts it again from the top.  A chord played
  before the stop takes effect cancels it.  Pressing the button again turns this off.
- Because SYNCHRO stays lit, an accompaniment that was synchro-started also stops on chord release.
- Without SYNCHRO, releasing the keys does nothing (0x346D bit 7 is clear).

`AccAutoPlay_SeqHandoff` also has a song branch (`AccPlayMode_StopExprFull` / `_StopExprC`, accompaniment only), but
"allowed" requires that no song track holds data, so this path does not reach it; its other caller
(`AccAutoPlay_Configure_Extended`) has no reference.  `AccAutoPlay_SubModeB` is the same as `_SubModeA` for the
song-playing configuration (also clears bit 3 of
`SEQ_TRANSPORT_STATE`, and defers through 0x346D bit 1 -> `AccPlayMode_StartPlay`).  The behaviour matches what a
"SYNCHRO & BREAK" button is expected to do, but the owner's manual was not checked [INFERENCE for the wording].

**Correction to accvar section 6.**  `ACC_TRANSPORT_STATE` = 128 / 134 is not the chord synchro wait: it is set by
`AccPlayMode_StartPlayFull` / `_StopExprB` only when 0x28B2 bit 1 is set (tested by `SeqPlay_CountInEnd`,
`SeqPlay_CheckAndStartPlayback`): the sequencer's start [INFERENCE: its count-in], which `INTTR4_SeqAutoStart`
completes at a bar end.  The chord-triggered start is the table above.

### B3. Where an ENDING stops the accompaniment

1. At a lane's 0x83 end marker `AccVoice_HandleMarker83` (0xF56A25) sees that the lane plays an ending
   (`ACC_LANES_ENDING1` / `_ENDING2`, or 0x3328) and calls `AccVoice_ActivatePart` (0xF56A56) instead of looping:
   the lane is parked (0x332A, 0x3328, 0x32F4 bit 0) and not advanced.  When all six lanes are parked, 0x3283 bit 2
   is set and 0x332A cleared.
2. With 0x3283 bit 2 set, `AccTick_Main` (0xF5804F) skips the lane engine and runs `AccState_CollectAll`
   (0xF591D1) every tick.
3. `AccState_CollectAll` waits while the accompaniment is already stopping (bit 3) and while any of the sounding-note
   tables (0x3094 and 0x30C4: 8 x 6 bytes, the drum parts; 0x30F4 / 0x313C / 0x3184 / 0x31CC: 8 x 9 bytes) holds a
   note with bit 7 set.  When the last ending note has been released it:
   - stops: `AccWrap_PlayModeStopSync` -> `AccPlayMode_StopToSync2` (both transports to 12) when no song track plays,
     else `AccWrap_PlayModeStartPlay` -> `AccPlayMode_StartPlay2` (accompaniment only, ACC = 12, marker 0x86);
   - sends all notes off (`AccInit_SendNoteOffAndFlush`), shows the keyboard's chord again;
   - clears the ENDING LEDs (`PANEL_STYLE+5` bits 4-5), 0x3283 bit 2 and all seven section lane bytes, and sets
     0x349F bit 1.
   `Rhythm_SaveState` then sees the ending lanes at 0 and clears the request bits (`_CheckEnding1Done`).

`AccPlayMode_StopToSync2` / `_StartPlay2` are misnamed: both stop (the proposed names are `AccPlayMode_StopPlayAndAcc`
and `AccPlayMode_StopAcc`).

### B4. Left open

- 0x3283 bits 0 and 1 (the deferral condition) and 0x3328's other writers were not traced.
- The sounding-note tables of the drum parts (0x3094, 0x30C4) are read here as "notes still on"; their layout
  beyond bit 7 of byte 0 was not checked.

---

## Renames and RAM names (for the lead)

- `rename_accomp.sed`: 49 rules, A2-A3 (`Rhythm_ChordConvertNote90/91`, `Rhythm_ChordRowMap*`,
  `Rhythm_ChordNoteDeltaRows`, `Rhythm_ChordExtSelect*`, `Rhythm_CheckFixedNote`, `Rhythm_BassToRoot`,
  `Rhythm_RootOnlyNote`, `Chord_TypeFamilyTable`, `AccVoice_ConvertNoteForChord`) and B (`AccSynchro_*`,
  `AccPlayMode_StopPlayAndAcc`, `AccPlayMode_StopAcc`, `AccEnding_StopWhenSilent`, `AccVoice_ParkLaneAtEnd`).  Apply to
  v10/v9/v7/v6/v5 `.s` and `.c` (`Rhythm_VelLookA_TableLookup_Table`, `AccTuning_ReadAndApplyOffset_Table` and
  `Rhythm_InstrBaseLookup` are named in C), symbols/, docs/, notes/ and the site.
- `ram-names-accomp.txt`: 23 names (0x32D7..0x32E1 the accompaniment's chord copies, 0x332D/E the bass floor,
  0x3433..0x3435 the ext bytes and pattern note, 0x332A, 0x3498..0x349C, 0x346D/E).  Its comments quote today's
  routine names; run it before the sed so the sed renames them too.

## Website page draft (accompaniment-engine.md)

**1. Replace** the 41-type table under "## Chord Recognition", the sentence "the firmware stores no names, the names
are the disassembly's", and the paragraph "Types 15-18 ... which chord mode uses it is open." with:

> The 41 chord types.  The names are the firmware's own (`Tbl_ChordTypeNames`, the LCD's 5-character names;
> type 1 shows the root alone).  "Voicing" is `ChordTables_TypeIntervals`, the notes `Chord_ApplyCurrentChord` and the
> sequencer's step entry use; the accompaniment does not use it (see Pattern transposition).
>
> (table: type, LCD name, voicing; the voicings of 29 and 30 are 0 4 8 10 and 0 4 9 10, four-note subsets of
> 9(#5) and 7(b9,13); 31-39 have none: #9 13, b13, b9b13, #9b13, M7(13) "13", M7(b13) "b13", 7#11, m7 11, +7#11)
>
> The chord mode decides which recognizer runs.  In PIANIST mode (`PANEL_STYLE+3` = 3) it is the 2,048-entry table
> above.  In FINGERED mode (2, and the default) `ComputeNoteBitPositi_StoreDRAM` tries each held note as the root
> and looks the intervals up in `NoteMask9_ClassTable` (512 entries): it knows types 1-27 plus add9 / madd9, so the
> tension chords 28-39 are recognized in PIANIST mode only.  ONE FINGER (1) has its own key rules.

**2. Add** after "## Chord Recognition" (and drop the sentence "The chord then drives the pattern: ... not traced yet"):

> ## Pattern transposition
>
> The rhythm-ROM patterns are written for C major.  Each note of the BASS and ACCOMP 1-3 parts is converted for the
> current chord when the lane writes it into its ring buffer (`AccVoice_CorrectNote`), and again from the stored
> pattern note when the chord changes (`Rhythm_CompareAndTrigger`).  The drum parts are not converted, nor are
> notes of 120 and above.
>
> 1. A 0x91 note carries two rule bytes.  For a seventh-family chord the first applies, for a minor-family chord
>    the second (`Rhythm_PitchShiftTable_Default`): low nibble = semitones, bit 4 = down, bit 5 = drop.  In IC14 the
>    first moves the colour note to Bb (G, C, A or B -> Bb) and the second E to Eb (and A to Ab or G).
> 2. The chord type picks one of 21 rows of semitone moves per pitch class (`Rhythm_InstrMapTable_*`,
>    `Rhythm_VelLookA_TableLookup_Table`): M7 raises Bb to B, m7 lowers E, dim snaps every note to C Eb Gb A, and so
>    on.  ACCOMP 1 has its own map that replaces the root with the tension (D for 9, Db for b9, D# for #9).
> 3. The note moves by the root (`Rhythm_TransposeNote`): up by up to the part's turnover (IC14: 6 semitones for
>    the bass, 8 for the chords), otherwise down; notes at or above the part's ceiling drop by octaves.
> 4. The bass plays the bass root of an on-bass chord, and the root on the first note after each chord change
>    (`Rhythm_CrossVoiceCorrect`), within a window that keeps it near the written note.
>
> (the type / row / selector table and the 21 rows from the disassembly notes; worked example: E4 of a 0x91 note
> with rules 00 / 11 plays F4 for Dm7 and B4 for G7)

**3. In "## Section switching"**, replace "Where the firmware stops it after an ending is not traced yet." with:

> An ending does not loop: each lane stops at the end marker (`AccVoice_ActivatePart`), and when all six have
> stopped and their last notes are released `AccState_CollectAll` stops the accompaniment (and only the
> accompaniment if a song plays), sends all notes off and clears the ENDING LEDs.

and replace the closing SYNCHRO paragraph with:

> ### SYNCHRO & BREAK
>
> The button toggles SYNCHRO (record 0x48 field 5 bit 1) whether the accompaniment runs or not.  While SYNCHRO is
> lit, an AUTO PLAY CHORD mode is on and no song plays or records, the chord keys drive the transport
> (`AccAutoPlay_TriggerCheck`):
>
> - stopped: the first chord key starts the accompaniment from the top (`AccPlayMode_StartAccPlayFull`);
> - running: releasing every chord key stops it at the next sixteenth (`AccAutoPlay_SeqHandoff` ->
>   `AccPlayMode_StopToSync2`), the break; the next chord starts it again, and a chord played before the stop
>   takes effect cancels it.
>
> SYNCHRO stays lit after a synchro start; only the button, or a song track starting, turns it off.

**4. Research Needed**: tick the transposition item (link to "Pattern transposition"), tick "Analyze the bass
pattern generation algorithm" (the bass is converted like the other parts, plus the root rule), update the chord
recognition item ("open: what sets CHORD_FLAGS bit 0"), and replace "open: SYNCHRO & BREAK ... after an ending" with
a link to "SYNCHRO & BREAK".  In "## Rhythm Note Dispatch" change `Rhythm_NoteRangeCheck`'s purpose to "with chord
flag bit 0, plays every note as the root".

## Evidence

- Code, v10: `sequencer/accompaniment_engine.s` (`AccMidi_*`, `AccBuf_WriteExtendedEvent`, `AccVoice_CorrectNote`,
  `AccCh1..4_NoteOnEntry`, `AccVoice_HandleMarker83`, `AccVoice_ActivatePart`, `AccTick_Main`, `AccState_CollectAll`,
  `AccStyleCtl_SynchroButton`, `AccAutoPlay_*`, `AccPlayMode_*`), `sequencer/rhythm_routines.s` (`Rhythm_*`,
  `RhythmEvt_*`), `sequencer/smf_event_processor.s` (`AccChord_ReadAndStoreKeys`), `sequencer/seq_audio_mode.s`
  (`AccChord_CompareAndSetDirty`), `audio/note_voice_mapping.s` (recognizers, `NoteOn_EntryPoint`),
  `audio/audioinit_routines.s` (0xC596), `audio/audio_control_engine.s` (`PanelButton_SynchroBreak`),
  `display/scoop_display.s` (`Tbl_ChordTypeNames`, `SNS_LoadKeyAndChord`).
- Tables read from `original_ROMs/kn5000_v10_program.rom` by `probes/pattern_transpose.py`.
- `scripts/analysis/kn5000_ram_bit_usage.py --tree v10 0x3283 0x332a 0x346d 0x3498 0x3499 0x346e 0x28b2` lists every
  setter, clearer and tester of the flag bytes of section B.
