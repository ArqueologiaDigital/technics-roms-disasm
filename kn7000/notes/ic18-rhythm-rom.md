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
is read: it is the rhythm count, and it bounds the index's style and table-ROM entries. The rest is
`[INFERENCE]`, and nothing reads it:

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
to program `00 00 26`. On every beat it plays a note 37 (side stick in GM numbering) at velocity
64. `StyleRecordSlotSelect` (0x48433643) uses one of them for slot 20, through
`StyleVariationNameGet` (0x484335BF). The low 3 bits of the bound variation's meter byte pick
which. The firmware takes its own table 0x48736078 instead when resource 0xD00A answers.
`StyleVariationNameGet` is therefore misnamed: it returns a count-in pattern record, not a name.
The source types these 8 patterns like any variation.

## A style record (0xC6 bytes)

`StyleNameCommit` (0x484334A4) and `func_484420EF` read the record:

| offset  | size   | field               | evidence                                                                           |
|---------|--------|---------------------|------------------------------------------------------------------------------------|
| `+0x00` | 13     | name, as displayed  | copied to the name buffer `0x50034B9C` and NUL-terminated there                    |
| `+0x0D` | 4      | two sound-unit keys | `0x50034C20`; `func_484420EF` decodes them (below)                                 |
| `+0x11` | 8 x 15 | eight part set-ups  | `0x50034BAC[i] = record + 0x11 + 15i`; `func_4844187A` copies them to `0x5003A37C` |
| `+0x89` | 1      | 1 in every style    | TODO: no reader found                                                              |
| `+0x8A` | 20 x 3 | slot offsets        | u24BE, from the record; `0x50034BCC[slot]`                                         |

**Sound-unit keys.** `func_484420C8` decodes each 2-byte pair as a 14-bit value, 7 bits a byte, low
byte first. Bit 6 of the second byte adds 0x10000. `func_484420EF` stores the first pair to
parameter key 0xB044 and the second to 0xB054. Bit 7 of the first pair's second byte goes to key
0xB001. Keys 0xB040/0xB050 are the last two sound-unit groups (`SndUnitRefreshGroups56`
0x48410D35). 88 styles have `44 00 44 00`; the source gives the four bytes as they are
(`style_units`).

**A part set-up** (15 bytes, `style_part`). Byte `k` is the value of field `k` of the firmware's
part-field table 0x485B77D4. That table holds one (status, controller) pair per field.
`StyleRecordToTemplate` (0x48441D1B) and `func_48441EB4` map an incoming controller to its field
through 0x485B789C / 0x485B781C.

| byte | controller | name in the source             | values over 169 x 8 parts                                                                |
|------|------------|--------------------------------|------------------------------------------------------------------------------------------|
| 0    | CC97       | `mode`                         | `0x00` on parts 0 and 7 of all 169 styles; `0x08` on the others but 8 parts              |
| 1    | CC7        | `volume`                       | most often 105, 98, 127, 100                                                             |
| 2-4  | program    | `prog`, `bank_lsb`, `bank_msb` | the program change's data bytes; `bank_msb` 0x26 on parts 0 and 7, else 0x20 but 4 parts |
| 5    | CC94       | `cc94`                         | 64 in every part                                                                         |
| 6    | CC91       | `reverb`                       |                                                                                          |
| 7    | CC93       | `chorus`                       | 0 in 1221                                                                                |
| 8    | CC10       | `pan`                          | 64 in 929                                                                                |
| 9    | CC96       | `cc96`                         | 12 in every part                                                                         |
| 10   | CC82       | `cc82`                         |                                                                                          |
| 11   | CC83       | `cc83`                         |                                                                                          |
| 12   | CC80       | `cc80`                         |                                                                                          |
| 13   | CC81       | `cc81`                         |                                                                                          |
| 14   | CC92       | `cc92`                         | 0 in 1259                                                                                |

Fields 15-23 of the table (CC64, CC1, CC11, channel pressure, pitch bend, CC16, CC17, CC13) are not
in a style's set-up. They start from the default template 0x485B7804.

`[INFERENCE]` The eight parts are Drum, Bass, Acc1-Acc5 and Perc. Parts 0 and 7 have mode 0 and
`bank_msb` 0x26 in every style. Every note on those two parts has a last byte of 0, unlike the notes of the other
parts. Part 1's program is 0x21 in 84 of the 169 styles, which is GM's finger bass. The names of the two bank bytes
are a guess from their order.

