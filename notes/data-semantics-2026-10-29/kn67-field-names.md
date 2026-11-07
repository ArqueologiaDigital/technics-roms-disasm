# Lane kn67-field-names (2026-10-29): naming the KN6000 / KN7000 record fields

The SX-KN6000 / SX-KN7000 floppy, custom-data and table sources were already byte-exact and typed, but
many fields carried offset names (`p<hex>`, `x<hex>`, `f<off>`, `s<hex>`, `m<hex>`). This lane traced the
code behind them and renamed the fields in the shared includes, so every tree that uses them changed at
once:

- `kn7000/src/include/panel_memory.inc`: `PM_*` (the one-touch record) by hand, `PMR_*` (the full panel
  record) through its generator `floppy/tools/kd/gen_panel_macros.py`;
- `kn7000/src/include/voice_record.inc`: `VOICE_*`, `SOUND_HEAD`, `SOUND_MOD`;
- `floppy/tools/kn_song.inc` and `floppy/tools/kd/kn_sqt.py`: the song events and the song record;
- the table flash's 'JK' voice archive (`kn7000/tools/gen_table_voices.py`): its tone heads, units, voice
  sub-records, elements and 0x2C8 records are now spelled with the `voice_record.inc` macros.

Probes: `kn7000/notes/kn67-field-names-probes/` (README there).

## 1. The panel record is the live state; the parameter-id trie names its bytes

