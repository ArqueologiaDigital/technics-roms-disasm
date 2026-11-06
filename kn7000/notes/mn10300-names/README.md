# Lane mn10300-names (2026-11-02): names, RAM / I/O addresses, IC18 boot ROM, tables, behaviour

Wave 6 of the open-items work (`notes/open-items/REGISTER.md`).  This lane took the KN7000 and
MN10300-sibling rows about names, RAM / I/O addresses, the IC18 boot ROM, the table ROM and
firmware behaviour; lane mn10300-data took data typing (`gen_data_s.py`, `data_readers.py`,
which this lane did not edit).  The research was split into seven parts by subject; each
part's evidence is in the note that listed its items (named per section below), and its
probes are in `../mn10300-names-probes/` (README there) or beside that note.  This README
says what was settled where, and what is still open.

## Tools changed

| tool                                                   | change                                                                                                                                                                                                                    |
|--------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `tools/gen_symbols.py`                                 | `--code-range LO:HI:LINK`: a reflection-table pointer into a RAM-linked range is code, named at its link address (the KN2400's `make symbols` passes its range; same output)                                              |
| `tools/port_names_by_code.py`                          | `--also-a LABEL ROM BASE CODES SYMS` (repeatable): after the primary image, carry names from further images into what is still unnamed; rows say `= LABEL 0x...`; without it the output is byte-identical to the old tool |
| `tools/gen_image_s.py`                                 | `--sfr-inc FILE`: registers by name (`NAME`, `NAME+1..3`); a `--sym` name of an address outside the image (a RAM variable) spells that exact address                                                                      |
| `tools/gen_program_s.py`                               | the same register spelling for the four KN7000 builds (both includes); no GUI event-id spelling in the library image (its id-valued immediates are TG register classes)                                                   |
| `tools/check_sfr_names.py`                             | new: the includes and `src/ic18/boot.s` must give each register one name (run by `make symbols-check`)                                                                                                                    |
| `src/include/mn103002a_sfr.inc`                        | new, hand-written: the MN103002A's on-chip registers and the `0x360080xx` board latches, with evidence per block                                                                                                          |
| `src/include/kn7000_board_io.inc`                      | new, hand-written: the KN7000 board's FDC, tone-generator ports, SD SPI, power controller, strap, LCD controller (from the IC18 boot ROM's rows)                                                                          |
| `tools/gen_wave_s.py`                                  | recordings cut where their records end (`_RunOut`, `.space` gaps), the reversed entry spelled                                                                                                                             |
| `tools/gen_table_styles.py`, `tools/table_segments.py` | the ZZZJ / pad comments, `.align 4, 0x00` after the last pad                                                                                                                                                              |
| `floppy/tools/kd/gen_panel_macros.py`                  | PMR field names `conductor`, `left_hold_on_bass`, `pad_volume`                                                                                                                                                            |

## Register names (N-4a4e97bc, N-5cad02df, N-82a73a67: the I/O half)

Evidence per block is in the include's header:

- the MN1030 instruction manual's interrupt example (IAGR, IVARn, G0ICR, G3ICR);
- the Linux MN10300 port's `timer-regs.h` / `serial-regs.h`.  The MN103E010's timer and serial
  blocks sit at `0xD4003000` / `0xD4002000`, and every offset the firmware uses is a register
  there: `+0..3`, `+0x10..13`, `+0x71`, `+0x80/82/84`, `+0x90/92`, `+0xA2`, `+0xB4/B5`, `+0xC4`,
  `+0xD4`; serial `+0/4/8/9/C` per channel.  [INFERENCE] that the MN103002A has the same layout;
- the IC18 boot ROM;
- kn7000_mame.

`0x32000010` and `0x34004002` stay `UNKNOWN_*`: no MN103002A LSI manual is at hand (BLOCKED).
Device bases that only appear as immediates (`0x30000000`, `0x38000000`, `0x38100000`,
`0x36900000` and the like) are not named.  The siblings' own board devices (KN2400 `0x98020004`
and so on) are not named either: nothing shows they are the KN7000's devices.

