# Sub-lane `engine` of lane kn5000-b (wave 4, 2026-10-31)

Issues: **kn5000-rlb** (voice allocation, sub CPU), **kn5000-wgc** (sequencer storage, main CPU),
**kn5000-98j** (accompaniment engine, main CPU), and four leads of **kn5000-nl6** (ChordDetect_*,
RhythmVariation_InlineCode_Code, VoiceSlot_FinalRetZ, ToneGen_CompareVoiceBlocks).

Addresses are v10 (main CPU) and v1.42 (sub CPU) unless said otherwise.  Labels are the ones this lane
leaves in the sources; the old names are in `scripts/renaming/rename_open4_engine.sed`.

Source changes, all byte-identical (`make gate`):

| tool                                           | what it does                                                                           |
|------------------------------------------------|----------------------------------------------------------------------------------------|
| `scripts/renaming/rename_open4_engine.sed`     | the renames below, in v10/v9/v7/v6/v5 and v142 (v141/v140 regenerated)                 |
| `scripts/tools/respell_open4_engine_tables.py` | data spelled as code -> `.byte`; v142 tables -> symbolic `.long`; chord-type row names |
| `scripts/tools/headers_open4_engine.py`        | version-neutral routine headers, corrected v142 allocator comments                     |

Probes: `probes/README.md`.

---

## kn5000-rlb -- voice allocation over the 64 tone-generator voices

The issue's starting point ("16 voice slots at 0x4A4C") was wrong: 0x4A4C is the held-key map, and the
allocator is a node-and-pool system over 64 voice records.  Most of it was already commented in
`v142/subcpu/kn5000_subprogram_v142.s` routine by routine; what was missing is the whole picture and three
facts this lane established from the code:

1. **The "forced/override node" at 0x1345 is the free list.**  `Voice_Retire_ToFreePool` moves a node into
   pool record 0x132B (= 0x112D + 17 x 30) under class 6 (`ld de, 6`), whose head word is at
   0x132B + 2 + 6 x 4 = 0x1345.  `Voice_Find_Candidate` returns that head first, so a free voice is always
   used before anything is stolen.
2. **The two "global" arrays are pools 16 and 17.**  0x130D = 0x112D + 16 x 30 (heads at 0x130F, the bit-7
   entries of the search lists) and 0x132B = pool 17.  Both are bound by the 27th part record (part 26,
   `Voice_Part_PoolPtr_ModeA` / `_ModeB` entry 26 -> pool 17) and both have quota 64.
3. **Pool classes.**  The class a node sits in is its state: `Voice_Allocate_Nodes` files a new node under the
   slot class's `+4` byte (0, 1 or 2: sounding), `Voice_Reprioritise` (note released, bit 3 -> bit 2) moves it
   to the `+5` byte (3, 4 or 5: released), `Voice_Demote_Decayed` (envelope level < 0x80) and
   `Voice_Retire_ToFreePool` use class 6.  The search lists rank decayed > released > sounding.

### Data structures (sub-CPU DRAM)

| address           | size         | what                                                                                           |
|-------------------|--------------|------------------------------------------------------------------------------------------------|
| 0x148D + v x 0x27 | 64 x 39 B    | voice node v (the TG channel number is node+0x24)                                              |
| 0x112D + g x 0x1E | 18 x 30 B    | pool record g: +0 quota, +1 count, +2 seven u32 class heads (classes 0..6)                     |
| 0x1349 + p x 0x0C | 27 x 12 B    | part record p: +0 pool-record pointer, +4 sounding-chain head, +8 released-chain head          |
| 0x292E / 0x2936   | 4 x u16 each | per-bank shadow of the TG active bitmap / "held, do not reap" bitmap (Voice_Manager_PollBank)  |
| 0x1129            | u32          | the note chain of the event being allocated (`Voice_Allocate_Nodes`, links at node+0x10/+0x14) |

