# IC18 past the boot ROM: the "Technics Rhythms" style data

IC18, the 4 MB mask ROM C3CBND000046 at `0x40000000`, holds the boot ROM in its first 64 KB
([`ic18-boot-rom.md`](ic18-boot-rom.md)). The rest is the KN7000's built-in rhythm (style) data.
It is one resource, `"Technics Rhythms"`, at `0x40010000`: a header, a style-ID index, 169 styles
of 20 variations each and 8 count-in patterns. The firmware reads it with LoadU16BE / LoadU24BE.

[`src/ic18/rhythm.s`](../src/ic18/rhythm.s) is the source for that part. It holds the header, the
index, the tables, the macros and the count-in patterns, and includes one file per style,
`src/ic18/styles/<rhythm group>/<style>.s`, plus `src/ic18/old_build.s` for the leftovers past the
last style. Every record and every event is typed, one event per line; nothing is `.incbin`'d
(see [Representation](#representation)). [`src/ic18/ic18.s`](../src/ic18/ic18.s) is `boot.s` plus
`rhythm.s`. `make verify-ic18-full` assembles it and compares all 4 MB with the chip.

All addresses of firmware routines are program 941's (`kn7000_manual.sym`). Figures come from
[`ic18-rhythm-rom-probes/ic18_rhythm_probe.py`](ic18-rhythm-rom-probes/README.md) unless a
routine is named. `[INFERENCE]` marks a reading that no code fixes.

## Provenance and reproduction

The image is the same as the boot ROM's: `technics_romsets/kn7000/c3cbnd000046.ic18` (private).
It is pass 4 of the dumper on Felipe's own instrument, read twice
(`technics_roms/roms/kn7000/real_dump_v1.3_b893/README.md`, "Pass 4"). The Makefile copies it to
`baserom/kn7000_ic18.rom` after checking its SHA-1. That copy is git-ignored.

| what                        | SHA-1                                      |
|-----------------------------|--------------------------------------------|
| the whole chip, 4,194,304 B | `2dc71f5082063cd6b21e4ed16acd67e9d326a79f` |

    make verify-ic18-full            # src/ic18/ic18.s -> build/kn7000_ic18.bin, compared with the chip
    make ic18-rhythm-src             # regenerate src/ic18/rhythm.s (tools/gen_ic18_rhythm_s.py)
    python3 -I notes/ic18-rhythm-rom-probes/ic18_rhythm_probe.py .../c3cbnd000046.ic18 \
        --program baserom/kn7000_program.rom

The generator reads three images. It reads IC18 itself. It reads program 941 for the rhythm
groups (`RhythmGenreNameTable` 0x48735EE4), which give each style its group, its place in the
group and its style-ID. It reads table 84 for the names of the 51 styles that the index sends to
the table ROM. The generator refuses an image whose structure differs from what is described here:
every offset, every tiling and every stream is checked.

## Layout

| file offset         | CPU address  | contents                                        | source label            |
|---------------------|--------------|-------------------------------------------------|-------------------------|
| `0x010000-0x010027` | `0x40010000` | header: signature, checksum, five offsets       | `TechnicsRhythms`       |
| `0x010027-0x010033` | `0x40010027` | count block                                     | `RhythmCountBlock`      |
| `0x010033-0x011033` | `0x40010033` | the style-ID index, 2048 x u16BE                | `RhythmStyleIndex`      |
| `0x011033-0x01122E` | `0x40011033` | the style table, 169 x u24BE                    | `RhythmStyleTable`      |
| `0x01122E-0x011246` | `0x4001122E` | the count-in table, 8 x u24BE                   | `RhythmCountInTable`    |
| `0x011246-0x0113B2` | `0x40011246` | the 8 count-in patterns                         | `CountIn_1Beats` ...    |
| `0x0113B2-0x3FBAD3` | `0x400113B2` | 169 styles, each a record and its 20 variations | `Style_8BtStandard` ... |
| `0x3FBAD3-0x3FFC6D` | `0x403FBAD3` | an older build's leftovers (below)              | `OldBuildStyle_*`       |
| `0x3FFC6D-0x3FFFE8` |              | erased (`0xFF`)                                 |                         |
| `0x3FFFE8-0x3FFFF8` | `0x403FFFE8` | `"jkr_33.ssf"`, NUL-padded                      | `RhythmRomVersion`      |
| `0x3FFFF8-0x3FFFFF` |              | erased                                          |                         |

The count-ins, the styles and their variations tile `0x10000-0x3FBAD3` exactly: 0 bytes
uncovered, 0 covered twice. Each style's 20 variations follow its record with no gap. They come in
the same slot order in all 169 styles: 12, 13, 16, 17, 0-11, 14, 15, 18, 19.

## The header

`StyleResourceWindowProbe` (0x4843D6D7) looks for the signature at five windows. The third is
`0x40010000`. `StyleNameModuleBoot` (0x4843385E) then opens the resource with
`StyleBuiltinNameTableInit` (0x484332F9). Offsets are from the resource start.

| offset  | type  | value                 | read by, and what for                                                                  |
|---------|-------|-----------------------|----------------------------------------------------------------------------------------|
| `+0x00` | ascii | `"Technics Rhythms"`  | `strncmp` with the firmware's string 0x4872980C                                        |
| `+0x10` | u16BE | `0xE2DA`              | `StyleResourceVerify` (0x484338AF): compared with `SumU16BE` (0x484403A5) of the range |
| `+0x12` | u24BE | `0x100000`            | the range's start: file `0x110000`, inside a style's events (not an object boundary)   |
| `+0x15` | u24BE | `0x100000`            | the range's length in halfwords: 2 MB, file `0x110000-0x310000`                        |
| `+0x18` | u24BE | -> `RhythmCountBlock` | the u16BE at +2 of the block is the rhythm count, `0x50034B74`                         |
| `+0x1B` | u24BE | -> the index          | `0x50034B7C`                                                                           |
| `+0x1E` | u24BE | -> the style table    | `0x50034B80`                                                                           |
| `+0x21` | u24BE | -> the count-in table | `0x50034B84`                                                                           |
| `+0x24` | u24BE | -> style 0            | `0x50034B88`, the style `StyleBuiltinNameResolve` falls back to                        |

The checksum recomputes equal. It covers only the middle 2 MB of the chip.

**The count block** is 12 bytes: `00 00 | 00 DC | 00 60 | 0D 08 04 02 02 02`. Only the 220 at +2
is read: it is the rhythm count, and it bounds the index's style and table-ROM entries. No routine
reads the other ten bytes. The block is reached only through the header's +0x18, and the one place
that loads it, `StyleBuiltinNameTableInit`, reads `add 2, a0` / `call LoadU16BE` and keeps no pointer
to the block. The KN2400, KN6000 and KN6500 programs do the same.
[`rhythm_count_block_readers.py`](mn10300-names-probes/rhythm_count_block_readers.py) lists every u24BE
load from +0x18 in the four images. `TechnicsPadsResourceParse` reads the "Technics Pads" resource,
which has the same header, the same way. The table ROM copy's count, 221, is not read either: from
that copy the firmware takes only the index (+0x1B). The readings of the unread bytes are
`[INFERENCE]`:

- `0x60` = 96 is the number of ticks a beat. The position byte that comes before an event is
  0-95 in every stream (below).
- The six bytes read naturally as the format's dimensions: a name of 13 characters, 8 parts,
  4 variations, 2 fill-ins each, 2 intros and 2 endings. That makes 4 + 4x2 + 2x2 + 2x2 = 20
  slots, the number every style has. The "TCMP" MEMORY-style header has a similar run at +0x18
  (`0D 08 04 02 02 01 02 0F`, `kn7000_manual.sym`).

## The style-ID index

A style-ID (a u32 of the rhythm group lists) is folded to an entry
`((id & 0x0F00) >> 1) | (id & 0x7F)` by `StyleNameSourceSet` (0x484333FF). Its source bits
`id & 0x00700000` must be 0, the built-in source. 2048 entries cover every folded ID.
`StyleBuiltinNameResolve` (0x48433ABF) reads an entry `e` like this:

| entry        | count | meaning                                                                                   |
|--------------|-------|-------------------------------------------------------------------------------------------|
| `e < 220`    | 169   | style `e` of this resource's style table; each of the 169 appears once                    |
| `0x8000 + n` | 1828  | read entry `n` instead (one hop)                                                          |
| `0x4000 + n` | 51    | style `n` of the table ROM's secondary sub-table (`TableRomStyleSubTablePtr`, 0x48244F78) |

After one alias hop, every one of the 2048 entries resolves to a style. The source writes the three
kinds as `sidx_style SNo_<style>`, `sidx_alias <entry>` and `sidx_table <n>`. Each line carries its
style-ID in a comment, and a table-ROM entry carries that style's name as table 84 has it.

So the 220 built-in rhythms are 169 styles in IC18 and 51 in the table ROM. Program 941's 14
rhythm groups list 220 IDs. All 169 IC18 styles are among them, each in exactly one group. The
chip stores them in group order: 8&16 BEAT, ROCK & POP, ... SOUL & R&B. COUNTRY&WESTERN has one
IC18 style (Bluegrass) and 13 from the table ROM. MARCH & WALTZ and LATIN & WORLD come entirely
from the table ROM. The source heads each style with its group, its place in the group and its
style-ID.

**The table ROM's copy.** Table 84 carries a truncated copy of this header and index at
0x483E828C (`TechnicsRhythmsTable` in `src/table.s`, 0x1248 bytes). `StyleBuiltinNameTableInit`
re-points `0x50034B7C` at that copy's index when the copy also carries the signature. So with
table 84 installed, the index the firmware uses is the table ROM's. The copy differs from IC18's
first 0x1248 bytes in 7 bytes: the checksum fields are zeroed, the count is 221, and one index
entry is different. That makes room for a 52nd table-ROM style, "70s Orchestra".

## The style table and the count-in patterns

The style table holds 169 u24BE offsets, each spelled `.be24 Style_<name> - TechnicsRhythms`.
Entry 0 is the fallback style.

The count-in table holds 8 offsets. Pattern `k` is one bar of `k + 1` beats. It sets the drum part
to program `00 00 26`, Standard Kit 1. On every beat it plays key 37, `KitRimShot`, at velocity 64.
The source types these 8 patterns like any variation.

**Who plays them.** `StyleRecordSlotSelect` (0x48433643) binds a count-in for slot 20, the
INTRO 1 handler's count-in case (`func_484437DA`, below). It gets the record from
`StyleCountInRecordGet` (0x484335BF). Until 2026-11-02 that routine was called
`StyleVariationNameGet`, and the name was wrong: it returns a count-in pattern record, not a name.
Its code (`d0` = the main variation's slot, 0, 3, 6 or 9):

    mov  0x50034bcc, a0 / mov (d0, a0), a0        the main variation's record
    movbu (1, a0), d0 / and 7  (builtin)           its meter byte, beats - 1 (MEMORY/CUSTOM: +0x11)
    mov  0x0000d00a, d0 / call GetM3EmVal_entry   parameter 0xD00A: COUNT INTRO (IntroToggleFunc,
    cmp  1, d0                                    the CountIntro widget of the APC screen TApcSel)
    ... (d0, 0x48736078), a2                       ON: the program's own pattern for this meter
    ... LoadU24BE(*(0x50034B84) + 3 * meter)       else, or for 5-8 beats: IC18's count-in table
    movbu 1, (0x50122dd0)                          a pattern was found

The program's table 0x48736078 has four records, for 1 to 4 beats, at 0x485B8D68 / 0x485B8D7D /
0x485B8D99 / 0x485B8DBC. Each sets the drum part to program `40 00 26`, Voice Kit, and plays keys
74, 75, 76 and 77 at velocity 76, one key a beat. Voice Kit names those keys "Count 1" to
"Count 4". So COUNT INTRO counts the bar in aloud, and IC18's patterns are the click count-in.
When no pattern is found, `StyleRecordSlotSelect` falls back to INTRO 1. The flag 0x50122DD0
(`StyleCountInBoundGet` 0x48433AB6, until 2026-11-02 `StyleVariationNameFlagGet`; read by
`func_48441DEB` and `StyleRecordSelectBind`) makes
the binders treat the count-in as a built-in record whatever the style's source is, and makes the
set-up replay apply its program changes.
[`rhythm_style_semantics.py`](mn10300-names-probes/rhythm_style_semantics.py) section 5 prints the
four records.

## A style record (0xC6 bytes)

`StyleNameCommit` (0x484334A4) and `func_484420EF` read the record:

| offset  | size   | field               | evidence                                                                           |
|---------|--------|---------------------|------------------------------------------------------------------------------------|
| `+0x00` | 13     | name, as displayed  | copied to the name buffer `0x50034B9C` and NUL-terminated there                    |
| `+0x0D` | 4      | two DSP preset keys | `0x50034C20`; `func_484420EF` decodes them (below)                                 |
| `+0x11` | 8 x 15 | eight part set-ups  | `0x50034BAC[i] = record + 0x11 + 15i`; `func_4844187A` copies them to `0x5003A37C` |
| `+0x89` | 1      | 1 in every style    | unread (below)                                                                     |
| `+0x8A` | 20 x 3 | slot offsets        | u24BE, from the record; `0x50034BCC[slot]`                                         |

**The byte at +0x89 is unread.** It is 1 in all 169 styles and in the program's fallback style. A
record reaches code only as a pointer: `StyleBuiltinNameResolve` returns it, `StyleNameSourceSet`
caches it in 0x50034B8C, and `StyleNameCommit` derives three things from it. Those are the units
pointer 0x50034C20 (+0x0D), the part pointers 0x50034BAC (+0x11 + 15i) and the variation pointers
0x50034BCC (from the offsets at +0x8A). Each reader of those, and each routine they hand the record
to, uses one of these ranges:

- the 13-byte name: `StyleNameCommit` and its MEMORY / CUSTOM twins, `func_48433C1E`, `func_4843A512`;
- the 4 unit bytes: `func_484420EF` / `func_484420C8`, and `func_4843A47C` / `func_4843A512`, which
  copy them into a MEMORY style;
- 15 bytes from a part pointer: `func_4844187A` and `func_48441FB3`. `func_48441EB4` copies all
  eight set-ups as one `memcpy` of 0x78 bytes from +0x11, which ends at +0x88;
- the 3-byte slot offsets from +0x8A: `StyleNameCommit` and `func_48433D88`.

No instruction in the program uses a displacement of 0x89 or an `add 0x89` on an address
register, so part 7's set-up ends at +0x88 and the slot table starts at +0x8A. The KN2400, KN6000 and
KN6500 programs have the same readers.
[`rhythm_style_record_readers.py`](mn10300-names-probes/rhythm_style_record_readers.py) collects
the readers of the four images, 44 to 50 routines each, and prints PASS for all four. The only
other bytes that cover +0x89 are those of the checksum `StyleResourceVerify` sums (2 MB of the chip)
and of the update path that rewrites the chip (`KN7KR1` / `KN7KR2`), and neither reads fields. The
source writes it as `.byte 1` with the comment "unread".

**DSP preset keys** (`style_units`). `func_484420C8` decodes each 2-byte pair as a 14-bit value,
7 bits a byte, low byte first. Bit 6 of the second byte adds 0x10000. `func_484420EF` stores the
first pair to parameter key 0xB044 and the second to 0xB054. Bit 7 of the first pair's second byte
goes to key 0xB001. The groups 0xB010 to 0xB050 are the five DSP effect units, EFF1 to EFF5 on the
EFFECT DEBUG screen. Its grid has the columns `UNIT | PART | OFF/ON | NUM | SUF | VARI`, and
`SndCmdEmitUnitCc` selectors 2 to 6 read them. So a style sets the effects of units EFF4 and EFF5.
Key 0xB001 is that screen's `EffApcModeBox`, "TOTAL MODE" (1) or "SOUND MODE" (0); 56 styles set it.

The value is the key of a DSP preset record, the same key `SndUnitSettingApplyFull` (0x484105EA)
resolves:

- `func_48412BD8` takes the low byte as the record kind (below 0x70: a factory preset);
- `func_48412187` indexes the table 0x48703558 with `(lo << 6) | (hi & 0x3F)`, 0x2010 entries;
- the record's u16 at +0x12 is the effect type, which goes to `DspEffectTypeValid` / `DspEffectSelect`;
- every record names itself: a 16-character name, and its own key at +0x1C.

All 338 keys of the 169 styles are presets whose own key matches. 0x0044 is "Limiter1" (236 keys,
88 styles have it for both units), 0x1111 "Shallow2" (22), 0x0B12 "Normal4" (6). Others are
"Single Rotor", "Wah1", "Comp+Dst+Delay", "Bright Twin" and so on. The source's comment names the
two presets: `style_units 0x11, 0x91, 0x44, 0x00 # EFF4 "Shallow2", EFF5 "Limiter1", TOTAL MODE`.
[`rhythm_style_semantics.py`](mn10300-names-probes/rhythm_style_semantics.py) section 4 prints the
list. The parts the units serve come from the bound variation's bytes +2/+3 (`func_48442164`,
"A variation record" below).

**A part set-up** (15 bytes, `style_part`). Byte `k` is the value of field `k` of the firmware's
part-field table 0x485B77D4. That table holds one (status, controller) pair per field.
`StyleRecordToTemplate` (0x48441D1B) and `func_48441EB4` map an incoming controller to its field
through 0x485B789C / 0x485B781C. A field reaches the sound by two paths:

- `func_4844085D` / `func_48440662` send each changed field as a controller event to
  `StyleIdArrayHandler` (0x48435DD0);
- `func_48440533` turns the event into the part parameter `0xB000cc` (CC96: `0xB08000`), which
  `StyleIdArrayStore` queues for the part.

What each parameter is comes from the program's own parameter dump `func_48500C71`. Its records
(0x48644F5C, keyed by parameter + 1: `inc d1` before the lookup) print "EQ LOW FC", "DIGITAL
EFFECT" and so on. The GUI's formatters agree: `func_4848BC9A` prints an FC through the table
0x485EC344, 20 Hz to 20 kHz in third octaves, at `value >> 2`. `func_4848BD21` prints a gain as
`(value - 64) / 2` dB, clamped to +-12. The tone generator's own controller table (lib
`TgPartControlChange`, records 0x48586860) has handlers for CC80-83, 91-94 and none for CC96 or CC97.

| byte | controller | name in the source             | meaning (program 941)                                                                                                     | values over 169 x 8 parts                              |
|------|------------|--------------------------------|---------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------|
| 0    | CC97       | `fold_root`                    | never sent (field 0 is `B0 FF`, and `func_48440662` skips a controller above 127); the note-conversion octave fold, below | `0x00` on parts 0 and 7; `0x08` on the others but 8    |
| 1    | CC7        | `volume`                       | volume, sent folded into CC11: `expression + volume - 127` (`func_48440662`)                                              | most often 105, 98, 127, 100                           |
| 2-4  | program    | `prog`, `bank_lsb`, `bank_msb` | the part's sound {program, bank LSB, bank MSB} (`func_4844077C`; `VoiceBankClassify`'s key order)                         | `bank_msb` 0x26 (the kits) on parts 0 and 7, else 0x20 |
| 5    | CC94       | `dsp_sw`                       | DIGITAL EFFECT: 0 off, 127 on, other = the sound's own setting (`func_48448D93`); TG lib 0x4C007724: part flag 0x1000     | 64 in every part                                       |
| 6    | CC91       | `reverb`                       | REVERB                                                                                                                    |                                                        |
| 7    | CC93       | `chorus`                       | CHORUS DEPTH                                                                                                              | 0 in 1221                                              |
| 8    | CC10       | `pan`                          | pan                                                                                                                       | 64 in 929                                              |
| 9    | CC96       | `bend_range`                   | parameter 0xB08000, RPN 0 "BEND SENS" in semitones                                                                        | 12 in every part                                       |
| 10   | CC82       | `eq_lo_fc`                     | EQ LOW FC; TG lib 0x4C0082CA: part +0x21, at most 0x7C                                                                    | 28 (100 Hz) in most                                    |
| 11   | CC83       | `eq_lo_gain`                   | EQ LOW GAIN; TG lib 0x4C0082F0: part +0x23 = value - 64, clamped to +-24                                                  | 64 (0 dB) in most                                      |
| 12   | CC80       | `eq_hi_fc`                     | EQ HIGH FC; TG lib 0x4C00826B: part +0x22                                                                                 | 108 (10 kHz) in most                                   |
| 13   | CC81       | `eq_hi_gain`                   | EQ HIGH GAIN; TG lib 0x4C008291: part +0x24                                                                               | 64 in most                                             |
| 14   | CC92       | `multi`                        | MULTI EFFECT DEPTH                                                                                                        | 0 in 1259                                              |