## Names

- `TgcBufWrite` (was `SndCmdStreamWrite`, N-ccdc980d): the firmware's own name, from 942's
  plug-in export table (`IDNAME FN_TgcBufWrite`) and the KN6000 / KN6500 reflection tables.
- The SD-card reflection table question (N-01128b1c): the KN2400's table was the one paired
  wrongly.  Its identifier run (90) is shorter than its registered count (111).
  `gen_symbols.py`'s start alignment fixed it on 2026-10-29 (8037f3750), after the 2026-10-24
  audit that showed the disagreement.  Since then KN2400 `SdcNewPlaylistInfoFunc` 0x48718C9E is
  the KN7000's `SdcNewPlaylistInfoFunc` 0x4855BAC5.  `names_reflection_table_dump.py` prints
  both tables' pairing; the KN7000's (81 names, 81 code pointers) is end-to-end aligned.
- KN2400 RAM-linked procedures (N-e7ed1928): no reflection table names one
  (`names_kn2400_ram_tables.py`).

## Where each item was settled

The evidence is in the note named; this table is the index.  Outcomes: CLOSED, BLOCKED (with the
blocker) or OPEN (with the next step).

| item                                                                   | outcome             | where                                                    | in one line                                                                                                                |                                   |
|------------------------------------------------------------------------|---------------------|----------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|-----------------------------------|
| N-01128b1c                                                             | CLOSED              | this README, `../sibling-name-port/`                     | the KN2400's SD-card table was the mispaired one; fixed by start alignment (8037f3750); the re-run audit agrees            |                                   |
| N-ccdc980d                                                             | CLOSED              | `kn7000_manual.sym`                                      | `TgcBufWrite`, the firmware's own name (942 export table, KN6000 / KN6500 reflection)                                      |                                   |
| N-1af8fb95                                                             | CLOSED              | `../ic18-rhythm-rom.md`                                  | `StyleCountInRecordGet` / `StyleCountInBoundGet`: the count-in pattern record, not a variation name                        |                                   |
| N-e7ed1928                                                             | CLOSED              | `../../../kn2400/README.md`                              | no KN2400 reflection table names a RAM-linked procedure; `gen_symbols.py` takes the range anyway                           |                                   |
| N-345ce6f1                                                             | CLOSED              | `../../../kn2400/notes/data-region/README.md`            | `RamSectionsCopy`: two 12-byte records, 0x6DFFA bytes to 0x50120000 and a 3-byte stub                                      |                                   |
| N-439d5da2                                                             | CLOSED              | `../../../kn6000/notes/data-region.md`                   | the COMPUTER CONNECTION diagram and its three overlays (KN6000, KN6500)                                                    |                                   |
| N-986ec818                                                             | CLOSED              | `../../../kn2400/notes/data-region/README.md`            | `_TT_CTHOMEPAGE` / `_TT_VDOUT` keep the default record: never registered                                                   |                                   |
| N-0a03a134                                                             | CLOSED              | `../../../kn6000/notes/data-region.md`                   | bitmap pixel order traced; the record accessors are the KN7000's layout (see the porting section for the rest)             |                                   |
| N-b318c54c                                                             | OPEN                | `../../../kn6000/notes/siblings-data-final/README.md`    | conductor, left hold, pad volume named; PM_SET88's `m008008` (from latched panel control 0xC6) is not                      |                                   |
| T-kn2400/6000/6500-todo, T-kn7000-todo (+0x89)                         | CLOSED              | `../ic18-rhythm-rom.md`                                  | +0x89 has no reader in any image (`rhythm_style_record_readers.py`); written `unread`                                      |                                   |
| T-kn7000-todo (IC18 SdFrameR2Cmd0)                                     | CLOSED              | `../ic18-boot-rom.md`                                    | mode-2 frames {clock mode, response type, 0x40\                                                                            | n, arg, CRC}; only R2Cmd0 is used |
| the IC18 boot TODO groups                                              | 9 CLOSED, 3 BLOCKED | `../ic18-boot-rom.md`                                    | see "IC18 boot ROM" below                                                                                                  |                                   |
| N-271d0bab, N-719cf65f, N-71feb370, N-a504af0f, N-a883f3f0, N-f5cfab22 | CLOSED              | `../ic18-rhythm-rom.md`                                  | gate + rule; kit key names; set-up controllers; intro / ending halves are major / minor; unread bytes; DSP keys            |                                   |
| N-44a0a9c3, N-79b9c8d3, N-564dcd72, N-cbaf135a                         | CLOSED              | `../wave-roms-2026-10-29.md`                             | the Reverse Cymbal (P bit 9); where recordings end; the page order; no release segment                                     |                                   |
| N-cc575880                                                             | BLOCKED             | `../wave-roms-2026-10-29.md`                             | P bit 12 is set in all 3,974 entries and read by no firmware code: needs the TG datasheet                                  |                                   |
| N-a0f81837                                                             | BLOCKED             | `../wave-roms-2026-10-29.md`                             | each split value is one granule in 1/8-octave steps; what the chip does with it needs the datasheet or a recording         |                                   |
| N-a39cce89, N-c7bd31b3, N-652c2321, N-68397a99, N-c94956b2, N-cc77e1d6 | CLOSED              | `../work-ram-map.md`                                     | RamInitMarker; 0x800 boot stack; slot slack; WPAL1 / WPAL2; unused .bss tail; the pool's last word                         |                                   |
| N-44e56012                                                             | OPEN                | `../work-ram-map.md`                                     | what keeps the keys silent on PICTURE LOAD: not the disk phase, ext mode or SD module; next: the key path into TgcBufWrite |                                   |
| N-1666f99a, N-716ca83b, N-c62a74fa                                     | CLOSED              | `../gui-data-region/README.md`, `../data-rest/README.md` | field D is a byte; rects are inclusive; no MT_GetBitCount answer = 4 bpp                                                   |                                   |
| N-b68f78f0                                                             | CLOSED              | `../table-semantics-2026-10-29.md`                       | the USER HP pictures are half their part views' boxes                                                                      |                                   |
| N-fb88572c                                                             | OPEN                | `../gui-data-region/README.md`                           | design written (a frozen `gui_object_names.tsv` read by `obj_names()`); implementing it is `gen_data_s.py`'s lane          |                                   |
| N-3d2fa559, T-kn7000-todo-what-the                                     | CLOSED              | `../table-semantics-2026-10-29.md`                       | 'ZZZJ' = the SOUND ARRANGER's factory settings, one record per preset rhythm                                               |                                   |
| N-8ef7dde2                                                             | CLOSED              | `../table-semantics-2026-10-29.md`                       | no routine reads or writes part_more's 9 bytes, so the program cannot give their order                                     |                                   |
| N-34fa7d2c                                                             | OPEN                | `../table-semantics-2026-10-29.md`                       | flags, source ids, record key, effect parts found; the rest has no static reader: next, a MAME write-watch                 |                                   |
| T-kn7000-todo-after-the, -whether-the                                  | CLOSED              | `../table-semantics-2026-10-29.md`                       | the 0x00 aligns segment 5; no Feature Demo script shows the placeholders                                                   |                                   |
| N-8b2b22bb, N-b562cfc1                                                 | CLOSED              | `../presentation-control-probes/song-records.md`         | tempo 250 is a lead-in bar in plain BPM; 0x80 recalls the memory; SysEx is source 3 and is recorded                        |                                   |
| N-8af92404                                                             | OPEN                | `../presentation-control-probes/song-records.md`         | type 4 = 47 handshake / dump-request descriptors; payload formats: trace func_484C34ED .. func_484C364E                    |                                   |
| N-f839ba10                                                             | OPEN                | `../presentation-control-probes/song-records.md`         | 8 more ids named; the remaining ids listed with the next step (their widgets' SetMmmFilter)                                |                                   |
| N-1ad3d4d4                                                             | CLOSED              | `../older-program-builds.md`                             | the block is 0x4840AE62..0x4840B696 in 935 / 893; all 35 routines named (`kn7000_b935_own.sym`, `_b893_own.sym`)           |                                   |
| N-90175c82                                                             | OPEN                | `../older-program-builds.md`                             | SD part closed (six mis-ported names corrected); 7 of 893's 40 own routines unnamed (listed)                               |                                   |
| T-kn7000-todo-purpose-unknown                                          | CLOSED              | `../older-program-builds.md`                             | the byte after 893's loader descriptor is read by nothing                                                                  |                                   |
| N-d753af29                                                             | OPEN                | `../sp7001-build-diff.md`                                | 1,316 of 1,340 BASEEXT.XAP indirect calls resolved; 24 listed with the next step                                           |                                   |
| N-4a4e97bc, N-5cad02df, N-82a73a67                                     | OPEN                | this README                                              | the I/O half is done (registers by name in every tree); the RAM half is not (counts below)                                 |                                   |
| N-f3294592, N-9eca4678, N-be2b9da5                                     | see below           | this README                                              | sibling-to-sibling porting is done; what is left is per-subsystem naming                                                   |                                   |

## IC18 boot ROM (`../ic18-boot-rom.md`)

Settled: PanelBusyPumpCount's unit (pump calls), the copy descriptor's unread 0x8001 word,
PanelLinkConst7D / the TickHook words (write-only / a debug hook), TGA_KEY_FIFO / TGA_INIT,
FatMountFailImage (never used), TickJobs' consumers (941's TickJobsTask), PanelLastFrame*,
the font header's +4 / +6, SdUpdateVerify.  BLOCKED: `0x32000010` and `0x34004002` (the
MN103002A LSI register manual is not at hand; only the MN1030 instruction manual is), and the
update lamps' device (on no page of the service manual; the factory jig on CN106).  The
boot ROM's TODO markers went from 16 to 3.