Node fields used by the allocator: +0x00/+0x04, +0x08/+0x0C, +0x10/+0x14 three doubly linked lists (pool
class, part chain, note chain); +0x18 part record; +0x1C chain index; +0x1D pool record; +0x21 class;
+0x22 flags; +0x23 MIDI note; +0x24 TG channel; +0x25 envelope level / 32 (0xFF when keyed);
+0x26 released class.  Flag bits (+0x22): bit 0 free, bit 1 decayed, bit 2 released (envelope watched),
bit 3 sounding, bit 4 stolen at the quota, bit 7 held (no reaping).

### Allocation (`Voice_Allocate_Nodes`, called by the four note-on builders)

A note-on request carries up to four layer slots; each slot byte selects a slot class (low nibble) in
`Voice_LayerClassTable` (16 x {u32 search list, u8 allocation class, u8 released class}):

| slot class | search list                 | allocation class | released class |
|------------|-----------------------------|------------------|----------------|
| 0          | `Voice_Search_Order_List_1` | 0                | 3              |
| 1          | `Voice_Search_Order_List_2` | 1                | 3              |
| 2          | `Voice_Search_Order_List_3` | 2                | 4              |
| 3..15      | `Voice_Search_Order_List_3` | 2                | 5              |

| list (address)                         | order (bit 7 = pool 16's class, else the part's own pool) |
|----------------------------------------|-----------------------------------------------------------|
| `Voice_Search_Order_List_1` (0x00F60B) | 86 85 06 05 84 83 82 04 03 02 81 80 01 00                 |
| `Voice_Search_Order_List_2` (0x00F61A) | 86 85 06 05 84 83 82 04 03 02 81 80 01                    |
| `Voice_Search_Order_List_3` (0x00F628) | 86 85 06 05 84 83 82 04 03 02                             |
| `Voice_StealPoolOrder` (0x00F603)      | 06 05 02 04 03 01 00 (own pool only)                      |

Per slot: take the free list if it is not empty; otherwise the first non-empty class in the list (so a
class-0 layer may take a sounding class-0/1 voice, a class-2 layer only decayed, released or class-2
voices); none -> the slot gets 0xFF and the layer is silently dropped.  The node is keyed (note, level
0xFF, released class), flagged 0x88 (held) or 0x08, filed under its allocation class in the part's pool,
put on the part's sounding chain and the event's note chain.  Then the pool count is checked against the
quota: below it, count +1; at it (`Voice_Allocate_Nodes_StealAtQuota`) `Voice_FindStealCandidate` picks a
victim in the same pool by `Voice_StealPoolOrder`, moves it to pool 16 under its own class and sets flag
bit 4 -- it keeps sounding but is now the first thing any later allocation takes.

### Quotas (`Voice_Pool_Quota_ModeA` / `_ModeB`, by `Voice_SetPolyphonyMode`)

`Voice_Reset_Engine` (A = 0 at boot, `Voice_SetPolyphonyMode` with system sub-command 0x09 otherwise)
copies one quota row into the 18 pool records and binds the 27 parts:

| mode | pools 0..15 quotas               | parts -> pool                                                              |
|------|----------------------------------|----------------------------------------------------------------------------|
| A    | 32 16 4 12, rest 0               | parts 0-3 -> 0, 4-14 / 16-18 / 21 -> 1, 19 / 22 -> 2, 15 / 20 / 23-25 -> 3 |
| B    | 12 6 6 4 4 4 4 4 2 2 2 2 2 2 2 6 | parts 0-15 -> pools 0-15, 16-25 folded onto 11-15                          |

Both rows of pools 0..15 sum to 64.  [INFERENCE] mode A is the keyboard's own allocation (four pools for
the panel's part groups), mode B a 16-part multi-timbral one; `Voice_SetPolyphonyMode`'s callers decide
which (A = 1 -> mode B); the main-CPU sender of sub-command 0x09 was not traced.
**Answered 2026-11-02 (kn5000-1gu, `notes/open6-kn5000-d/subcmd/README.md`):** mode B is General MIDI mode.
GM ON/OFF (`PANEL_GM`+3 bit 2) sends `F0 7F 09 01` (on -> mode B) or `F0 7F 09 02` (off -> mode A).

### Release and reaping