## The 20 slots

| slots | name in the source                               | bars                      | evidence                                                                                                                           |
|-------|--------------------------------------------------|---------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| 0-11  | `Var1`, `Var1Fill1`, `Var1Fill2` ... `Var4Fill2` | 4, 1, 1 in all 169 styles | only `slot % 3 == 0` carries a name in a MEMORY style (`MemStyleVarCopy` 0x4843B22E); `func_4844232B` treats `slot % 3 != 0` apart |
| 12-15 | `Intro1A/B`, `Intro2A/B`                         | 1-9                       | `func_4844232B` treats `(slot - 12) % 4 < 2` (12, 13, 16, 17) apart from 14, 15, 18, 19                                            |
| 16-19 | `Ending1A/B`, `Ending2A/B`                       | 2-10                      | the same; the odd slots are the B halves (`0x485B6D74`, the MEMORY pair bit)                                                       |

The two halves of each pair have the same bar count in every style. `[INFERENCE]` The roles are
main pattern, fill-in, intro and ending. They follow the panel's VARIATION 1-4, FILL IN 1/2 and
INTRO & ENDING 1/2 buttons, the bar counts (slots 12-15 shorter, 16-19 longer) and the count block.
What tells an A half from a B half is not known.

## A variation record

`StyleRecordBindBuiltin` (0x484336DB) binds the current one into the pattern player's view:

| offset     | size  | field                         | evidence                                                                                    |
|------------|-------|-------------------------------|---------------------------------------------------------------------------------------------|
| `+0`       | 1     | bars - 1                      | `0x50122DCE`; `StyleBoundRecByteCeInc` + 1 -> `0x5003A452` (`func_48442293`)                |
| `+1`       | 1     | beats a bar - 1               | `0x50122DCF`; `StyleBoundRecByteCfLow3` + 1 -> `0x5003A454`                                 |
| `+2`, `+3` | 1, 1  | two part numbers, 0xFF = none | `0x50122DD4`; `func_48442164` stores them as key 0xB048 [INFERENCE: the sound units' parts] |
| `+4`       | u16BE | set-up length L               | `0x50122DCC`                                                                                |
| `+6`       | L     | set-up events                 | `0x50122DC8`; replayed into the part table by `func_48441DEB`                               |
| `+6+L`     | u24BE | stream length S               |                                                                                             |
| `+9+L`     | S     | the event stream              | start `0x50122DC0`, end `0x50122DC4` = start + S - 1, the 0xF5                              |

Bytes 2/3 are `FF FF` in 2710 of the 3380 variations and `FF 02`-`FF 07` in the rest. The set-up
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

`[INFERENCE]` A note's last three bytes: the first two are its length (low byte 8-16 typically,
high byte mostly 0). The last is 0 on every note of parts 0 and 7 and takes a few values elsewhere
(1, 16, 80, 100 ...), so it reads as the chord-adaptation class. The player that reads them was
not traced.

**In the source**, one event per line, one macro per kind (defined in `rhythm.s`):

| macro                                                                 | bytes                          | used for                                                       |
|-----------------------------------------------------------------------|--------------------------------|----------------------------------------------------------------|
| `n part,key,vel,len_lo,len_hi,cls`                                    | `9n key vel len_lo len_hi cls` | a note; `len_lo`/`len_hi`/`cls` named by the inference above   |
| `vol`, `pan`, `expr`, `mod`, `sus`, `rev`, `cho`, `mode` `part,value` | `Bn CC value`                  | CC7, 10, 11, 1, 64, 91, 93, 97                                 |
| `cc part,ctl,value`                                                   | `Bn ctl value`                 | any other controller (CC80-83, 92, 94 in set-ups)              |
| `pc part,prog,bank_lsb,bank_msb`                                      | `Cn prog bank_lsb bank_msb`    | program change (set-ups only)                                  |
| `bend part,lsb,msb`, `pres part,value`                                | `En lsb msb`, `Dn value`       | pitch bend, channel pressure                                   |
| `@<any of the above> tick,...`                                        | `tick` then the event          | the event with the position byte before it                     |
| `beat`, `end`                                                         | `F4`, `F5`                     | beat marker, end of stream                                     |
| `at tick`                                                             | `tick`                         | a position byte with no event after it; not needed in this ROM |