## Sibling-to-sibling names (N-f3294592, N-9eca4678, N-be2b9da5)

`make ported-names` in each sibling now runs `port_names_by_code.py` from KN7000 941 first and
then, with `--also-a`, from the two other siblings' reflection and hand names (not their
`*_ported.sym`, which came from the KN7000):

| image  | from 941 (signature + whole body) | then from the siblings  |
|--------|-----------------------------------|-------------------------|
| KN6000 | 694 + 84                          | +0 (KN6500 0, KN2400 0) |
| KN6500 | 710 + 84                          | +9 (KN6000 9, KN2400 0) |
| KN2400 | 656 + 89                          | +1 (KN6000 1, KN6500 0) |

A direct KN2400 -> KN6000 run (KN2400 as the only source) carries 0 as well.  The siblings
hold names the image lacks (142 KN6500 names the KN6000 does not have, 1,208 KN2400 ones), but
those are their own code (help text, KN2400-only screens); everything they share is already
named through the KN7000.  So the porting items are CLOSED with that measurement, and what
is left in every sibling is per-subsystem naming (the `func_` counts in each README): OPEN,
next step per subsystem from callers, strings and MILK messages, as for 893 in
`../older-program-builds.md`.

The re-run of `port_sibling_names.py` (sibling names into the KN7000) also found that the
2026-10-29 start alignment had shifted three KN6000 / KN6500 reflection tables;
`gen_symbols.py` now takes the code-array start the registering call loads
(`../sibling-name-port/README.md`), and the audit's `wrong` picks are KN2400 1, KN6000 0,
KN6500 0.