The four EQ fields are read together by the tone generator's `func_4C00807E`. It takes the two
(FC, gain) pairs at part record +0x21/+0x23 and +0x22/+0x24, looks each FC up in 0x4C008071's table
(132 exponential words) and computes the filter coefficients in double precision (`LibF64Div`,
`LibF64Mul`). So they are a two-band part equaliser. The coefficients reach the tone generator's
per-voice filter-coefficient registers (2026-11-06,
[`rhythm_part_eq_and_units.py`](ic18-rhythm-rom-probes/rhythm_part_eq_and_units.py) part A):

- `func_4C00807E` writes five 20-bit words to the part record (0x500B5340 + part x 0x54C) at
  +0x28, +0x2C, +0x30, +0x34 and +0x38, and a normalising shift (`asl 3` / `LibDiv32` by 6 of the
  halvings it needed) to the byte at +0x3C;
- when a part's EQ changes (a case of the TG controller handler `TgPartControlChange`), the library collects the part's voices (`TgVoiceListCollectPartAll`) and `func_4C0045E7` merges the five words
  into each voice record (`TgVoiceRecordPtr`) at +0x64 .. +0x74, keeping the top 12 bits, then calls
  `TgVoiceReg4000GroupWrite` (lib 0x4C037BA8);
- that writes the five words through `TgVoiceRegWrite` as register classes 0x40000000, 0x44000000,
  0x48000000, 0x4C000000 and 0x50000000 of the voice's slot (hi16 to 0x98050000 / lo16 to
  0x98050002 on the MAIN TG, 0x98040000 on the SUB TG).  The note-on paths (`TgElemNoteOnStd`,
  `TgKitElemNoteOn`, `TgElemNoteOnFresh` and four unnamed routines) copy part +0x28 into a new
  voice's +0x64 (`[INFERENCE]` from `add 0x28` / `add 0x64` on the two pointers), so every note
  starts with them.