Note-off (`VoiceSlot_NoteOff`, `OutputBuf_Flush_B`) moves the node to the part's released chain and calls
`Voice_Reprioritise`.  A sustained note keeps bit 7 until `Voice_Clear_HoldBit` (12 callers, pedal-up and
note-off paths) clears it and re-runs `Voice_Reprioritise`.  `Voice_Manager_PollBank` polls one bank of 16
TG channels every other tick (each bank every 8 ticks): a voice the TG reports silent that was active and
is not held goes back to the free list (`Voice_Retire_ToFreePool`, `ToneGen_SilenceChannel`); a released
voice whose envelope reads below 0x80 is demoted to class 6.

Renames (v142, v141/v140 regenerated): `Voice_KeyTable_Remapping` -> `Voice_StealPoolOrder`,
`Voice_SFX_ModulationTable` -> `Voice_LayerClassTable` (now `.long` + `.byte` records),
`Voice_Pitch_Table_High` -> `Voice_Part_PoolPtr_ModeB` (now `.long 0x112d + 30*k`),
`NoteChain_FindNode_B*` -> `Voice_FindStealCandidate*`, `Voice_Allocate_Nodes_WalkNext` ->
`_StealAtQuota`, `_AdvancePriority` -> `_CountAgainstQuota`; headers of `Voice_Find_Candidate`,
`Voice_FindStealCandidate` and the two allocator steps corrected.

Left open: none of the issue's questions.  The main-CPU side of mode selection (who sends system
sub-command 0x09) is a separate question, listed under "Proposed new issues".

### Website page draft (audio-subsystem.md, replace "Polyphony and Voice Management"'s last paragraph and add a section after it)

> #### Voice allocation
>
> The 64 tone-generator voices are allocated by `Voice_Allocate_Nodes` in the sub CPU.  Each voice has a
> 39-byte node at sub-CPU DRAM 0x148D + v x 0x27; nodes live in **pools**: 18 records of 30 bytes at
> 0x112D (+0 quota, +1 count, +2 seven list heads, one per *class*).  Each of the 27 parts points to one
> pool (`Voice_Part_PoolPtr_ModeA` / `_ModeB`); pool 16 holds stolen voices and pool 17 (part 26) is the
> free list.  A node's class is its state: 0-2 sounding (by layer class), 3-5 released, 6 decayed or free.
>
> For each layer of a note, `Voice_LayerClassTable` gives a search list.  A free voice is taken first;
> otherwise the first non-empty class in the list, decayed before released before sounding, stolen voices
> before the part's own:
>
> | layer class | takes, in order                           |
> |-------------|-------------------------------------------|
> | 0           | decayed, released, sounding class 2, 1, 0 |
> | 1           | decayed, released, sounding class 2, 1    |
> | 2+          | decayed, released, sounding class 2       |
>
> When nothing qualifies the layer is dropped silently (slot = 0xFF).  When the pool's count reaches its
> quota, the pool's lowest-ranked voice (`Voice_StealPoolOrder`: decayed, released, then sounding) is moved
> to pool 16 and flagged, so the next allocation anywhere takes it first.
>
> | mode (system sub-command 0x09) | quotas of pools 0-15              |
> |--------------------------------|-----------------------------------|
> | A (boot default)               | 32, 16, 4, 12                     |
> | B                              | 12, 6, 6, 4, 4, 4, 4, 4, 2 x 7, 6 |
>
> Voices come back through `Voice_Manager_PollBank`, which reads one bank of 16 TG activity bits every
> other tick and returns to the free list each voice that went silent and is not held; a released voice
> whose envelope falls below half is demoted to class 6.  Sustained notes are held (flag bit 7) until
> `Voice_Clear_HoldBit` runs on pedal-up.

---

## kn5000-wgc -- sequencer storage and events

### Storage (consolidates floppy-disk-formats.md "SQT" with the RAM view)