So `@n 48,0,BD1,64,16,0,0` is a bass drum on part 0 at tick 48 of the beat. On parts 0 and 7 a
key from 27 to 87 is spelled by its GS/GM percussion name (`.equ BD1, 36` ...); other keys stay
numbers. `[INFERENCE]` That the KN7000's kits follow that map rests on table 84's drum-voice
records near file offset 0x1088D0, which list "Bass Drum 2", "Bass Drum 1", "Side Stick" and
"Snare Drum 1" in the GM order of keys 35-38. The kits' own records were not decoded, so their
names for the keys outside 27-87 (18 and 19 are frequent) are not used.

## Past the last style

The last style, Bluegrass, ends at `0x3FBAD3`. 16,794 non-erased bytes follow, which no table
reaches:

- `0x3FBAD3-0x3FBB9A`: the end of an event stream whose start is overwritten.
- `0x3FBB9A-0x3FF9B0`: ten whole variation records, 4,1,1, 4,1,1, 4,4, 6,6 bars of 4/4. None of
  their streams occurs anywhere else in the chip. `[INFERENCE]` In the slot order that
  every style here uses, these are slots 6-11, 14, 15, 18 and 19 of a style that is not in this
  build. The fragment before them is the end of that style's slot 5. The source labels them
  `OldBuildStyle_Var3` ... `OldBuildStyle_Ending2B` and types their headers like any other
  variation's.
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
bytes from 0x10000). With `--source src/ic18` it measures the text: 171 files (169 style files), 760,109 lines,
14,378,065 bytes of text for the 4,128,768 bytes from 0x10000, 3.48 times the binary size, and
0 `.incbin` lines.

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
constant expressions are evaluated once. Assembling all of IC18 takes 18 s (13 s with the label
seed of a previous build) on the development machine. No other image's bytes change;
`make gate-kn7000` passes.

## Open questions

- The count block's bytes after the 220 and the style byte at +0x89 have no reader. Their
  readings above are inferences.
- CC97 (part `mode`), CC94, CC96 and CC80-CC83: the firmware routes these controllers into part
  fields, but what each one does to the sound was not traced into the tone generator.
- The two sound-unit keys: what values 0x0044 (and 0x1111, 0x0B12 ...) select in units
  0xB040/0xB050.
- The A/B halves of the intros and endings. A major/minor pair would fit, but nothing shows it.
- A note's last three bytes: trace the pattern player that consumes `0x50122DC0` to fix the length
  and the class.
- The drum kits' own key names: table 84 has drum-voice records with names ("H.H.On Beat",
  "Reverse Snare" ...); decoding which kit and key each belongs to would name the keys outside the
  GS/GM range and confirm the map.
- `StyleVariationNameGet` returns a count-in pattern record. Renaming it (and its slot-20 caller's
  reading) is left to whoever next regenerates `src/program/`.
- Which chip answers at the IC18/IC20 site of the owner's unit has not been checked (see the dump's
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
> - **Styles**: 169 records. Each has a 13-character name, two sound-unit keys and eight part
>   set-ups (Drum, Bass, Acc1-5, Perc), each set-up being 15 controller values with volume, the
>   program, reverb, chorus and pan. Each record then has 20 slot offsets: four variations, each
>   with two fill-ins, then two intros and two endings, each as an A/B pair.
> - **Variations**: bars and meter, set-up events (controllers and program changes per part),
>   then an event stream. In the stream a position byte (0-95, 96 ticks a beat) precedes notes
>   (6 bytes), controllers, pitch bends, beat markers (0xF4) and the end (0xF5).
> - **Count-ins**: eight one-bar side-stick patterns, of 1 to 8 beats.
> - The chip ends with leftovers of an older build and the version string `jkr_33.ssf` (RHYTHM 33).
>
> The disassembly rebuilds all 4 MB byte for byte (`make -C kn7000 verify-ic18-full`), with
> every record and every event typed, one file per style. Source: `kn7000/src/ic18/rhythm.s`; format notes:
> `kn7000/notes/ic18-rhythm-rom.md`.