What the TG does with classes 0x40-0x50 (the filter topology, the coefficients' fixed-point format)
needs the tone generator's datasheet.  The probe finds no load of the byte at +0x3C in the library.

**`fold_root`.** `func_484419BB` reads field 0 of the part template 0x5003A2BC, and `func_4843D558`
passes it to the key conversion `func_4843CEF3` -> `func_48436229`. There the note follows the
chord root up by `root - 1` semitones. When `root - 1 > fold_root` it is moved by `root - 13`
instead:

    movbu (a0), d2 / add -1, d2           root - 1  (root 1..12 of the current chord)
    movbu (1, a0), d0 / cmp d0, d1 / bgt  fold_root
    mov -0xc, d2 / add d1, d2             one octave lower

So with 8 the pattern moves up for roots C to G# and down for A, A# and B, which keeps an
accompaniment part within a fifth of where it was written. The value does not matter on the drum
parts, where every note's rule is `NcrNone`. The routine's other branches are in "What the
conversion tables do" below.

Fields 15-23 of the table (CC64, CC1, CC11, channel pressure, pitch bend, CC16, CC17, CC13) are not
in a style's set-up. They start from the default template 0x485B7804.

`[INFERENCE]` The eight parts are Drum, Bass, Acc1-Acc5 and Perc. Parts 0 and 7 play kits
(`bank_msb` 0x26) in every style, and every note on them has rule `NcrNone`. Part 1's program is
0x21 in 84 of the 169 styles, which is GM's finger bass.

## The 20 slots

| slots | name in the source                               | bars                      | evidence                                                                                                                           |
|-------|--------------------------------------------------|---------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| 0-11  | `Var1`, `Var1Fill1`, `Var1Fill2` ... `Var4Fill2` | 4, 1, 1 in all 169 styles | only `slot % 3 == 0` carries a name in a MEMORY style (`MemStyleVarCopy` 0x4843B22E); `func_4844232B` treats `slot % 3 != 0` apart |
| 12-13 | `Intro1Major`, `Intro1Minor`                     | 1-9                       | INTRO 1: slot `12 + 4k` for `k` = 0 (`func_484437DA`)                                                                              |
| 14-15 | `Ending1Major`, `Ending1Minor`                   | 1-8                       | ENDING 1: slot `14 + 4k` for `k` = 0 (`func_484439EB`)                                                                             |
| 16-17 | `Intro2Major`, `Intro2Minor`                     | 2-9                       | INTRO 2: `k` = 1                                                                                                                   |
| 18-19 | `Ending2Major`, `Ending2Minor`                   | 2-10                      | ENDING 2: `k` = 1                                                                                                                  |

**The intro and ending handlers** of program 941 (both called from the rhythm event dispatcher
`func_48435ED4`, cases 0x48435FC8 / 0x48435FFD, and from `CmpVariationSelect`) compute the slot:

    func_484437DA (INTRO, d0 = 1, 2, 3):  1 -> 2, 2 -> 0, 3 -> 1 (`add -2` / `mov 2`), >= 3 -> 0
                                          asl2 d2 / add 0xc, d2         slot 12 + 4k: 20, 12, 16
    func_484439EB (ENDING, d0 = 1, 2):    d2 = d0 - 1
                                          add d2, d2 / inc d2 / add d2, d2 / add 0xc, d2   slot 14 + 4k

So INTRO 1 is slot 12 and INTRO 2 slot 16, and the third intro case is slot 20, the count-in
(above). ENDING 1 is slot 14 and ENDING 2 slot 18. `func_4844232B` and `func_48442F03` single out
`(slot - 12) % 4 < 2`, the intros. The bar counts fit: INTRO/ENDING 1 are 1-9 bars, 2 is 2-10.
The chip stores a style's slots as the intros, the twelve variation slots, then the endings (12,
13, 16, 17, 0-11, 14, 15, 18, 19). The earlier reading of this note had 12-15 as the intros and
16-19 as the endings. That was wrong; the source's labels follow the code since 2026-11-02.