| RAM                              | what                                                                                             |
|----------------------------------|--------------------------------------------------------------------------------------------------|
| `SEQ_SONG_SLOTS` 0xAB000         | 10 song records of 0x800 bytes (the SQT file's part 1)                                           |
| `SEQ_SONG_RECORD` 0xF180         | the current song's record, copied in from slot `SEQ_CURRENT_SONG` and back                       |
| `SEQ_BLOCK_POOL` -> 0xB0000      | 1,240 blocks of 256 bytes (`SEQ_BLOCK_TOTAL`), block n at 0xB0000 + (n - 1) x 0x100 (SQT part 2) |
| 0x0C9E + 2(t-1) / 0x0CBE + (t-1) | per-track cursor: block number (u16) and offset (u8, 5..255)                                     |

Block: +0 flags (bit 7 used), +1 previous block (u16), +3 next block (u16, 0xFFFF = last), +5..+0xFF 251
data bytes; events run on across blocks.  Free blocks form a list through +3 from `SEQ_FREE_LIST_HEAD`
(record +0xAF), counted by `SEQ_FREE_BLOCKS` (+0xB1).

Song-record fields used by the storage code (offsets from 0xF180; the panel-memory part is on
floppy-disk-formats.md):

| offset | size     | field                                                            | evidence                          |
|--------|----------|------------------------------------------------------------------|-----------------------------------|
| +0x1E  | u16      | `SEQ_TRACK_MASK`, one bit per track holding data                 | ram_variables_by_use.s            |
| +0x20  | 16 B     | `SEQ_TRACK_ASSIGN` (13 CHORD, 14 APC, 15 CONTROL, 16 RHYTHM ...) | ram_variables_by_use.s            |
| +0x78  | 16 x u16 | each track's tail block (where recording appends)                | `SeqTrack_AdvanceCursor` (new)    |
| +0x98  | 16 B     | each track's write offset in its tail block                      | `SeqTrack_AdvanceCursor` (new)    |
| +0xAF  | u16      | `SEQ_FREE_LIST_HEAD`                                             | ram_variables_by_use.s            |
| +0xB1  | u16      | `SEQ_FREE_BLOCKS`                                                | ram_variables_by_use.s            |
| +0xD0  | 16 x 3 B | `SEQ_TRACK_TABLE`: {flags (bit 7 = has data), u16 first block}   | ram_variables_by_use.s, the disks |

`SeqTrack_AdvanceCursor` (was `VoiceSlot_ReadParamsWithSaveRestore_Helper2`) moves a cursor DE bytes on:
within a block it only stores the offset; past 255 it follows the +3 link once per 251 bytes; in the
track's tail block it refuses to pass the write offset (W = 0xFF).  `SeqTrack_ReadByteAndAdvance` (was
`VoiceSlot_FinalRetZ`) is read-one-byte-and-step, the reader the event parsers use (49 call sites).

Timing: 96 ticks per beat (`SEQ_BEAT_TICK` 0..95); event byte +1 is the tick within the beat; `0x81`
events mark the beats, so positions are (beat count, tick).

### Events

`SeqEvent_GetParamLength` gives each event's total length (status included).  Byte +1 is the tick for
every event of two bytes or more.  The data layouts below are measured on the 14 KN5000 disks
(`floppy/kn5000/*/files/*.SQT.s`, counted by `probes/sqt_event_census.py`); the meanings cite the
player's case in `SeqNoteCh_DispatchEventType` (sequencer_engine.s) or the routine named.