## RAM addresses (the other half of N-4a4e97bc, N-5cad02df, N-82a73a67)

Every on-chip register operand is now a name in the four sibling trees and the four KN7000
builds; what stays a number in I/O space is chip-select base addresses (`0x36900000`,
`0x38000000`, `0x38100000`) and float constants.  RAM is another matter: the sibling sources
still hold 19,019 (KN6000), 19,055 (KN6500) and 22,483 (KN2400) numeric RAM operands, over
2,944 / 2,954 / 3,521 distinct addresses (HD-SX3: none; counted after merging lane mn10300-data).  The KN7000 itself names only a few
dozen RAM variables (`kn7000_manual.sym`; work-ram-map.md's census has 4,130 addresses), so
there is little to port yet.  The mechanism is in place: `gen_image_s.py` spells any
`--sym` name of an address outside the image, as `gen_program_s.py` already did, so a RAM
name in a `*_manual.sym` file now reaches the code.  Next step (OPEN): name the KN7000's RAM
variables by subsystem from work-ram-map.md's census, then carry them to the siblings along
the routine pairs `port_names_by_code.py` already matches (the two routines' operands line
up instruction by instruction).

## Left for lane mn10300-data (files this lane did not edit)

- `gen_data_s.py` `PROFILES["b935" / "b893"]["syms"]`: append `kn7000_b935_own.sym` /
  `kn7000_b893_own.sym`, so the data labels use those builds' own names (RAM rows,
  LibLoadDescriptorTail).