**Recall.** Library `func_4C021F33` (KN7000 lib 0x4C021F33) takes a 1-based memory number, computes the
record `0x84000824 + (n-1)/8 * 0x3A90 + 0x10 + (n-1)%8 * 0x750`, copies it over **0x84000020** (`memcpy`,
0x750 bytes) and calls `func_4C01F98B`. `func_4C021EEE` is the store: the same copy the other way.
`func_4C01F98B` copies the eight 4-byte entries at record +0xF4 into the work-RAM part records
0x500D28C2 + i*0x4A, at offsets +3, +5, +0x3A, +0x3B. So a PANEL MEMORY record (and a `.PMT` memory, an
`.LSW` panel, a song's settings bank) is an image of the live panel state at 0x84000020.

**The trie.** Every live parameter is read and written through its 24-bit id: `GetM3Em` / `PutM3Em`
look the id up in `ResourceIdTrie` (KN7000 0x4858B424, walked by lib `func_4C01BB1A`; KN6000 0x4C1935DC,
walker 0x4C02CA6A). A leaf is `{u32 id, u16 type, u16 kind, u16 min, u16 max, u8 block, u8 offset, u8
mask, u8 shift}`. For type 0, `func_4C015602` dispatches on `kind` and reads through
`func_4C01F153(block, offset, mask)`; writes go through `func_4C01F200`, which then calls
`func_4C01F8F4` (the accompaniment-entry mirror). The block is a pointer from table 0x4858D44C
(`func_4C021040`; KN6000 0x4C195520), and **block n is the payload of the panel record's tag n**:
tags 0x00-0x12, 0x1B, 0x1C, 0x1F the parts, 0x40 the name, 0x41-0x4D the panel sections, 0x50-0x52 and
0x60-0x68 past the 0x750-byte record. Part-scoped ids take the block from the id's top byte.

**Id classes.** Region-1 `func_48440533` builds a MIDI-style id as `(status & 0xF0) << 16 | controller`,
so 0xB0nnnn is control change nn and 0xC00000 program change; 0xB080nn is RPN nn ([INFERENCE]: the
ranges are 0..12 for RPN 0, 40..88 for RPN 2). Names for the other ids come from their callers
(`m3em_callers.py`: 1,303 literal-id calls, 213 ids), from the GUI grids of lane gui-kn7000 (branch
`data/gui-kn7000`: `fixedcol` / `fixedrow` captions and `func=` handlers), and from the song-event
trace (`kn7000/notes/presentation-control-probes/song-records.md`).

**The tag -> part map.** The MIDI part grid's row table 0x48626C14, read by `MidiPartGrid` (0x484D0..),
names the parts: 0x00-0x0F PART1-16, 0x10 RIGHT1, 0x11 RIGHT2, 0x12 LEFT, 0x1B CHORD, 0x13-0x1A ACCOMP1-5,
BASS, DRUMS1, DRUMS2 (whose records live in work RAM and keep only the 4-byte entries in the panel
record). The song-track names (0x486773D8) add 0x1F B.PEDAL.

### What is named (panel record)

| record             | named fields (parameter id: evidence)                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|--------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| part (72 B)        | sound triple (0xC00000, kind 6 reads 3 bytes), volume (CC7), effect depths with on/off bits (CC91 reverb, CC93 chorus + 0x20005D CHOSELTitleFunc, CC92 + 0x20005C MULSELTitleFunc, CC95 + 0x20005F DSPSELTitleFunc), portamento (CC5 / CC65), CC71-78, CC80-83, pan (CC10), RPN 0/1/2/5, drawbars 0x200090-98, scale tuning 0x2000C0-CB, MIDI CHANNEL / OCTAVE / LOCAL (0x204001 / 0x204004 / 0x204000, MidiPartGrid "PART\|CHANNEL\|OCTAVE\|LOCAL"), tremulant (0x2000A2, AcTabTremulantProc) |
| entries 0x13-0x1A  | volume, `tg_bits`, `midi_octave_local`, `midi_channel` (the RAM part's bytes +3, +5, +0x3A, +0x3B)                                                                                                                                                                                                                                                                                                                                                                                             |
| 0x41               | `r_octave` (0x008038, AcRightOctProc)                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 0x42               | rhythm (0x00C000, 24-bit), `variation` (0x00C004, VARIATION 1-4), tempo (0x000004, 40..300, two bytes)                                                                                                                                                                                                                                                                                                                                                                                         |
| 0x43               | `control_channel` (0x00F101, the grid's CONTROL row)                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| 0x44               | split mode / tremolo, split point, transpose, TECHNI-CHORD part and type, APC reverb depths (KN7000, ApcRevFunc)                                                                                                                                                                                                                                                                                                                                                                               |
| 0x46               | `pad_bank` (0x00E005, AcPadBankProc)                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| 0x48               | the foot-switch / foot-controller / expression-pedal functions (FSWAssGridCheck reads 0x004002-7 then 0x004000 in the grid's row order)                                                                                                                                                                                                                                                                                                                                                        |
| 0x4C               | effect switches, the effect ids 0x00A000-0x00A500, the DSP group part keys 0x00B014-0x00B054 (SndUnitRecApply)                                                                                                                                                                                                                                                                                                                                                                                 |
| 0x4D               | the 5-band EQ: gains (AcGainBoxProc reads 0x00A311 / 14 / 17 / 1A / 1C), frequencies and Q ([INFERENCE] from the ranges)                                                                                                                                                                                                                                                                                                                                                                       |
| 0x52               | `pmem_number` (0x000080), DSP unit numbers (0x00B010-50), MONO 1 / 2 part (SpPartMono)                                                                                                                                                                                                                                                                                                                                                                                                         |
| one-touch (`PM_*`) | the same names for the copied bytes; the fourth part is tag 0x03 (PART 4) on both models, not an unnamed part                                                                                                                                                                                                                                                                                                                                                                                  |

**What keeps a placeholder name, and why.**

- `m<id>` (about 60 fields): the parameter id is known (so the field is grep-able in the probes'
  output and in the code), but no caller or screen caption says what it means: for example the part's
  `ctl_bits` / `tg_bits` bits 0x204080-0x204088 (the library sends them to the tone generator as TG
  codes 0x85, 0x93, 0x84 at lib 0x4C02581A), the second sound triple 0x204020 at part +0x3C and its four
  companions, the MIDI filter bits of tag 0x47 (0x2000-0x2099: the MIDI control grid builds its ids at
  run time, so the literal-call probe does not see them), the vocalist and mic bytes of 0x4A / 0x4B.
- `p<hex>` / `x<hex>`: no parameter record covers the byte at all (part +0x06..+0x0A, +0x21, +0x2B,
  +0x44..+0x47; most of tags 0x41, 0x48, 0x60-0x68). Nothing in the parameter layer reads them; a
  direct reader elsewhere may exist.

KN6000: the two type-0 maps (`m3em_param_map.py --table`, both models, `diff`) agree on every part
field except the KN7000-only ones (scale bits 0x2000B0-BF, tremulant, APC reverb) and some ranges; the
KN6000 has more foot-controller functions (0x004008-0x004041 in tag 0x48), which keep `x<hex>` names.

## 2. The song events and the song record

The event grammar was already traced (`song-records.md`, section 2) but `kn_sqt.py` still used
measured lengths. It now uses the firmware's per-status table 0x485B9328 (read by `func_4845BC5B`; the
player tick 0x484595F0 steps each track with 0x4845979E, which reads an event at 0x48459C98). The
table agrees with the measured lengths on every status the 27 disks hold; it adds 0x84 (bar), 0x8A
(PIC), 0xA2 / 0xA3, 0xF4, and makes 0xB1-0xBF non-events. The macros' parameters are the event layouts
(`sq_cc` {part, cc, value}; `sq_a` {part, flags, id big-endian, value}; `sq_note` {key, velocity, u16
duration}, n = 8 for a note recorded from MIDI IN). All 422 tracks still type; no generated source
changed for this.

**The song record.** `func_4C01F153`, in mode bit 0 (the GetM3Sqf / PutM3Sqf "Sqf" bank), reads a
parameter at `Rec8E0Field120Ptr(0) + (block - 0x84000000)`. So song record +0x120.. is an image of
backup SRAM 0x84000000 + (offset - 0x120): +0x140 is the song's panel memory (the image of the live
record), and the tail after it is block 0x52 -- 46 bytes on the KN6000 (the record's end), 40 on the
KN7000, followed by the images of blocks 0x50, 0x51 and the start of 0x60, whose tag / length bytes the
song copy does not keep. All 605 song records now type that block as `PMR_52_40` / `PMR_52_46`.
+0x07..+0xCF and +0x100..+0x11F stay rows: no reader was traced.

## 3. The sound records (`voice_record.inc`) and the JK archive

**The desc2 puzzle** of `kn7000/notes/table-semantics-2026-10-29.md`: the `Tg*` routines read a "desc2" at
librec +0x3C with offsets up to +0x4C, which does not fit a 0x1C sub-record. On the melodic path the
staging `TgElemStageFresh` (lib 0x4C034927) stores `*(tone block +0x60 + unit*0x34)` there: the 0x7A
unit, the same pointer `TgPartAuxRecBuild` copies into a SOUND EDIT record. Only the table-tone staging
(0x4C035EAA) stores a sub-record at +0x3C. So the desc2 readers name the 0x7A unit's fields: level
offset and velocity sense, the pitch EG (+0x0B..+0x17), effect sends and the glide bit (+0x18 / +0x19),
key follow, the velocity and key fade zones (+0x20..+0x27), the amp EG rates, breakpoints and
sensitivities (+0x28..+0x36), CUTOFF ADJUST and the filter EG (+0x3E..+0x4C). `SOUND_HEAD` names the
tone class, the modulation source, the tone type and the EG flag; `VOICE_SUB` the element reference
(+1..+3, which the table-tone staging passes to `TgPartElemProgramApplyIdxSel`); `VOICE_ELEM` the three
velocity split points and six 5-byte layers whose first bytes go to `VoiceParamRecFetchBanked`.

A tone record (0x54-byte head + units) and a SOUND EDIT record's first 0x23C bytes are the same layout
(`TgPartAuxRecBuild` copies one onto the other), so the archive's `tone_head` / `tone_type` macros are
gone: the archive now writes `SOUND_HEAD`, `SOUND_MOD`, `VOICE_HEAD_TAIL`, `VOICE_SUB` and `VOICE_ELEM`,
including its 40 0x2C8 records and its 87-row element table. Tables 84, 83 and 80 rebuild
byte-identically.

Not named: the 0x7A unit's +0x04..+0x06 (SOUND EDIT reads and writes them, `TgPartAuxMod04/05/06Get/Set`,
but their meaning is not traced) and the bytes no traced routine reads (+0x00..+0x03, +0x07, +0x08, +0x13, +0x1C..+0x1F, +0x29,
+0x2B, +0x2D, +0x37..+0x3D, +0x48, +0x49, +0x4B, +0x4D..+0x79), the tone head's +0x11, +0x13..+0x43,
+0x46..+0x53, the sub-record outside +1..+3, the element's +3, +4 and each layer's last two bytes.
(2026-11-07, lane kn7000-ic21: the sub-record's fields, the layers' last two bytes (level and filter
offsets) and a TABLE head's modulation routings are now named from their readers, observed in MAME;
`kn7000/notes/kn7000-ic21/README.md`.  Still unread: the element's +3 / +4 and three sub-record bytes.)
Which TG (MAIN or SUB) each zone side bit 0x400 / 0x800 selects was not traced either:
`TgVoiceSideSelect` maps class 1/2 kits to 0x400 and 3/4 to 0x800, but the register writer that
consumes the bit was not followed.

## Gates

| gate                                                                   | result                                                              |
|------------------------------------------------------------------------|---------------------------------------------------------------------|
| `make gate-floppy`                                                     | all 50 floppies byte-identical                                      |
| `make -C kn7000 verify verify-sp7001 verify-table80 verify-customdata` | program, tables 84 / 83 / 80, SP7001, 9 CUSTOM banks byte-identical |
| `make -C kn6000 verify-customdata`                                     | `01ctmini.ic18` byte-identical                                      |

(kn7000 overrides as in the lane brief: `ROMSET_DIR`, `CA_MIRROR`, `SOFTLIST_DIR`, `UNIDASM`.)
`data_incbin_census.py` rows are unchanged by this lane (it renames fields; it adds and removes no
`.incbin`): kn7000-table 0 generic, kn7000-customdata 0, kn6000-customdata 0, kn7000-floppy 0,
kn6000-floppy 0.

## Open questions

- The `m<id>` parameters: their set handlers (the trie's type 1-6 records, and lib `func_4C025F02`'s TG
  translation) or the MIDI implementation chart would name them.
- The song record's +0x07..+0xCF and +0x100..+0x11F; the track directory's low flag bits.
- The 0x7A unit's untraced bytes; the TG side bits.
- The KN6000's extra foot-controller functions in tag 0x48.

## Website page draft

> **KN6000 / KN7000 panel memories: what each byte is**
>
> A panel memory on the SX-KN6000 and SX-KN7000 is a copy of the instrument's live panel state: the
> firmware recalls one by copying it over the live record in battery-backed SRAM (0x84000020) and stores
> one by copying the other way. The record is a list of tag/length blocks; each tag is one part (PART 1-16,
> RIGHT 1/2, LEFT, CHORD, the accompaniment parts) or one panel section (rhythm and tempo, split and
> transpose, MIDI, foot controllers, effects, EQ, vocalist).
>
> Every setting has a parameter id, and the firmware finds its byte through a trie of parameter records
> (block, offset, mask). Many ids are MIDI messages: a part's volume is control change 7, its reverb depth
> control change 91, its pitch-bend range RPN 0. That table names most of the record: each part's sound,
> volume, effect depths, sound controllers, pan, tuning, drawbars, scale tuning and MIDI channel / octave /
> local; the rhythm, variation and tempo; the split point, transpose and TECHNI-CHORD; the foot-switch
> functions; the five EQ bands. A song stores the same record as its initial settings.
>
> The sound records follow the tone generator's own readers: a tone is a 0x54-byte head and up to four
> 0x7A-byte element units holding the pitch, amplitude and filter envelopes, key follow and velocity /
> key fades; a SOUND EDIT record is a tone plus four element maps.