**The two halves are major and minor.** `StyleRecordSelectBind` (0x4843398F) is called with the
slot (`0x5003A466`) and an extra byte (`0x5003A46A`). `StyleRecordSlotSelect` adds that byte to an
intro or ending slot, `(0x2c, sp) + d1`. The byte is only ever written as 0 (reset, `RhyControllerReset`)
or as `func_484361BC(chord type)`, in `func_48442FC7` when the chord changes. `func_484361BC` is a
lookup in the 42-byte table 0x485B6EC8:

    cmp 0x2a, d0 / bcs   -> movbu (d0, 0x485B6EC8), d0   1 when the entry is nonzero, else 0

The entries that are 1 are the minor-family chord types of the chord-name table 0x485A0EA8: min,
min7, dim, m7(b5), mM7, m6, m(b5), m7(9), m6(9), mM7(b5), madd9, and the two 7(#9) 13 types (31, 34).
`func_48442FC7` re-binds the running intro or ending when the new chord changes the half
(`StyleSlotRecordDiffers`). The music agrees: in the non-drum parts (1-6), pitch class 4 (E) is
11-13 % of the A halves' notes and 1 % of the B halves'. Pitch class 3 (Eb) is 2-3 % of A and
13-15 % of B. Pitch class 9 (A) goes from 8-10 % to 2 % and pitch class 8 (Ab) from 2 % to 6-8 %.
That is the same pattern in C major and in C minor
([`rhythm_style_semantics.py`](mn10300-names-probes/rhythm_style_semantics.py), sections 1-2). The
two halves have the same bar count in every style.

`[INFERENCE]` The roles of slots 0-11 are main pattern and fill-ins. They follow the panel's
VARIATION 1-4 and FILL IN 1/2 buttons, the bar counts and the count block.

## A variation record

`StyleRecordBindBuiltin` (0x484336DB) binds the current one into the pattern player's view:

| offset     | size  | field                                                       | evidence                                                                    |
|------------|-------|-------------------------------------------------------------|-----------------------------------------------------------------------------|
| `+0`       | 1     | bars - 1                                                    | `0x50122DCE`; `StyleBoundRecByteCeInc` + 1 -> `0x5003A452` (`RhyMeterBind`) |
| `+1`       | 1     | beats a bar - 1                                             | `0x50122DCF`; `StyleBoundRecByteCfLow3` + 1 -> `0x5003A454`                 |
| `+2`, `+3` | 1, 1  | the style parts DSP units EFF4 / EFF5 serve, 0xFF = default | `0x50122DD4`; `func_48442164` (below)                                       |
| `+4`       | u16BE | set-up length L                                             | `0x50122DCC`                                                                |
| `+6`       | L     | set-up events                                               | `0x50122DC8`; replayed into the part table by `func_48441DEB`               |
| `+6+L`     | u24BE | stream length S                                             |                                                                             |
| `+9+L`     | S     | the event stream                                            | start `0x50122DC0`, end `0x50122DC4` = start + S - 1, the 0xF5              |

Bytes 2/3 are `FF FF` in 2710 of the 3380 variations and `FF 02`-`FF 07` in the rest. They are
the style parts that the DSP effect units the style sets (EFF4 / EFF5, `style_units` above) apply
to (2026-11-06, [`rhythm_part_eq_and_units.py`](ic18-rhythm-rom-probes/rhythm_part_eq_and_units.py)
part B). `func_48442164` runs when the style's units are applied (`func_4844223A`, after
`StyleDspUnitsApply`, and at the other six call sites) and reads them through `0x50122DD4`:

- a byte of 8 or more (0xFF) takes a default: style part 2 (Acc1) for +2, part 3 (Acc2) for +3,
  and the other one when the named part is that default (+3 = 2 moves +2's default to 3);
- `func_48435C29` maps each style part to its TG part (table 0x485B6DA8: Drum 0x19, Bass 0x18,
  Acc1-Acc5 0x13-0x17, Perc 0x1A); nothing more happens when either is invalid or the
  units' flag 0x5003A43C is 0;
- it queues (`StyleIdArrayStore`) key 0xB048 = `(part_of_+3 << 8) | part_of_+2`, then for each of
  the two TG parts parameter 0x0020005F ("SOUND DSP" ON / OFF in the parameter dump `func_48500C71`)
  = 1 when the variation named the part and 0 when it took the default, and parameter 0x00B0005F
  ("SOUND DSP DEPTH") = 80.

So in the 670 variations that name a part (always in +3, parts 2-7) that part's SOUND DSP is on;
in the other 2,710 the default parts get depth 80 with the switch off. Key 0xB048 itself has no
reader by its literal value in program 941 (the unit PART keys `SndUnitRefreshGroups56` reads are
0xB040 / 0xB050) and no `M3HookDispatch` handler (the class-0x00 list holds only {0xFF00, 0xD000});
`[INFERENCE]` it is the style's record of the two parts, which the DSP unit code reads through
another key. The set-up
events are only CC (22,351) and program changes (4,947). In the source, `var_head` writes the
first six bytes from the bars, the beats and the two parts, with the length as a label difference.
The set-up events follow, one per line (below). Then come `var_events` (the stream length as a label
difference), the stream's events and `var_end`.

The MEMORY ("TCMP") variation record is a different layout of the same fields: bars at +0x10,
meter at +0x11, the stream offset at +0x15, no set-up events (`kn7000_manual.sym`, the TCMP
section). `MemStyleVarBarCount` (0x4843C445) gives the beat-marker count both kinds must hold.

## The event stream

Event lengths are those of `RhyEventLenByStatus` (0x484403D5) and `RhySysexLen` (0x484403CD). The
low nibble of a status byte is the part.

| first byte  | length | meaning                                                               | count in the 169 styles |
|-------------|--------|-----------------------------------------------------------------------|-------------------------|
| `0x00-0x5F` | 1      | position: the tick in the beat (0-95) of the events after it          | 324,664                 |
| `0x9n`      | 6      | note: key, velocity, then three bytes                                 | 529,662                 |
| `0xBn`      | 3      | controller: CC11 69,771, CC1 24,081, CC64 17,758, CC10 1,593, CC91 20 | 113,223                 |
| `0xDn`      | 2      | channel pressure                                                      | 4                       |
| `0xEn`      | 3      | pitch bend                                                            | 23,491                  |
| `0xF4`      | 1      | beat marker; a stream opens with one                                  | 39,412                  |
| `0xF5`      | 1      | end of stream                                                         | 3,388                   |
| `0xF0`      | 2 + n  | SysEx                                                                 | 0                       |

All 3,388 streams (169 x 20 plus the 8 count-ins) parse to their exact end. Each opens with 0xF4,
ends with 0xF5, and has bars x beats beat markers. Every data byte is below 0x80. The 324,664
position bytes are all 0-95 and never fall within a beat. That is why they read as positions, not
deltas, and why a beat is 96 ticks. An event with no position byte before it is at tick 0.

**A note's last three bytes** are its gate time and its note-conversion rule:

- **gate**, bytes 3-4, 7 bits a byte, low byte first, in ticks. When a pattern starts in the middle
  (`func_484425FE`, which walks the stream from `0x50122DC0` to the play position), a note whose
  gate reaches past the position is started for the rest of it:

      movbu (4, a1), d0 / movbu (3, a1), d1 / asl 7, d0 / add d1, d0   gate
      cmp d3, d0 / ble -> skip / sub d3, d0 / call func_4843D558        start with gate - elapsed

  `func_4843D558` starts such a note only when at least a beat is left (`cmp 0x60, d0`). The most
  common gates are 12, 8, 11, 13 and 14 ticks; the longest is 15,715.
- **rule**, byte 5, an entry of `NoteConvRules` (0x48736104, 128 x 8 bytes). `func_4843D558` reads
  it (`movbu (5, a0)`), tests its flag bytes +2/+3 (`func_484361F3`, `func_4843620E`) and hands it
  to the key conversion `func_4843CEF3`, which reads +1 (`func_484361D8`). Then `func_48436229`
  converts the key through the table at +4. Each table starts with a pointer to its name, so the
  rules name themselves:

| rule                     | notes   | the rule's table (program 941)                      | source name                 |
|--------------------------|---------|-----------------------------------------------------|-----------------------------|
| 0                        | 205,435 | none: the key is not converted                      | `NcrNone`                   |
| 1                        | 192,095 | "Root Shift Only"                                   | `NcrRootShiftOnly`          |
| 16                       | 54,978  | "Melody Basic"                                      | `NcrMelodyBasic`            |
| 17                       | 4,440   | "Melody In 7th G>Bb"                                | `NcrMelodyIn7thGToBb`       |
| 18                       | 1,402   | "Melody In 7th C>Bb"                                | `NcrMelodyIn7thCToBb`       |
| 19                       | 698     | "Maj incl. F for Gospel etc"                        | `NcrMajInclFForGospelEtc`   |
| 20                       | 1,022   | "Maj incl. A for walking Bass"                      | `NcrMajInclAForWalkingBass` |
| 21                       | 823     | "Maj incl.Bb for MAJ=7th"                           | `NcrMajInclBbForMajIs7th`   |
| 22                       | 44      | "Natural=MelodicDown"                               | `NcrNaturalIsMelodicDown`   |
| 23                       | 277     | "Harmonic Minor"                                    | `NcrHarmonicMinor`          |
| 24                       | 7       | "Merodic Min Ascend" (sic)                          | `NcrMerodicMinAscend`       |
| 80                       | 46,711  | "Basic Chord 100%"                                  | `NcrBasicChord100`          |
| 82                       | 2,335   | "Keep near C"                                       | `NcrKeepNearC`              |
| 83                       | 5,085   | "HardRock Chord"                                    | `NcrHardRockChord`          |
| 96                       | 718     | "Chord CEGB"                                        | `NcrChordCEGB`              |
| 97                       | 2,082   | "Chord CDEG"                                        | `NcrChordCDEG`              |
| 98                       | 1,155   | "Chord DEGB"                                        | `NcrChordDEGB`              |
| 100                      | 7,670   | "Chord CEGA"                                        | `NcrChordCEGA`              |
| 101                      | 1,378   | "Chord ADGC"                                        | `NcrChordADGC`              |
| 102                      | 356     | "Chord EGAD"                                        | `NcrChordEGAD`              |
| 103                      | 199     | "Chord CEAD"                                        | `NcrChordCEAD`              |
| 10, 32, 58, 81, 118, 122 | 716     | 10 none; the others repeat 17's, 15's or 80's table | the number                  |

Every note on parts 0 and 7 has rule 0. Part 1, the bass, mostly has `NcrRootShiftOnly` and
`NcrMelodyBasic`; the chord parts have the `Chord` rules. The 128 entries, their flags and their
names are the same in the KN2400, KN6000 and KN6500 programs. Entries 26-79 repeat table 17,
84-95 and 104-127 table 80, 25 table 22, 81 and 99 the unnamed table of 15. [`rhythm_style_semantics.py`](mn10300-names-probes/rhythm_style_semantics.py)
section 3 prints the counts. What each table does to a key is the next section.

**What the conversion tables do** (2026-11-06,
[`rhythm_noteconv_tables.py`](ic18-rhythm-rom-probes/rhythm_noteconv_tables.py)). The patterns are
written over a C chord: a key's pitch class is read as a degree of C. A rule entry is
`{mode, alt_chord, flag2, flag3, u32 table}`, and a table is a name pointer followed by signed
offsets. `StyleNoteKeyConvert` (0x4843CEF3) hands `NoteConvApply` (0x48436229) the note's
`{rule, fold_root, bass, root, type, on_bass, ..., state ptr, composer_part}`: root 1-12 (C = 1)
and type 1-41 from `GetCurrentChord`, or from the second chord record `func_4844DDC6` copies when
the rule's `alt_chord` byte is set (only rule 2); `bass` is 1 on style part 1; `composer_part` is
1 when the rhythm genre is not 0 and the part is the one `CmpRecPartSet` selected (set from the
COMPOSER's step screen `TT_CMSTEP`, 0xFF = none; [INFERENCE] the part being recorded).
`NoteConvApply` then:

- rule >= 0x80, or no table (rules 0, 3-14): the key unchanged, chord or not;
- root 0 (no chord): 0xFF, no note;
- type 0: the chord's root in the key's octave (`key - key % 12 + root - 1`, folded by `fold_root`);
- `composer_part`: only the root shift (`root - 1`, folded), and with `flag2` clear a written E
  (pitch class 4) becomes Eb on a minor-family chord (`ChordTypeMinorTable`); `flag3` set: no
  shift at all;
- the bass part when the chord's bass note (+5, a slash chord) is not its root, or the state
  byte 0x50038D95 is set (cleared on use): the bass note in the key's octave, folded, and an octave up
  when that lands more than 11 - `fold_root` semitones below the key;
- otherwise the table. **Mode 1** (11 tables, 496 bytes: 41 types x 12 pitch classes): the key
  moves by `offset[type][key % 12]`, then by the root (`root - 1`, an octave lower above
  `fold_root`). **Mode 0** (10 tables, 5,908 bytes: 41 types x 12 roots x 12 pitch classes): the key
  moves by `offset[type][root][key % 12]` only, which holds the root shift and the inversion;
- last, for the bass part, an octave up when the result is more than an octave below the key; the
  result is folded into 0..127 by octaves (`func_48436197`).

The chord types are the 41 names `AcChordBoxProc` prints (0x485A0D45; type t is name t - 1, which
the minor-family table confirms: its 13 types are the 13 minor / dim / (#9) names): 1 Maj, 2 7,
3 Maj7, 4 aug, 5 min, 6 min7, 7 dim, 8 m7(b5), 9 mM7, 10 7sus4, 11 6, 12 aug7, ... 40 add9,
41 madd9. What the tables do, read from their offsets:

| table (rules)                                                                       | mode | what it does to a key written over C                                                                                                                                                        |
|-------------------------------------------------------------------------------------|------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| "Root Shift Only" (1, 2)                                                            | 1    | every offset 0: transposed by the root only                                                                                                                                                 |
| unnamed (15, 81, 99), "Melody Basic" (16)                                           | 1    | the scale follows the chord: on 7 Eb -1, A +1, B -1 (B -> Bb); on min E -> Eb, B -> Bb, A and Ab -> C (avoid notes go up); dim and m7(b5) pull every tone onto the chord; 15 also adds 9ths |
| "Melody In 7th G>Bb" (17, 26-79)                                                    | 1    | as Melody Basic, and on 7th chords G (and F#) go up to Bb                                                                                                                                   |
| "Melody In 7th C>Bb" (18)                                                           | 1    | as Melody Basic, and on 7th chords C goes down to Bb                                                                                                                                        |
| "Maj incl. F for Gospel etc" (19)                                                   | 1    | as Melody Basic, and F is raised to G on 7 and min (F is kept on Maj)                                                                                                                       |
| "Maj incl. A for walking Bass" (20)                                                 | 1    | A is kept on 7 and min (a walking bass's 6th); on 7, C -> Bb                                                                                                                                |
| "Maj incl.Bb for MAJ=7th" (21)                                                      | 1    | a 7 chord moves only B -> Bb: the written Bb is the 7th                                                                                                                                     |
| "Natural=MelodicDown" (22, 25)                                                      | 1    | on min: E -> Eb, A -> Ab, B -> Bb (natural minor)                                                                                                                                           |
| "Harmonic Minor" (23)                                                               | 1    | on min: E -> Eb, A -> Ab, Bb -> B (harmonic minor)                                                                                                                                          |
| "Merodic Min Ascend" (24)                                                           | 1    | on min: E -> Eb, Ab -> A, Bb -> B (melodic minor)                                                                                                                                           |
| "Basic Chord 100%" (80, 84-95, 104-127)                                             | 0    | every written scale tone onto a chord tone (Maj {0, 4, 7}, 7 {4, 7, 10}, min {0, 3, 7} above the root), an inversion per root that stays within A3..C#5                                     |
| "Keep near C" (82)                                                                  | 0    | all seven scale tones kept (transposed diatonically), the octave chosen per root to stay within Ab3..E5                                                                                     |
| "HardRock Chord" (83)                                                               | 0    | onto the root and fifth only, {0, 7}: a power chord                                                                                                                                         |
| "Chord CEGB" / "CDEG" / "DEGB" / "CEGA" / "ADGC" / "EGAD" / "CEAD" (96-98, 100-103) | 0    | a written four-note voicing mapped tone by tone onto the chord's tones, keeping its shape (CEGA: Maj {0, 4, 7, 9}; DEGB: Maj {2, 4, 7, 11}), per root inside about G3..E5                   |

The probe prints every table's offsets per chord type (mode 1) and the intervals and range the
written scale lands on per type over the 12 roots (mode 0).

**In the source**, one event per line, one macro per kind (defined in `rhythm.s`):

| macro                                                         | bytes                               | used for                                                       |
|---------------------------------------------------------------|-------------------------------------|----------------------------------------------------------------|
| `n part,key,vel,gate,rule`                                    | `9n key vel gate&0x7F gate>>7 rule` | a note                                                         |
| `vol`, `pan`, `expr`, `mod`, `sus`, `rev`, `cho` `part,value` | `Bn CC value`                       | CC7, 10, 11, 1, 64, 91, 93                                     |
| `fold_root`, `dsp_sw`, `bend_range`, `eq_lo_fc` ... `multi`   | `Bn CC value`                       | CC97, 94, 96, 82, 83, 80, 81, 92 (set-ups; see `style_part`)   |
| `cc part,ctl,value`                                           | `Bn ctl value`                      | any other controller (none in this ROM)                        |
| `pc part,prog,bank_lsb,bank_msb`                              | `Cn prog bank_lsb bank_msb`         | program change (set-ups only)                                  |
| `bend part,lsb,msb`, `pres part,value`                        | `En lsb msb`, `Dn value`            | pitch bend, channel pressure                                   |
| `@<any of the above> tick,...`                                | `tick` then the event               | the event with the position byte before it                     |
| `beat`, `end`                                                 | `F4`, `F5`                          | beat marker, end of stream                                     |
| `at tick`                                                     | `tick`                              | a position byte with no event after it; not needed in this ROM |

So `@n 48,0,KitBassDrum1,64,16,NcrNone` is a bass drum on part 0 at tick 48 of the beat, 16 ticks
long.

**Drum keys.** On parts 0 and 7 a key is spelled by its name in table 84's Standard Kit 1
(`.equ KitBassDrum1, 36` ...). Keys 0, 1 and 117-127 are "Silent" there and stay numbers. A kit
(bank MSB 0x26) is a table tone, class 0x40. `TgNoteOnTableTone` (0x4C03600D) reads a
{program, LSB, MSB} triple per note at `+0x27 + note * 3`.
`TgPartVoiceRecFetchSel` -> `TgPartVoiceRecFetch` -> `VoiceRecFetchBanked` -> `VoiceBankClassify`
turn that triple into a voice record, whose first 13 bytes are the name (`tone_note` and
`Voice_*` in `src/table/voices/internal_archive.s`). Standard Kit 1 names every key from 2 to 116.
Its layout is GS's for 27-87 but its own around it, for example 18 "H.H.On Beat", 19 "H.H.Off
Beat", 20 "Hi-Hat Accent", 21 "H.H.Half Open", 24 "Piccolo Snare", 104 "Shaker OnBeat", 106
"Maracas On" and 111-116 "Cowbell 1" to "Cowbell 6". It calls key 37 "Rim Shot" (GS: side stick).

The styles play 40 kit sounds. 30 of them are tones of the internal archive: Live Standard Kit,
Standard Kit 2, Standard Kit 1, Jazz Kit and so on. Voice Kit is the one COUNT INTRO uses. The other
10 have no tone there: eight LSB-4 variants, {34, 0} and {127, 0}, 3,386 notes in all.
`ToneKeyFind` (0x4856FC51, through `ToneRecordFind`) gives them another kit (2026-11-06,
[`rhythm_kit_tone_fallback.py`](ic18-rhythm-rom-probes/rhythm_kit_tone_fallback.py)). After the
archive sources 1-4 and the internal hash fail, the kit bank (MSB 0x26) takes none of the per-MSB
rules and reaches the general tail (0x4856FF17), which tries {MSB, LSB & 0xF8, program},
{MSB, 0, program}, {MSB, 0, program & 0xF8}, {MSB, 0, 0} and last 0x207F7F. So each LSB-4 kit
plays the LSB-0 kit of its program ({26, 4} Analog Kit 2, {32, 4} Jazz Kit, {31, 4} Techno Kit,
{48, 4} Orchestral Kit, {72, 4} Bongo&Conga Kit, {27, 4} Soul Kit, {0, 4} Standard Kit 1,
{56, 4} Sound Effect Kit), {34, 0} plays Jazz Kit (program 32) and {127, 0} Standard Kit 1. With
that, 191,448 of the 203,802 drum notes (93.9 %; 188,420, 92.5 %, counting the ten as not
matching) play a voice that has Standard Kit 1's name for that key in the kit they sound. The rest
are the kits' own sounds on
the same keys: the brush kits put "Brush Tap", "Brush Slap" and "Brush Swirl" on 38-40, the
orchestral kit "Orch.S.Drum 1" on 38, and the bongo / conga and voice kits have their own sets. So
one layout holds, and its names are Standard Kit 1's.
[`rhythm_drum_kit_keys.py`](mn10300-names-probes/rhythm_drum_kit_keys.py) prints each kit's notes,
the names per key and Standard Kit 1's map. The KN6000's table (`IK2.bin`) has the same voices in
the same order around Standard Kit 1's keys 18-37. The KN2400 and KN6500 tables were not checked,
so the siblings' fallback styles use the KN7000's names `[INFERENCE]`.

## Past the last style

The last style, Bluegrass, ends at `0x3FBAD3`. 16,794 non-erased bytes follow, which no table
reaches:

- `0x3FBAD3-0x3FBB9A`: the end of an event stream whose start is overwritten.
- `0x3FBB9A-0x3FF9B0`: ten whole variation records, 4,1,1, 4,1,1, 4,4, 6,6 bars of 4/4. None of
  their streams occurs anywhere else in the chip. `[INFERENCE]` In the slot order that
  every style here uses, these are slots 6-11, 14, 15, 18 and 19 of a style that is not in this
  build: Var3 to Var4Fill2 and the four endings. The fragment before them is the end of that
  style's slot 5. The source labels them `OldBuildStyle_Var3` ... `OldBuildStyle_Ending2Minor` and
  types their headers like any other variation's.
- `0x3FF9B0-0x3FFBE6`: a stream fragment that starts inside a note event.
- `0x3FFBE6-0x3FFC6D`: the last 135 bytes of that fragment, again.

So the chip was mastered over an image of an earlier, longer build. The boot ROM shows the same
thing in its first kilobyte ([`ic18-boot-rom.md`](ic18-boot-rom.md), "The older link").

## The version string

`"jkr_33.ssf"` at `0x3FFFE8`, then 6 NULs and 8 bytes of `0xFF`. `AcRhythmVerBoxProc`
(0x4848895F) takes the probed window, subtracts 0x10000, adds 0x3FFFEC, reads the decimal digits
there and prints them with `"RHYTHM  : %4d"` (0x485D6800): RHYTHM 33 on the SP7001 DEBUG TOOLS
screen. The boot ROM can rewrite this data on units with an IC20 flash in this site: update kinds
8/9 (`KN7KR1`/`KN7KR2`, CS0 in two 2 MB halves) and `KN7KRHY.DAT` on SD
([`ic18-boot-rom.md`](ic18-boot-rom.md)).

## Representation

| part                                    | form in the source                                                            | bytes     |
|-----------------------------------------|-------------------------------------------------------------------------------|-----------|
| header, count block, index, tables      | `rhythm.s`: `.ascii`, `.be16`/`.be24` with label differences, `sidx_*`        | 4,678     |
| 169 style records                       | `styles/*/*.s`: `.ascii` name, `style_units`, 8 x `style_part`, `style_slots` | 33,462    |
| 3,380 variation headers + set-up events | `var_head`, set-up events, `var_events`, `var_end`                            | 117,229   |
| 3,380 event streams                     | one event per line                                                            | 3,955,326 |
| 8 count-in patterns                     | `rhythm.s`, typed the same way                                                | 364       |
| the leftovers                           | `old_build.s`: 10 variations and 3 fragments, the same way                    | 16,794    |
| erased flash, the version string        | `.space ..., 0xff`, `.ascii`                                                  | 915       |

The probe prints these byte counts ("bytes by representation"; they add up to the 4,128,768
bytes from 0x10000). With `--source src/ic18` it measures the text: 171 files (169 style files), 760,253 lines,
21,118,597 bytes of text for the 4,128,768 bytes from 0x10000, 5.11 times the binary size, and
0 `.incbin` lines. Until 2026-11-02 it was 14,378,065 bytes (3.48 times). The note rules and the
drum keys are now spelled by name (`NcrRootShiftOnly`, `KitHiHatClosed`), and that adds the
6.7 MB.

`python3 scripts/analysis/data_incbin_census.py` gives the tree `kn7000-ic18` no binary include
at all: 0 generic, 0 opaque.

**A fragment that begins inside an event.** `fragment_lines` in the generator writes the shortest
prefix after which the rest parses to the fragment's end as the styles' streams do (a position
byte is followed by an event, positions rise within a beat) as `.byte`, with a comment: 2 bytes
for `OldBuildFragment1`, none for the other two fragments. Those 2 bytes are the end of an event;
the byte after them, 0, reads as a position but could as well be the event's last byte.

**kn7asm.** This tree needed three additions to `tools/kn7asm.py`: `.be16` / `.be24` / `.be32`;
`.macro` / `.endm` with named parameters, where `\p` is replaced by the argument and `\s_X`
pastes a suffix; and caches that make 760,000 lines of macro invocations fast. A macro whose
body is only data directives is compiled once, an invocation whose operands are numbers,
operators and constant `.equ` names becomes its bytes once and is reused in every pass, and
constant expressions are evaluated once. Assembling all of IC18 took 18 s (13 s with the label
seed of a previous build) on the development machine. With the named spelling, `rhythm.s` alone
assembles in 30 s where the earlier text took 21 s, both measured on 2026-11-02 on the same loaded
machine, and `make verify-ic18-full` took 33 s. No other image's bytes change.

## Open questions

Settled on 2026-11-02 (lane mn10300-names, agent `rhythm`; the probes are in
[`mn10300-names-probes/`](mn10300-names-probes/), prefix `rhythm_`):

- the count block's bytes after the 220 and the style byte at +0x89: no reader in program 941 or the
  KN2400 / KN6000 / KN6500 programs; the source marks them unread;
- the part set-up's CC97 / CC94 / CC96 / CC80-CC83 / CC92: octave fold, DIGITAL EFFECT, bend range,
  the two-band part EQ, MULTI EFFECT depth (above);
- the two sound-unit keys: the DSP presets of units EFF4 and EFF5;
- the A/B halves of the intros and endings: major and minor, chosen by the chord type; and the slot
  order, which had intros and endings wrong;
- a note's last three bytes: the gate in ticks and the note-conversion rule;
- the drum keys' names: Standard Kit 1's, one layout over the kits;
- 0x484335BF returns a count-in pattern record: renamed `StyleCountInRecordGet` (was
  `StyleVariationNameGet`).

Settled on 2026-11-06 (lane kn7000-names; probes in
[`ic18-rhythm-rom-probes/`](ic18-rhythm-rom-probes/), prefix `rhythm_`):

- `ToneKeyFind`'s fallback for the ten kit sounds the internal archive has no tone for: the LSB-0
  kit of the same program, {34, 0} -> Jazz Kit, {127, 0} -> Standard Kit 1 (N-83177c3d, "Drum
  keys");
- what each NoteConvRules table does to a key: every branch of `NoteConvApply` and all 21 tables
  (N-c052c027, "What the conversion tables do");
- the part EQ's coefficients reach the per-voice TG register classes 0x40000000-0x50000000
  (`TgVoiceReg4000GroupWrite`), and a variation's bytes +2/+3 are the parts of DSP units EFF4 /
  EFF5, with their SOUND DSP switch and depth (N-e779328f, the part set-up and "A variation record").
  What the TG does with those coefficient words needs its datasheet; key 0xB048 has no literal
  reader (`[INFERENCE]` above).

Still open:

- which chip answers at the IC18/IC20 site of the owner's unit has not been checked (see the dump's
  README).

## Website page draft

> **KN7000 rhythm data (IC18)**
>
> The KN7000's 4 MB rhythm ROM (IC18, C3CBND000046, or an IC20 flash on early units) starts with
> the 64 KB boot ROM. The rest is one resource, "Technics Rhythms", at CPU address 0x40010000. All
> its multi-byte fields are big-endian, although the CPU is a little-endian MN10300.
>
> - **Header**: the signature, a 16-bit sum of the middle 2 MB, and the offsets of the count
>   block (220 rhythms), the style-ID index, the style table and the count-in table.
> - **Style-ID index**: 2048 entries, one per folded style-ID. Of the 220 built-in rhythms, 169
>   are in IC18 and 51 in the table ROM. The other 1828 IDs alias to one of these.
> - **Styles**: 169 records. Each has a 13-character name, the DSP presets of effect units EFF4
>   and EFF5, and eight part set-ups (Drum, Bass, Acc1-5, Perc). A set-up is 15 controller values:
>   the sound, volume, reverb, chorus, pan, bend range, a two-band EQ, the digital-effect switch,
>   the multi-effect depth and an octave fold point for chord transposition. Each record then has
>   20 slot offsets: four variations, each with two fill-ins, then INTRO 1, ENDING 1, INTRO 2 and
>   ENDING 2, each in a major and a minor version, which the firmware picks by the chord played.
> - **Variations**: bars and meter, set-up events (controllers and program changes per part),
>   then an event stream. In the stream a position byte (0-95, 96 ticks a beat) precedes notes,
>   controllers, pitch bends, beat markers (0xF4) and the end (0xF5). A note is 6 bytes: key,
>   velocity, gate time in ticks, and one of the firmware's named note-conversion rules ("Root
>   Shift Only", "Melody Basic", "Basic Chord 100%" ...). Drum keys follow the layout of the
>   KN7000's Standard Kit 1.
> - **Count-ins**: eight one-bar rim-shot patterns, of 1 to 8 beats. With COUNT INTRO on, the
>   program plays its own spoken count ("Count 1" to "Count 4" of the Voice Kit) for 1 to 4 beats.
> - The chip ends with leftovers of an older build and the version string `jkr_33.ssf` (RHYTHM 33).
>
> The disassembly rebuilds all 4 MB byte for byte (`make -C kn7000 verify-ic18-full`), with
> every record and every event typed, one file per style. Source: `kn7000/src/ic18/rhythm.s`; format notes:
> `kn7000/notes/ic18-rhythm-rom.md`.