| status | len | layout after the tick                     | meaning                                                                                                                                       | evidence                                                                                                                                    |
|--------|-----|-------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------|
| 0x81   | 1   | -                                         | beat marker                                                                                                                                   | `SeqPart_ReadEventStream` counts them                                                                                                       |
| 0x82   | 1   | -                                         | end of track (bytes after it are stale)                                                                                                       | the case clears the part's active bit                                                                                                       |
| 0x84   | -   | -                                         | skipped by the player (2 occurrences on the disks); `SeqEvent_GetParamLength` returns 0xFFFF                                                  | `SeqPlay_IterateCh_CheckEventType`                                                                                                          |
| 0x85   | 2   | -                                         | **accompaniment start** in the song                                                                                                           | sets `SEQ_RTMCFG` bit 1 (accompaniment runs with the song); `MIDI_RESET_PLAYBACK_STATE` queues 0x85 when MIDI Start arrives while recording |
| 0x86   | 2   | -                                         | **accompaniment stop**                                                                                                                        | clears `SEQ_RTMCFG` bit 1                                                                                                                   |
| 0x80   | 4   | tempo low 7 bits, tempo bit 7 + high      | **tempo change**: tempo = byte2 or bit 0 of byte3 << 7, stored in panel record 0x48 fields 8/9                                                | `SeqNoteCh_HandleTempoEvent` -> `SeqEvt_ApplyTempoEvent` (was `AccPedalConfig_ApplyTempo`); disks hold 102..127                             |
| 0x9n   | 6   | key, velocity, duration lo7, duration hi7 | note (duration in ticks, 7-bit little-endian)                                                                                                 | sent on as a 5-byte record without the duration (`SeqNote_SetupVoice`)                                                                      |
| 0xBn   | 6   | panel record, field, value, value         | **panel-parameter change** (n = flag bits); record 0x48 (style) fields 5 / 6 get extra handling                                               | `SeqPlay_IterateCh_CheckControlChange` tests record 0x48 field 5 / 6; `AccPedalConfig_ApplyChannel0` applies it                             |
| 0xCn   | 6   | panel record, 0, value, value             | **record select**: a part record (0x00-0x19) gets a sound, record 0x48 field 0 on track 16 a rhythm [INFERENCE: value, value = program, bank] | `SeqCh_DispatchMidi_CheckResult` -> `Rhythm_NoteDispatchWrapper`; `AccPedalConfig_ApplyChannelDirect`                                       |
| 0xD0   | 3   | value                                     | single-value controller, sent as a 4-byte record                                                                                              | `SeqNoteCh_HandleEventD0`                                                                                                                   |
| 0xD1   | 3   | value                                     | single-value controller (2,170 on the disks, values 19..94)                                                                                   | `SeqNoteCh_HandleEventD1`                                                                                                                   |
| 0xD2   | 4   | lsb, msb                                  | pitch bend (3,809 on the disks; rest value 0, 64), sent as a 5-byte record                                                                    | `SeqNoteCh_HandleEventD2`                                                                                                                   |
| 0xD3   | 3   | 0 or 127 (few others)                     | switch-type controller; the player also sets `DEMO_CONTROL_FLAGS` bit 6                                                                       | `SeqNoteCh_HandleEventD3`, `SeqPlay_IterateCh_NotControlChange`                                                                             |
| 0xA0   | 3   | value                                     | in the length table, absent from the disks                                                                                                    | `SeqEvent_GetParamLength`                                                                                                                   |

[INFERENCE] which controllers 0xD0, 0xD1 and 0xD3 are: their values fit aftertouch / modulation (D1) and a
pedal (D3, 0/127).  The player forwards them unchanged to the sub-CPU batch (`SeqBuf_WriteMidiEvent` ->
`Audio_ReinitAndProcessEvents`); the conversion that turns them into sub-CPU records is the remaining step,
listed under "Proposed new issues".
**Answered 2026-11-02 (kn5000-a1f, `notes/open6-kn5000-d/subcmd/README.md`):** 0xD0 = channel pressure, 0xD1 =
modulation, 0xD2 = pitch bend, 0xD3 = expression (the expression pedal on a CONTROL track).  They reach the sub CPU
as `D0 part 00 v`, `B0 part 01 v`, `E0 part lsb msb` and `B0 part 0B v`.  In 0xBn, the second "value" byte is the
write mask.  The two value bytes of 0xCn are part-record bytes +0 (sound number) and +1 (variation bank).

Renames (v10/v9/v7/v6/v5): `AccPedalConfig_ApplyTempo` -> `SeqEvt_ApplyTempoEvent`,
`SeqNote_NoteOff_CheckActive` -> `SeqNoteCh_HandleTempoEvent`, `SeqNote_NoteOff_CheckActive2` ->
`SeqNoteCh_HandleEventD2`, `SeqNote_UpdatePosition{A,B}_Entry` -> `SeqNoteCh_HandleAcc{Start,Stop}Event`,
`VoiceSlot_FinalRetZ` -> `SeqTrack_ReadByteAndAdvance`, `VoiceSlot_ReadParamsWithSaveRestore_Helper2` ->
`SeqTrack_AdvanceCursor`, local labels `VoiceSlot_FinalRetZ_*` -> `SeqBlockChain_*`.

