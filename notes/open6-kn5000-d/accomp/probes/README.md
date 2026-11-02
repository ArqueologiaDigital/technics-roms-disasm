# Probes of sub-lane `accomp` (lane kn5000-d, 2026-11-02)

Run from the repository root.  Every probe reads committed files only: the v10 dump
`original_ROMs/kn5000_v10_program.rom` and the typed IC14 source `rhythm_data/patterns/*.s`.

| script                 | question it answers                                                                                                                                        | command                                                                                           |
|------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| `pattern_transpose.py` | How does an IC14 pattern note become the played note for the recognized chord (kn5000-3qp)?  Re-implements AccVoice_CorrectNote from the firmware's tables | `python3 notes/open6-kn5000-d/accomp/probes/pattern_transpose.py --tables`                        |
|                        | One note, step by step (NOTE STATUS EXT1 EXT2 PART TYPE ROOT; root 1 = C)                                                                                  | `python3 notes/open6-kn5000-d/accomp/probes/pattern_transpose.py --example 64 0x91 0 0x11 16 6 3` |
|                        | Does the conversion make the patterns fit the chord?  All 245,470 notes of parts 4..32, every chord type, root C                                           | `python3 notes/open6-kn5000-d/accomp/probes/pattern_transpose.py --census`                        |

## What `pattern_transpose.py` reads and what passing means

Tables (v10 addresses; v9 links them at the same addresses):

| table                                | address  | shape    | role                                                                         |
|--------------------------------------|----------|----------|------------------------------------------------------------------------------|
| `Note_PitchClassTable`               | 0xE46142 | 128 B    | note -> pitch class                                                          |
| `Rhythm_VelLookA_TableLookup_Table`  | 0xE461C2 | 21 x 16  | signed semitone delta per [row][pitch class]                                 |
| `Rhythm_InstrMapTable_Default`       | 0xF550CA | 3 x 49   | chord type -> row; +0 parts 16/32, +0x31 part 8, +0x62 part 4                |
| `Rhythm_PitchShiftTable_Default`     | 0xF5526F | 2 x 49   | chord type -> ext selector (0 none, 1 ext1, 2 ext2); +0x31 part 4            |
| `AccTuning_ReadAndApplyOffset_Table` | 0xE49FC8 | 48 B     | chord type -> family (0 major, 1 minor, 2 seventh, 3 dim7)                   |
| `Tbl_ChordTypeNames`                 | 0xEFF5B9 | 64 x 5   | the chord-type names the LCD shows                                           |
| `ChordRecog_IntervalMaskTable`       | 0xEEAE44 | 2048 x 2 | which pitch-class sets each type is recognized from (the census's yardstick) |

`--census` measured 2026-11-02: 245,470 pattern notes (3,026 distinct note / status / ext combinations).  For every
chord type except M (1) and add9 (40), which have no conversion, the share of played pitch classes that belong to
the set the type is recognized from rises: for example min 57.5 % -> 77.8 %, m7b5 35.0 % -> 100 %, dim 39.5 % ->
100 %, 7 74.9 % -> 81.2 %, M7#5 52.0 % -> 82.8 %.  The remaining notes are the patterns' passing and colour notes
(the major-chord patterns themselves have 72.9 % chord tones).  No ext byte in IC14 has bit 5 set (the "drop
this note" code), so the "dropped" column is 0 everywhere.  A conversion that moved notes off the chord would show
as a fall; none does.  That is the evidence that the table semantics written in the README are the firmware's.

`--example` cases quoted in the README (all from this probe):

| input                                                   | output | reading                                     |
|---------------------------------------------------------|--------|---------------------------------------------|
| E4 (64), 0x91, ext 00/11, part 16, Dm7 (type 6, root 3) | 65 F4  | the minor third of D                        |
| E4 (64), 0x91, ext 00/11, part 16, G7 (type 2, root 8)  | 71 B4  | the third of G                              |
| G1 (31), 0x90, part 4, C/E on-bass (flags 2, bass 5)    | 28 E1  | on-bass: the bass plays the bass root       |
| C4 (60), 0x90, part 8, A9 (type 15, root 10)            | 59 B3  | ACCOMP1 voices the 9th in place of the root |