- `gen_data_s.py`: name the KN2400's unregistered titles from TitleNameTable (the research
  agent's diff, not applied: `title_names=(0x48414BD8, 0x140)`); InitModeTitleTable's
  28-byte default record is typed as one word plus 24 opaque bytes.  (2026-11-06, lane
  kn7000-names: the default record is typed now, `TitleDefaultRecord`, 7 x u32; the 25 titles
  to name are listed by `../kn7000-names-probes/names_kn2400_titles.py`; BLOCKED in wave 10 only
  because `gen_data_s.py` was lane mn10300-data2's, `../kn7000-names/README.md`.)
- `gen_data_s.py`, near the bitmap bit-count comment: drop the `[INFERENCE]` (N-c62a74fa).
- N-fb88572c's frozen name map (design in `../gui-data-region/README.md`).
- ~~941's data labels `SdReadBlockCmd_Var_2` / `SdReadBlockCmd_Table` are the mode-2 SD frames
  at 0x50007E94.. (the IC18 SdFrameR2Cmd* table's twin); `func_484ABA68_Var..` are TickHookArg0..3.~~
  (Resolved 2026-11-06, lane kn7000-names: named in `kn7000_manual.sym`, `SdFrameR2Cmd0/5/3/6/7`
  and `TickHookArg0..3`; the data labels follow at the next `make data-and-code-src`;
  `../kn7000-names/README.md`.)

## Website page draft

*For the technics-docs KN7000 pages (another process publishes them; text only).*

**Registers by name.** Every MN10300 source in the tree (the KN7000's four program builds, the
KN2400/KN2600, KN6000, KN6500 and HD-SX3) now spells the on-chip registers by name: the
interrupt controller (G0ICR..G31ICR, IAGR, EXTMD), the three serial ports (SCnCTR / ICR / TXB /
RXB / STR), the timers (TMnMD / BR / BC, TM6, TMPSCNT), the bus and memory controller
(MEMCTR0..7), DMA channel 0, the cache controls and the 0x360080xx board latches (P04..P84).
The names come from the MN1030 instruction manual's own example, from the Linux MN10300
port's register headers (the same timer and serial blocks at 0xD4003000 / 0xD4002000 there),
and from the IC18 boot ROM.  The KN7000 program builds also name the board's floppy
controller, tone-generator ports, SD-card SPI port and LCD controller.  Two registers stay
unnamed until an MN103002A register manual turns up: 0x32000010 (written 0x400 first in the
bus set-up) and 0x34004002 (written 0 after MEMCTR0).

**Count-in.** The KN7000 can start a style with a one-bar count-in: a rim-shot click from
the rhythm ROM, one per meter of 1 to 8 beats, or, with COUNT INTRO on, the program's spoken
"Count 1" to "Count 4" on the Voice Kit.

**Style notes.** A style note is six bytes: status, key, velocity, a gate time in ticks (two
7-bit bytes) and a note-conversion rule.  The rule indexes a firmware table whose entries
carry names such as "Root Shift Only", "Melody Basic" and "Basic Chord 100%"; rule 0, used
on every drum note, leaves the key alone.  Each style has two intros and two endings, each
in a major and a minor version; the minor one plays for a minor-family chord, and the
firmware switches version mid-pattern when the chord changes.  Each part's set-up gives its
sound, volume, reverb, chorus, pan, a 12-semitone bend range, a two-band EQ, the
digital-effect switch, the multi-effect depth and an octave fold point for transposition;
each style also picks presets for DSP effect units 4 and 5 ("Limiter1" usually).

**Drum keys.** The kits share Standard Kit 1's layout: GS from 27 to 87, plus hi-hat on / off
beat (18-19), hi-hat accent and half-open (20-21), piccolo snare (24), shaker and maracas
on / off beats, and six cowbells (111-116).  Key 37 is a rim shot.

**The Sound Arranger.** Table segment 1 ('ZZZJ') holds the SOUND ARRANGER's factory settings:
for each of the 220 preset rhythms, one replacement sound per accompaniment part, copied to
battery SRAM.

**Wave ROMs.** A directory entry gives where a recording starts; its record gives where it
ends: a looped recording ends 32 samples after its loop end, and those 32 samples repeat the
loop's start.  There is no release segment.  One entry, the Reverse Cymbal, plays the ride
cymbal backwards (P bit 9).

**Start-up.** The first 16 bytes of work RAM are a reserved header with a "RAM initialised"
marker at 0x5000000E: a power-on factory reset wipes RAM and SRAM, sets it to 0x5AA5 and
restarts.  The reset code runs on a 2 KB stack below 0x50021CF8.  The KN2400/KN2600 copies its
RAM-linked tone-generator library itself (RamSectionsCopy, two 12-byte records at the end of
the image).

## Found on the way, not fixed here

- (Resolved 2026-11-06, lane kn7000-names: `port_symbols.py` takes INITIAL_SP from the reset's
  stack load, `../kn7000-names/README.md`.)  `src/b935/symbols.inc` sets `INITIAL_SP` to 941's 0x50021CF8, but 935's reset loads
  0x50021CCC (`notes/mn10300-names-probes/ramgui_reset_layout.py`); in 935 the name only spells
  `add INITIAL_SP, a0`, where the value is the base of 0x42-byte records, not the stack.
  `tools/port_symbols.py` moves a RAM name by the majority vote of the references near it, and
  the stack top moved -0x2C while its neighbours did not.  Next step: port the memory-map
  constants a build's reset code loads (INITIAL_SP) from that code, not by the vote.
- (Resolved 2026-11-06, lane kn7000-names: `_entry` labels are candidates now,
  `../kn7000-names/README.md`.)  `tools/port_names_by_code.py` takes B's candidates from its `func_<ADDR>` labels, which sit
  at an `add -N, sp` prologue; a name 941 gives the call entry 3 bytes later never matches,
  which is why 941's four DSP host-port names never reached 935 / 893
  (`../older-program-builds.md`).  Next step: compare a `_entry` name with the entry of B's
  prologue routines.
- KN2400 `FilePriorityFunc` and the KN7000's `SdcPanelSwAsFunc` are the same routine by body;
  both names come from reflection tables (`../sibling-name-port/README.md`).  (Resolved
  2026-11-06: both are right, a template twin with different choice lists.)
- The IC18 rhythm source grew from 14.4 MB to 21.1 MB when every note began to spell its
  conversion rule and every drum note its kit key; emptying `NCR_NAMES` in
  `tools/gen_ic18_rhythm_s.py` would save about 5.6 MB.  The owner decided on 2026-11-06 to keep the names ("keep the names. Yes!"),
  so `NCR_NAMES` stays.