### Website page draft (sequencer.md, replace "Event Storage Format" through "Timing")

> ## Song storage
>
> Ten songs live in RAM: their 0x800-byte records at 0xAB000 (`SEQ_SONG_SLOTS`; the current one is copied
> to 0xF180) and their events in a shared pool of 1,240 blocks of 256 bytes at 0xB0000.  A block is
> {flags (bit 7 = used), u16 previous, u16 next (0xFFFF = last)} and 251 event bytes; a track is a chain of
> blocks whose first block is in the song record's track table (+0xD0, 16 x {flags, u16 block}).  The
> record also keeps each track's tail block (+0x78) and write offset there (+0x98), the free-block list
> (+0xAF) and the free count (+0xB1).  An .SQT file is these records and blocks
> ([Floppy Disk Formats]({{ site.baseurl }}/floppy-disk-formats/#kn5000-disk-files)).
>
> ## Events
>
> An event is a status byte and, for events of two bytes or more, the tick within the beat (0..95) and
> its data; `SeqEvent_GetParamLength` gives the length.  `0x81` marks each beat.
>
> (the event table above)

---

## kn5000-98j -- accompaniment engine

### Chord recognition (done)

`AccChord_ReadAndStoreKeys`, which accompaniment-engine.md calls the chord detector, only latches the
recognized chord (`CHORD_ROOT` / `CHORD_TYPE` / `CHORD_BASS_ROOT` / `CHORD_FLAGS`) into the accompaniment
state.  The recognizer is the `Chord_*` group in `audio/note_voice_mapping.s`:

1. **Trigger.**  `Chord_RecognizeNowOrDelay` starts recognition when the held chord keys change, at once
   (`CHORD_FLAGS` bit 6) or after a 5-tick delay (`CHORD_RECOGNIZE_DELAY`); a key count drop waits 6 or 22
   ticks (`CHORD_DECAY_TIMER`).
2. **Collect.**  `Chord_CollectHeldNotes` takes up to four held notes of distinct pitch class, newest first,
   into `CHORD_NOTES` / `CHORD_NOTE_COUNT`.
3. **Mask.**  `Voice_ComputeNoteBitPosition` builds a 12-bit interval set relative to the reference note
   (the last note in the list): bit 11 - i for a note i semitones above it, bit 11 for the reference.
4. **Look up.**  `ChordRecog_IntervalMaskTable[mask & 0x7FF]` (2,048 x 2 bytes at 0xEEAE44) gives the chord
   type (1..41) and the root as a semitone offset above the reference; root = pitch class of
   (reference + offset), counted 1 = C.  `probes/chord_table_check.py` checks all 292 non-zero entries.
   For chord types 1-30, 40 and 41 (189 entries) the type's notes (root plus voicing) moved up by the
   offset are the held set exactly (93), or a subset of it (34: extra held notes ignored), or a superset
   (44: an incomplete fingering, e.g. a 9th chord held without its fifth).  The 18 entries whose notes
   contradict the held set are all among the 51 with bit 7 of the offset byte set: approximations (e.g.
   C, D, A, Bb -> 7(13)) that are accepted at once; for the others the recognizer first prefers a match on
   fewer notes.  Types 31-39 (103 entries) have no voicing row (below).
5. **Fall back.**  Without a match on all notes, `Voice_LookupNoteAndComputePitch` retries with 3, then more
   notes, then fewer from the top; with none, the last applied chord (`CHORD_LAST_TYPE` / `_ROOT`) stays.
   On-bass chords (`CHORD_FLAGS` bit 1) keep a separate bass root.
6. **Apply.**  `Chord_ApplyCurrentChord` builds the voicing from `Chord_Tables`: the type's note count and
   four intervals (`ChordTables_TypeNoteCount`, `ChordTables_TypeIntervals`) above the root, sounded between
   G3 and F#4 (`ChordTables_PitchMask`), and the bass note A1..G#2 (the 12 bytes after the first), and posts the chord to
   the display (0x8D40 / 0x8D42 / 0x8D44).

The 41 chord types (`ChordTables_TypeIntervals`, row names now in the source).  **Corrected 2026-11-02**
(notes/open-items/notes-errors-2026-10-31.md row 10; lane kn5000-d sub-lane accomp,
`notes/open6-kn5000-d/accomp/README.md` A3): the firmware does store names, `Tbl_ChordTypeNames` (0xEFF5B9,
64 x 5 LCD characters); the name column below now follows it, written conventionally.  Types 12 / 29 and 28 / 30 do
have identical interval rows in the ROM, but they are different chords: 29 is "9#5" and 30 "b9 13", recognized from
0,2,4,8,10 and 0,1,4,7,9,10; their rows are four-note subsets.  31-39 are named too:

| type | intervals | name   | type | intervals | name    | type  | intervals | name      |
|------|-----------|--------|------|-----------|---------|-------|-----------|-----------|
| 1    | 0 4 7     | M      | 15   | 4 7 10 2  | 9       | 29    | 0 4 8 10  | 9(#5)     |
| 2    | 0 4 7 10  | 7      | 16   | 4 7 10 1  | 7(b9)   | 30    | 0 4 9 10  | 7(b9,13)  |
| 3    | 0 4 7 11  | M7     | 17   | 4 7 11 2  | M7(9)   | 31-39 | (zero)    | see below |
| 4    | 0 4 8     | aug    | 18   | 4 7 9 2   | 6(9)    | 40    | 0 4 7 2   | add9      |
| 5    | 0 3 7     | m      | 19   | 0 3 7 9   | m6      | 41    | 0 3 7 2   | madd9     |
| 6    | 0 3 7 10  | m7     | 20   | 0 3 6     | dim     |       |           |           |
| 7    | 0 3 6 9   | dim7   | 21   | 3 7 10 2  | m7(9)   |       |           |           |
| 8    | 0 3 6 10  | m7(b5) | 22   | 3 9 2 7   | m6(9)   |       |           |           |
| 9    | 0 3 7 11  | mM7    | 23   | 0 5 7     | sus4    |       |           |           |
| 10   | 0 5 7 10  | 7sus4  | 24   | 4 7 10 3  | 7(#9)   |       |           |           |
| 11   | 0 4 7 9   | 6      | 25   | 0 4 6 11  | M7(b5)  |       |           |           |
| 12   | 0 4 8 10  | 7(#5)  | 26   | 0 4 8 11  | M7(#5)  |       |           |           |
| 13   | 0 4 6     | (b5)   | 27   | 0 3 6 11  | mM7(b5) |       |           |           |
| 14   | 0 4 6 10  | 7(b5)  | 28   | 0 4 9 10  | 7(13)   |       |           |           |

Types 31-39 (no voicing row; LCD names in quotes): 31 7(#9,13) "#9 13", 32 7(b13) "b13", 33 7(b9,b13) "b9b13",
34 7(#9,b13) "#9b13", 35 M7(13) "13", 36 M7(b13) "b13", 37 7(#11) "7 #11", 38 m7(11) "m7 11", 39 aug7(#11) "+7#11".

Types 15-18, 21, 22 and 24 are voiced without the root (four tension notes).  Types 31-39 are recognized
(103 table entries, e.g. held 0 5 6 11) but their voicing rows are zero.  **Answered 2026-11-02**
(`notes/open6-kn5000-d/accomp/README.md` A5, A6, kn5000-3qp): the accompaniment does not use these rows; it
converts its patterns for every type, 31-39 included, through `Rhythm_InstrMapTable_*` and the ext bytes.  The rows
are read only by the `Chord_Tables` voicing builders, whose traced consumer is the sequencer's step entry.
`NoteMask9_ClassTable` is the FINGERED mode's recognizer (a root-rotation search, types 1-27 plus add9 / madd9);
`ChordRecog_IntervalMaskTable` is the PIANIST mode's.

### Variation / fill switching and bass/chord transposition (not done here)

**Answered since**: section switching in `notes/open4-kn5000-b/accvar/README.md`; the transposition (kn5000-3qp) and
SYNCHRO / the end of an ending (kn5000-rzg) in `notes/open6-kn5000-d/accomp/README.md` (2026-11-02).

Variation stepping is already on the site (`AccDir_TickVector`).  The playback-time section switching
(intro -> variation -> fill-in -> variation / ending, `STYLE_SECTION` 0..29) and the transposition of the
Rhythm-ROM pattern notes to the recognized chord (`Note_PitchClassTable`,
`ToneGen_PitchClassNoteFormTable` in `sequencer/accompaniment_engine.s`) were not traced in this lane;
they are given as a proposed new issue.

### Website page draft (accompaniment-engine.md, replace "## Chord Detection")

> ## Chord Recognition
>
> The recognizer is the `Chord_*` group of the main CPU (`audio/note_voice_mapping.s`);
> `AccChord_ReadAndStoreKeys` only copies its result into the accompaniment state.
>
> 1. A change of the held chord keys starts recognition at once or after 5 ticks; when keys are released
>    it waits 6 or 22 ticks, so a chord is not lost while the hand moves.
> 2. Up to four held notes of different pitch class are collected, newest first.
> 3. Their intervals above the reference note form an 11-bit mask, which indexes the 2,048-entry table at
>    0xEEAE44: chord type and root offset.  Without a match the recognizer tries other note subsets, then
>    keeps the last chord.
> 4. The chord is voiced from `Chord_Tables`: the type's intervals above the root between G3 and F#4, and
>    a bass note between A1 and G#2.
>
> (the 41-type table above)

---

## kn5000-nl6 leads (this sub-lane's four)

| lead                              | finding                                                                                                                     | action                                                                                                                          |
|-----------------------------------|-----------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| `ChordDetect_*` (7 routines)      | they scroll and wrap the composer's measure view (registers B, C, D, E from `ToneGen_StepFwd_Alternate`); no chord          | renamed `AccTiming_{Scroll,Wrap}{Four,Two}BarView*`, exit labels `<name>_Ret` / `_Pad`, headers in all five trees               |
| `RhythmVariation_InlineCode_Code` | it and `_Code2` are the composer STEP title's record-part maps (32 bytes each), spelled as `nop` / `ld (1:8), 0:io` / `rcf` | respelled as `.byte` rows: `CmpStep_RecPartTowardBass_Map` / `_TowardDrums_Map`; callers `CmpStep_MoveRecPartTowardBass(_Impl)` |
| `VoiceSlot_FinalRetZ`             | reads a song-data byte and steps the track cursor; not a voice slot                                                         | `SeqTrack_ReadByteAndAdvance`, its step `SeqTrack_AdvanceCursor`, locals `SeqBlockChain_*` (kn5000-wgc above)                   |
| `ToneGen_CompareVoiceBlocks`      | compares nothing: it replaces the note event at the pattern cursor (save, delete, build, insert)                            | `ToneGen_ReplaceCursorNoteEvent`, its exit `ToneGen_MultiChan_Done`                                                             |

The rest of the `VoiceSlot_*` family in `display/scoop_display.s` (about 1,200 references) is song-memory
code too; renaming it is listed under "Proposed new issues".

## Proposed new issues

- Accompaniment section switching and pattern transposition (from kn5000-98j): the intro / variation / fill /
  ending state machine over `STYLE_SECTION` at play time, and how `Note_PitchClassTable` /
  `ToneGen_PitchClassNoteFormTable` transpose Rhythm-ROM notes to the chord; the voicing source of chord
  types 31-39 and the chord mode that uses `NoteMask9_ClassTable`.
- Song controller events 0xD0 / 0xD1 / 0xD3 (from kn5000-wgc): trace `Audio_ReinitAndProcessEvents` /
  `VoiceMode_ParamDispatch` to the sub-CPU records they become.  (kn5000-a1f; answered 2026-11-02,
  notes/open6-kn5000-d/subcmd/.)
- Rename the `VoiceSlot_*` song-memory family in `display/scoop_display.s` (from kn5000-nl6).
- Main-CPU sender of sub-CPU system sub-command 0x09 (voice allocation mode A / B, from kn5000-rlb).  (kn5000-1gu;
  answered 2026-11-02, notes/open6-kn5000-d/subcmd/.)
