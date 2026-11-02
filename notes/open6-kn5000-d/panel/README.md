# Panel companion records, DSP slot packing, sound-record captions (sub-lane open6-kn5000-d/panel, 2026-11-02)

Three items of `notes/kn5000-style-2026-10-31/README.md` "Left open", settled from the v10 main-CPU code that reads
the bytes.  The KN5000 floppy sources (`floppy/kn5000/`) now carry the names; the 14 disk images still rebuild byte for
byte (`make -C floppy gate-kn5000`: "All 14 kn5000 floppies reproduced byte-for-byte").

| item                    | what was open                                             | outcome                                                                                     |
|-------------------------|-----------------------------------------------------------|---------------------------------------------------------------------------------------------|
| N-0b145a01              | 125 panel bytes named `f<offset>`                         | 63 named, 61 reserved (no reader in v5..v10), 1 blocked (0x80 +4)                           |
| N-583fb77c              | DSP slot byte packing of 16 effects                       | established for every effect; one macro per effect spells each record with named parameters |
| N-10dad9c5 / N-b64487fc | envelope pair order, LFO byte captions, controller groups | envelopes, LFOs and the seven controller groups named from the SOUND EDIT pages             |

Probes: `probes/README.md`.  Label renames (not applied): `rename_panel.sed`.

## 1. Panel records (N-0b145a01)

### The companion records 0xC0..0xD7 and 0x49 hold the "last sound per group" memory

`PanelTlv_ResolvePartCompanions` (audio/tonegen_fileio_handlers.s) builds a 5-byte frame {+0 offset, +1 value, +2 part,
+3 sound, +4 bank} and calls `SndParam_ResolveVoiceEntry`, which for a part <= 0x1F calls `SndParam_FetchOscTableEntry`
-> `ApplyProgramChangeAs_LoadDRAM2`: the bank map of SoundData_CategoryDesc slot +0x10 turns (bank, program) into
(category, slot), so frame +0 = the SOUND GROUP (0..17, SOUND_CATEGORY_NAMES) and +1 = the slot in it (0..39); for
part 0x48 (the style) `AccStyle_LookupPanelRhythm` gives (rhythm group, number).  The routine then stores
`companion[group] = slot`.  The same store is `MIDI_DistributeParamToChannels` (A = part, C = group, E = slot; called by
`MainVariSet` on EVT_VARI_WRITE and by `Sound_SetSelection`), and the reader is `VoiceData_DistributeToChannels`
(A = part, C = group -> L = companion[group]), called by `PanelButton_SoundGroup` and `PanelButton_RhythmGroup` (part 72):
pressing a group button recalls the sound / style last chosen in that group.  So each byte of a companion record is
one group's slot:

| record                                     | byte k                                                                                                                                                                                                                              |
|--------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0xC0 + part (parts 0x00..0x14, 0x17), 18 B | SOUND GROUP k: PIANO, GUITAR, STRINGS & VOCAL, BRASS, FLUTE, SAX & REED, MALLET & ORCH PERC, WORLD PERC, ORGAN & ACCORDION, ORCHESTRAL PAD, SYNTH, BASS, DIGITAL DRAWBAR, ACCORDION REG., GM SPECIAL, DRUM KITS, MEMORY A, MEMORY B |
| 0x49 (style record 0x48's), 16 B           | RHYTHM GROUP k: STANDARD ROCK, R & ROLL & BLUES, POP & BALLAD, FUNK & FUSION, SOUL & MODERN DANCE, BIG BAND & SWING, JAZZ COMBO, U.S. TRAD, COUNTRY, LATIN, MARCH & WALTZ, PARTY TIME, SHOWTIME & TRAD DANCE, WORLD, CUSTOM, MEMORY |

Group order: SOUND_CATEGORY_NAMES (audio/sound_data.s); rhythm groups from PanelButton_RhythmGroupCodes_LeftSeg0/1/6
(ui_widgets/extension_device_screens.s, with the button captions of technics-docs control-panel-protocol.md).
Measured over the floppies (`probes/panel_byte_values.py --tags c0,...`): 1,386 companion records, every byte <= 39
(SYNTH reaches 39), DIGITAL DRAWBAR never non-zero; 0x49 bytes <= 59 (CUSTOM).  The load rule zeroes all of them
(PanelTlv_Rules_TagC0 / _Tag49 RULE_ZERO), then `PanelTlv_ResolvePartCompanions` re-derives the current sound's byte:
the saved bytes are the RAM state at save time.  The generator now makes one kind of the 22 companion tags,
`ptlv_part_vari` (arguments `vari_piano` .. `vari_memory_b`), and `ptlv_style_vari` for 0x49; this also names the 17
bytes per record that were `reserved_<off>` (they are written, by the same store, for any group).

### Other names

- **The SndParam descriptor pattern dropped 11 descriptors**: `floppy/kn5000/panel_fields.py` matched `/* [n] ADDR NAME */`
  with a single name, so the 11 descriptors whose comment lists several labels ("NakaInst_Param_Term00,
  NakaInst_Param_Field88(+1)") were lost, among them the MSP bank (0x28800, tag 0x72 +6), MSP volume / reverb and the
  0x93 +4 key.  Fixed; 951 + 23 = 974 descriptors are read.
- `KEY_NAMES` names two placeholder descriptors from their readers: key 0x28800 = `msp_bank` (PanelButton_MspNumber
  turns MSP 1-6 into pedal functions when SndParam_LookupReadOnly(0x28800) is 17 or 18; VwVariBox_Init / _Match);
  key 0x28403 (tag 0x93 +4, 0..12, default 2) = `composer_bend_range` (CmpBndRng returns the key; DrumVoice_Handler7, a
  Composer RECORD SETTING row, steps PANEL_TOUCH+4 0..12).
- Tag 0x71 +0 = `pmemout_l_flags`: PmemOutLGridCheck sets bit 1 of it in a panel memory (0x1ED400 + 960 n);
  PanelMemory_Recall calls BitMapOut_DispatchIOChanges when bit 1 of the live copy is set (0 in every saved panel).
- Tag 0x98 +12 = `reserved_12`: its 25 "references" are 0xFDA2 = PANEL_PMEM_SETTINGS+12 used as the END of the
  0xF980..0xFDA1 block copies (BitMapOut_ComputeRegionDelta, ToneGen_FileIO_SaveAndSync), not accesses of the byte.
- Bytes with no descriptor and no reference that the load rule overwrites with a constant (`RULE_STORE`, tag 0x93
  +9..+24 = 64) are `reserved_<off>` like the zeroed ones.

### The 63 bytes that were still `f<offset>` (second pass)

`probes/panel_f_readers.py` lists every v5..v10 instruction that names each of them, by an absolute operand or through
a base register.  51 have no hit at all; the others' hits are the record-pointer tables, the record's base load and the
PANEL MEMORY recall copies (bitmap_out_routines.s), which move whole records and read no value.  So:

| record           | bytes                    | verdict                                                                                                                                                                                                                                  |
|------------------|--------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0x60             | +0                       | `reserved_0`: pointer tables, base load, recall copy only; 0 in every save                                                                                                                                                               |
| 0x68             | +0..+9                   | `reserved_<off>`: pointer tables and a base load only; 0 in every save                                                                                                                                                                   |
| 0x72 (MSP)       | +0, +1, +4, +5           | `reserved_<off>`: no reader; BitMapOut_RestoreFields clears bit 7 of +0 / +1; +0 (range 0..15) is 1 or 13 in 77 saves                                                                                                                    |
| 0x80 (MIDI)      | +4                       | **BLOCKED** (`f4` kept): ToneGen_FileIO_SaveAndSync keeps it across a demo preset load and the MIDI preset banks store 0 in it, but no instruction tests it; a MIDI capture from an instrument with the byte set would show what it does |
| 0x80 (MIDI)      | +5                       | `reserved_5`: no reader; the MIDI preset banks store its low 6 bits                                                                                                                                                                      |
| 0x90             | +1                       | `conductor_flags`: read with +0 as the word 0x9163, bit 1 by AudioInit_ProcessModeChange / AudioMode_ConfigExternal_MergeFlags, sent by MIDI_WriteResetSequence [INFERENCE: what bit 1 selects not traced]                               |
| 0x90             | +2                       | `reserved_2`: recall copies only; 0x67 in every save                                                                                                                                                                                     |
| 0x91 (GM)        | +2                       | `reserved_2`: no reader                                                                                                                                                                                                                  |
| 0x93             | +1..+3, +7, +8, +25..+33 | `reserved_<off>`: no reader (the load rule validates +1..+3, +7, +8); one value in all 63 saves                                                                                                                                          |
| 0x98             | +10                      | `reserved_10`: no reader; ranged 0..99 (default 90) by the load rule                                                                                                                                                                     |
| 0x99 (foot ctrl) | +16..+26                 | `reserved_<off>`: no reader; 82 01 02 81 00 10 11 12 13 00 00 in all 4,328 saves                                                                                                                                                         |
| 0x9A             | +0, +4..+19              | `reserved_<off>`: pointer tables only (+0) or no reference                                                                                                                                                                               |

Of the 125: 62 named in the first pass, `conductor_flags` in this one, 61 `reserved_<off>`, 1 blocked.  The verdicts and
their evidence are the `VERDICT` table of `floppy/kn5000/panel_fields.py`, so the generated macro comments carry them.

## 2. DSP slot packing (N-583fb77c)

The reader of a DSP slot record (tags 0x61 DSP EFFECT, 0x63 DIGITAL REVERB, 0x64 EQUALIZER, 0x65 ACOUSTIC ILLUSION,
0x66 MIC REVERB; and the 24-byte default blocks of DspFxSettingsPtrTable) is `DSPCfg_ReadViaTableLookup` ->
`DSPCfg_ReadMultiField` -> `DSPCfg_ReadField` (audio/dsp_config_sysex.s).  Byte +0 is the effect number e;
`DspFxRecListPtrTable[e]` is the effect's parameter-write record list, one record per parameter; ReadMultiField walks
it with a pointer into the payload, and ReadField returns each parameter's value and the WIDTH by which the pointer
moves.  The op letter (record +2) and the operand nibbles of record +4 (`DSPCfg_ExtractFieldSingle` /
`DSPCfg_ExtractFieldPair`) decide, with W = payload[ptr] << 8 | payload[ptr + 1]:

| op                     | value                  | width                             |
|------------------------|------------------------|-----------------------------------|
| `v`, sub 0x10, lo 2    | (W >> 8) & 0x3F        | 1                                 |
| `v`, sub 0x10, lo != 2 | W & 0x3F               | 2                                 |
| `v`, other sub         | (W >> 6) & 0x1F        | 0 (shares the word with the next) |
| `p`, sub 0x20          | W & 0x3F               | 2                                 |
| `p`, sub 0x10          | (W >> 11) & 0x1F       | 0                                 |
| `p`, other sub         | (W >> 6) & 0x1F        | 2 if lo == 1, else 0              |
| `h`                    | payload[ptr], unsigned | 1                                 |
| `g`, `d`               | W (big-endian word)    | 2                                 |
| any other letter       | payload[ptr], signed   | 1                                 |

`DSPCfg_WriteParam` writes with the same cases and `DSPCfg_RecordFieldToParamId` / `DSPCfg_FindParamAtRecordOffset`
map a changed payload byte back to a parameter through the same walk (payload bytes 1..16 only).  So the reverbs'
PRE DELAY is a big-endian word although its maximum is 200 (op `g`), HIGH DAMP GAIN is the low 6 bits of a byte (`v`),
the PARAMETRIC EQ bands are 16-bit words {Q 15:11, FC 10:6, G 5:0}, the GEQ / ROOM pairs {FC 10:6, G 5:0}.
`probes/dsp_slot_packing.py` decodes every saved record with this layout: all 23,434 typed DSP slot records of the
floppies are in range, for every effect (the old byte-per-parameter reading fitted 28 of 44 effects).  The "40 odd
CHORUS records" of the 2026-10-31 count came from a raw byte scan of the extracted files, not from typed records:
every one of the 1,640 typed CHORUS records decodes [INFERENCE: the scan's extra hits are byte patterns outside the
panel blocks].  NO OPERATION (effect 0, 7 records) has no record list, so none of its bytes is read.

`floppy/kn5000/panel_fields.py` now writes one macro per effect into `include/kn5000_panel.inc`
(`ptlv_dsp20_concert_reverb_1 tag, reverb_time, pre_delay, high_damp_gain, er_level, volume, tail:vararg`, ...), each
argument a parameter value, packed words composed by the macro; `tail` is the bytes after the effect's last parameter
up to +23, which no reader reads (they hold the previous effect's bytes; +22 = 99 in most records, the default blocks'
constant).  Records with a set bit outside every field (5 EXCITER records) and NO OPERATION records keep the generic
`ptlv_dsp_slot` line, with a comment saying why.  The spec `notes/floppy-kn5000-2026-10-29/specs/dsp_effect_params.json`
(regenerated by the probe) carries, per parameter, op, payload offset, width, shift and mask.

## 3. Sound record: envelope pairs, LFO bytes (N-10dad9c5 = N-b64487fc)

Each SOUND EDIT page column handler (`Se<Page>_OnColumn<n>`, audio/semenu_routines.s and display/scoop_editor_data.s)
edits one value of the page cache at RAM 0x660 + i (the byte that the page's bound field record prints under its
caption, `SePitFilEnv1_*Field`, `SeAmpEnv1_*Field`, `SeLfo1_*Field`, ...) and sends it through
`SeMenu_StepParamFieldAndSend` -> `SeMenu_RegisterElement_Extended` as {0x88, master, ELEMENT, 1, value, mask}; the
object flags are the tone (part 1..4) for a per-tone value and 0 for a common value.  The element of a per-tone value
is its offset in the tone's 81-byte block (record +0x66 + 0x51 p), of a common value its record offset: PITCH ENV
elements 7..22, AMPLITUDE ENV 39..53 and FILTER ENV 61..76 land exactly on the three envelope structures the record's
readers place there, and each element's edit range equals that offset's clamp range (0..100 for the times, -50..50 for
the levels).  [INFERENCE: the sub-CPU handler of the element message was not traced; the evidence is that agreement.]
`probes/se_page_names.py --table` prints the full map (59 values).  The result per tone block:

| block offset | PITCH ENV                | block offset | AMPLITUDE ENV                | block offset | FILTER ENV               |
|--------------|--------------------------|--------------|------------------------------|--------------|--------------------------|
| +0x07        | TOTAL DEPTH              | +0x27        | ATK                          | +0x3D        | CUTOFF ADJUST            |
| +0x08        | START PITCH              | +0x28        | PEAK                         | +0x3E        | START POINT              |
| +0x09        | ATK                      | +0x29        | DECAY1                       | +0x3F        | ATK                      |
| +0x0A        | PEAK                     | +0x2A        | SUST1                        | +0x40        | PEAK                     |
| +0x0B        | DECAY1                   | +0x2B        | DECAY2                       | +0x41        | DECAY1                   |
| +0x0C        | SUST1                    | +0x2C        | SUST2                        | +0x42        | SUST1                    |
| +0x0D        | DECAY2                   | +0x2D        | RELEASE                      | +0x43        | DECAY2                   |
| +0x0E        | SUST2                    | +0x2E        | TOUCH ATTACK                 | +0x44        | SUST2                    |
| +0x0F        | RELEASE                  | +0x2F        | TOUCH DECAY                  | +0x45        | RELEASE                  |
| +0x10        | STOP PITCH               | +0x30        | KEY FOLLOW RANGE middle note | +0x46        | STOP POINT               |
| +0x11        | TOUCH ADR-TIME           | +0x31        | KEY FOLLOW RANGE low note    | +0x47        | TOUCH ADR-TIME           |
| +0x12        | TOUCH DEPTH              | +0x32        | KEY FOLLOW RANGE high note   | +0x48        | TOUCH DEPTH              |
| +0x13        | KEY FOLLOW CENTER (note) | +0x33        | KEY FOLLOW ATK               | +0x49        | KEY FOLLOW CENTER (note) |
| +0x14        | KEY FOLLOW ATTACK        | +0x34        | KEY FOLLOW DECAY             | +0x4A        | KEY FOLLOW ATTACK        |
| +0x15        | KEY FOLLOW DECAY         | +0x35        | KEY FOLLOW RELEASE           | +0x4B        | KEY FOLLOW DECAY         |
| +0x16        | KEY FOLLOW RELEASE       |              |                              | +0x4C        | KEY FOLLOW RELEASE       |

**Pair order: time first, then level** (ATK, PEAK; DECAY1, SUST1; ...), for all three envelopes.  The spec's
`env1_segN_target / _rate` had the AMPLITUDE pairs the other way round, and `env1_level` (+0x2D) is the RELEASE time.

**The sub-CPU disagreement** (`Voice_Level_ComputeTriplet` reads block +0x0A / +0x0C as signed levels, the type-1/2
path `Voice_Calc_LevelPair_FixedAtk` indexes `Voice_EnvelopeRate_Table` with paramA +0x0A / +0x0C): both are right,
for different records.  In a sound's tone block +0x0A / +0x0C are the PITCH envelope's PEAK and SUST1 (signed levels,
-50..50, the page's edit range), as ComputeTriplet reads them.  The type-1/2 path runs for drum-kit instruments, whose
paramA is a kit-instrument record of another layout: the AMPLITUDE ENV1 page in drum-kit mode (SEMENU_PART_MODE 1)
edits that record at +8 (column 1, ATK), +9, +10, +11 (columns 2-4) and +14 (column 8, -50..50)
(`SeAmpEnv1_OnColumn1..4, 8`: element 16 + 21 (n - 1) + offset), so the rate-table reading of its +0x0A / +0x0C says
nothing about the tone block [INFERENCE: the kit record's captions in drum-kit mode were not mapped beyond column 1].
The two layouts never meet: as the sub-CPU note says, the allocation paths bind different record kinds to slot +0x17.

**LFO bytes** (common block, 12 entries of 4 bytes: PITCH LFO1-4 at +0x2B, AMPLITUDE LFO1-4 at +0x3B, FILTER LFO1-4
at +0x4B; `SeMenu_TransferPartValues` gives the element 0x2B / 0x3B / 0x4B + 4 (n - 1)): entry +0 DEPTH (0..127),
+1 SPEED (0..127), +2 TOUCH (bits 5:0, 0..50) and KEYSYNC (bit 7), +3 WAVE (bits 7:6: SIN TRI SQR SAW) and DELAY
(bits 4:0, 0..30).  Each tone selects its LFOs in three switch bytes, sent by `SeMenu_CyclePartLfoState` with the
element from `SeMenu_GetLfoPartSwitchParamId`: block +0x06 PITCH, +0x26 AMPLITUDE, +0x38 FILTER; bit 5 = on, bits 7:6 =
the LFO number - 1, bit 4 = the +/- sign (SeLfo1_Part1SignField).  (+0x26 and +0x38 were `unread_*`: the sub-CPU
probe found no reader; +0x06 bits 2:0 are also read by the sub-CPU's Voice_Pitch_ApplyPortamento.)

`specs/tm_sound_record.json` is renamed by `probes/se_page_names.py --apply` (the generator's inputs are not
committed, so the spec is patched; `gen_tm_spec.py` imports the same table, so a regeneration gives the same names).
The two- and three-byte fields the pages show as separate values (+0x14, +0x2E, +0x30, +0x33, +0x4A) are split into one
field per byte.

**Controller groups** (+0x14..+0x28, seven groups of 3 bytes).  The CONTROLLER page (TT_SECTR2) is common (object
flags 0).  `UpdSeSel_DetailedUpdate_Helper5` requests the six FUNCTION bytes 0x18 + 3 k (k = 0..5) into page cache
1..6 (`SeCtr2_FunctionNameFields` shows 1, 2, 5 and 6) and, for the selection s (RAM 0x695, `SeCtr2_SetSelection`;
side row 2 picks 1 / 2, side row 3 picks 5 / 6), the group base g from `UpdSeSel_DetailedUpdate_SetDisplayState_Helper2`
(1 -> 0x17, 2 -> 0x1A, 5 -> 0x23, 6 -> 0x26) into cache 13, g + 2 into cache 11 and g into cache 12.  The handlers then
send: FUNCTION (`SeMenu_ApplyPartEdit_AltStore_Join21`, columns 2 / 3, 0..27) as element g + 1; DEPTH
(`SeCtr2_StepDepth`, column 4, 0..127) as g + 2; the 1ST..4TH switches (`SeCtr2_StepPartField`, columns 5..8, two bits
per tone stepped 0 OFF -> 1 ON -> 3 INV) as g.  So every group is {tone switches, FUNCTION, DEPTH}:

| record offset  | group                         | +0 `ctrl_tone_switches`            | +1 `ctrl_function`                                    | +2 `ctrl_depth` |
|----------------|-------------------------------|------------------------------------|-------------------------------------------------------|-----------------|
| +0x14          | 0: not on the CONTROLLER page | tone 1 bits 1:0 .. tone 4 bits 7:6 | 0x81 in every record: bit 7 + 1 = PITCH BEND          | 0..127          |
| +0x17 .. +0x26 | 1..6: FUNCTION selection 1..6 | same                               | bits 6:0 index SeValText_CtrlDestinations; bit 7 flag | 0..127          |

Group 0 is the fixed PITCH BEND assignment (sub-CPU `Voice_PitchBend_BranchA` takes its address).  The page offers
selections 1, 2 in its first row and 5, 6 in its second; no side row selects 3 or 4, although Helper5 still requests
their FUNCTION bytes.  Which physical controller each row is was not read: the rows carry icons (op-23 styles 0x60 and
0x39 in SeCtr2_PageFrame) that were not rendered; that is the only part left unnamed.  CONTROLLER page 2 (TT_SECTR3,
SeCtr3_OnColumn3 / 6) edits record +0x10 bit 4 (SUSTAIN PEDAL MODE) and bit 5 (GLIDE).

## Names in the firmware (not applied; `rename_panel.sed`)

| old                                                      | new                                                          | why                                                |
|----------------------------------------------------------|--------------------------------------------------------------|----------------------------------------------------|
| `MIDI_DistributeParamToChannels`                         | `PanelVari_SetGroupSlot`                                     | stores companion[group] = slot                     |
| `VoiceData_DistributeToChannels` (and its 5 locals)      | `PanelVari_GetGroupSlot`                                     | returns companion[group]                           |
| `VoiceData_RamBlockPtrs`                                 | `PanelVari_PartRecordPtrs`                                   | the companion records of parts 0..15               |
| `SeMenu_TransferPartValues`                              | `SeLfo_GetEntryElement`                                      | the record offset of LFO n's entry                 |
| `SeMenu_TransferPartValues_EndData`                      | `SeLfo_GetSelectedLfo`                                       | the page's selected LFO number, forced into 1..4   |
| `UpdSeSel_DetailedUpdate_SetDisplayState_Helper`         | `SeCtr2_GetSelection`                                        | the CONTROLLER page's selection, clamped 1..6      |
| `UpdSeSel_DetailedUpdate_SetDisplayState_Helper2`        | `SeCtr2_GetGroupBase`                                        | selection -> controller-group base 0x17 .. 0x26    |
| `UpdSeSel_DetailedUpdate_SetDisplayState_Helper3`        | `SeCtr2_GetKitGroupBase`                                     | the drum-kit twin                                  |
| `UpdSeSel_DetailedUpdate_Helper5` / `_Helper6` (+ loops) | `SeCtr2_RequestGroupValues` / `SeCtr2_RequestKitGroupValues` | request the page's FUNCTION / DEPTH / switch bytes |

## Website page draft (technics-docs, "KN5000 disk files" -- panel records)

> **Companion records.** Each part record 0x00..0x14 and 0x17 has a companion record (tag 0xC0 + part, 18 bytes), and
> the style record 0x48 has one (tag 0x49, 16 bytes). Byte k of a companion is the sound (0..39) the part last had in
> SOUND GROUP k (PIANO, GUITAR, ..., MEMORY A, MEMORY B), or the style last chosen in RHYTHM GROUP k (STANDARD ROCK ..
> MEMORY): when a group button is pressed, the instrument recalls that byte. The loader zeroes the records and then
> re-derives the byte of the current sound, so the saved values are the panel's memory at save time.

## Website page draft (technics-docs, "Panel parameter keys" -- DSP slot records)

> **DSP slot records** (tags 0x61 DSP EFFECT, 0x63 DIGITAL REVERB, 0x64 EQUALIZER, 0x65 ACOUSTIC ILLUSION, 0x66 MIC
> REVERB) hold the effect number and then its parameters in the order of the effect's parameter list, but not one byte
> each: the firmware's per-effect write list gives each parameter a kind. A delay time or a pre-delay is a big-endian
> 16-bit word (even PRE DELAY, 0..200); a damping gain is the low 6 bits of a byte; an equalizer band is one 16-bit
> word holding Q (bits 15-11), frequency (10-6) and gain (5-0); the GEQ and the ROOM / KARAOKE / BATH ROOM / STAGE
> illusions pair frequency (10-6) and gain (5-0) the same way; every other parameter is a byte, feedback and resonance
> signed. With this layout every saved DSP slot record of the 14 factory diskettes decodes inside its parameter
> ranges. The bytes after the last parameter are not read.

## Website page draft (technics-docs, "KN5000 disk files" -- .TM sound records)

> **Envelopes, LFOs and controllers of a sound.** Each of a sound's tones (81-byte blocks at +0x66) has three envelopes, named as
> the SOUND EDIT pages show them. PITCH: TOTAL DEPTH, START PITCH, then ATK, PEAK, DECAY1, SUST1, DECAY2, SUST2,
> RELEASE, STOP PITCH (+0x07..+0x10), then TOUCH ADR-TIME, TOUCH DEPTH and KEY FOLLOW CENTER / ATTACK / DECAY /
> RELEASE. AMPLITUDE: ATK, PEAK, DECAY1, SUST1, DECAY2, SUST2, RELEASE (+0x27..+0x2D), TOUCH ATTACK / DECAY, the KEY
> FOLLOW RANGE notes (middle, low, high) and KEY FOLLOW ATK / DECAY / RELEASE. FILTER: as PITCH, 0x36 bytes later, with
> CUTOFF ADJUST, START POINT and STOP POINT. Every envelope stores a time and then a level. The sound has twelve
> LFOs (PITCH, AMPLITUDE, FILTER, four each, at +0x2B), each DEPTH, SPEED, TOUCH + KEYSYNC, WAVE + DELAY; each tone
> chooses one LFO of each kind (and its sign) in three switch bytes. Seven controller assignments at +0x14 each hold
> the tones it acts on (OFF / ON / INV, two bits per tone), its FUNCTION (PITCH BEND, AMP ENV SUST, FILTER CUTOFF, an
> LFO depth or speed, ...) and a DEPTH; the first is the fixed PITCH BEND assignment.
