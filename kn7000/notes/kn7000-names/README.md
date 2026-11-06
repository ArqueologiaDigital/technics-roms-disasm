# Lane kn7000-names (2026-11-06, wave 10): names, ported constants, IC18 rhythm, song records, floppies

Wave 10 of the open-items work (`../../../notes/open-items/REGISTER.md`).  The lane took 16
register items about names in the KN7000 and its MN10300 siblings, the IC18 rhythm data, the
song-record events, BASEEXT.XAP's indirect calls, the PICTURE LOAD screen and the stale bytes
of the KN6000 / KN7000 `.SQT` files.  Lane mn10300-data2 owned `tools/gen_data_s.py` and the
data-region sources in this wave, so the three items that need that file are handed over
(section "Handed over").  The probes of this README are in `../kn7000-names-probes/` (README
there); the other items' evidence is in the note that listed them.

## Tools changed

| tool                          | change                                                                                                                                                                                                                                         |
|-------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `tools/port_symbols.py`       | `RESET_LOADED`: `INITIAL_SP` takes the stack top the new build's reset code loads (its one `mov imm32, aN ; mov aN, sp`), `BootStack` that minus 0x800; the old build's value is checked against its own reset first                     |
| `tools/gen_program_s.py`      | the `mov X, aN` before `mov aN, sp` spells X as `INITIAL_SP` even where a manual name takes the same address for what lies above the stack (`DspPresetRamRecords` in 941 / 942)                                                               |
| `tools/port_names_by_code.py` | B's `func_<ADDR>_entry` labels (the call entry after an `add -N, sp` / `movm` prologue) are candidates too, so a name A gives the call entry is carried; with `--b-src` the entry's address is taken from B's decode (`prologue_entry`) |
| `floppy/tools/kd/kn_sqt.py`   | `stale_tokens` reads older-layer cuts, 0xFF fill and song-record copies (`../../../notes/floppy-leftovers-2026-10-31/README.md`, "layer cuts")                                                                                               |

## Items

| item                                | outcome | where                                                                     | in one line                                                                                                                       |
|-------------------------------------|---------|---------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| L-mn10300-names-b935-initial-sp     | CLOSED  | this README, `tools/port_symbols.py`                                      | INITIAL_SP 935 0x50021CCC, 893 0x50021CC8 (was 941's value / unported); the records above it named `DspPresetRamRecords`          |
| L-mn10300-names-port-entry          | CLOSED  | this README, `tools/port_names_by_code.py`                                | call entries are candidates; on 935 the rule finds DspFullReinit, DspWritePMWord, DspWriteDMWord (3 of the 4 hand-placed names)   |
| L-mn10300-names-sd-frame-labels     | CLOSED  | `kn7000_manual.sym`, `../kn7000-names-probes/names_sd_frames.py`          | SdFrameR2Cmd0/5/3/6/7 at 0x50007E94 + 10 k, TickHookArg0..3 at 0x4874D11C; the data labels follow at the next `make data-src*`    |
| L-mn10300-names-kn2400-titles       | BLOCKED | this README, `../kn7000-names-probes/names_kn2400_titles.py`              | 25 titles TitleNameTable names and gui_ids.inc lacks, listed; writing them is `gen_data_s.py` (lane mn10300-data2)               |
| N-89cedbdb                          | CLOSED  | `../sibling-name-port/README.md`, `names_choice_func_lists.py`            | both names right: one choice-parameter template, the string lists differ (TECHNICS/SMF vs SD-AUDIO/SD-SOUND)                     |
| N-61c32961                          | BLOCKED | `../callee-walk/README.md`, `../mn10300-data/README.md`                   | the indexed `sentinel_lists` form is `gen_data_s.py` (lane mn10300-data2)                                                        |
| N-fb88572c                          | BLOCKED | `../gui-data-region/README.md`                                            | the frozen `gui_object_names.tsv` read by `obj_names()` is `gen_data_s.py` and its data directories (lane mn10300-data2)         |
| N-83177c3d                          | CLOSED  | `../ic18-rhythm-rom.md`                                                   | ToneKeyFind's general tail; 3,386 notes resolved; Standard-Kit-1 key agreement 92.5 % -> 93.9 %                                   |
| N-c052c027                          | CLOSED  | `../ic18-rhythm-rom.md`                                                   | NoteConvApply traced past the fold: 11 mode-1 and 10 mode-0 tables over the 41 chord types                                       |
| N-e779328f                          | CLOSED  | `../ic18-rhythm-rom.md`                                                   | EQ words to TG register classes 0x40000000..0x50000000; a variation's +2/+3 are the DSP units' style parts (key 0xB048)          |
| N-c6900716                          | OPEN    | `../presentation-control-probes/song-records.md`                          | 0xA0 / 0xA1 / 0x200000 named; 17 ids left with the next step                                                                     |
| N-abdfdef8                          | CLOSED  | `../presentation-control-probes/song-records.md` section 7                | the 47 descriptors are the PC COMMUNICATION protocol: request layout, CRC-7, replies                                              |
| N-42bc8729                          | see report | `../sp7001-build-diff.md`                                              | (filled in below)                                                                                                                 |
| N-44e56012                          | OPEN    | `../work-ram-map.md`                                                      | key-bed path traced, no work-RAM gate on it; next step a MAME break on TgcNoteOnSend / TgcBufWrite                               |
| N-e140c8dc                          | CLOSED  | `../../../notes/floppy-leftovers-2026-10-31/README.md`                    | KN6000 1,768 -> 36 B, KN7000 5,270 -> 5,045 B (the rest: RAM nothing wrote [INFERENCE], bit density by address mod 8)          |
| O-kn6000-floppy-unknown-dump-397763 | CLOSED  | the same                                                                  | the 126 x 1,768 B group is 3 x 36 B                                                                                               |

## INITIAL_SP and the records above it (L-mn10300-names-b935-initial-sp)

`port_symbols.py` moved every RAM name by the majority vote of the references near it.  In 941
the boot stack's top, `INITIAL_SP` 0x50021CF8, is also the start of ten 0x42-byte records
(`func_48412C25` kind 1: `mov 0x42, d0; mulu; add 0x50021CF8, a0`).  In 935 / 893 the stack top
moved by -0x2C / -0x30 and the records by 0 / -4, so the vote gave 935 941's value, which
there only spelled `add INITIAL_SP, a0` (the records), and left 893's unported.  Each build's
reset code loads its stack top in exactly one `mov imm32, aN ; mov aN, sp`
(`port_symbols.reset_sp`), so `INITIAL_SP` (and `BootStack`, 0x800 below it in all four
builds) is now ported from that instruction:

| build | reset loads  | INITIAL_SP before | after        | DspPresetRamRecords |
|-------|--------------|-------------------|--------------|---------------------|
| 941   | 0x50021CF8   | 0x50021CF8        | 0x50021CF8   | 0x50021CF8          |
| 942   | 0x50021D08   | 0x50021D08        | 0x50021D08   | 0x50021D08          |
| 935   | 0x50021CCC   | 0x50021CF8        | 0x50021CCC   | 0x50021CF8          |
| 893   | 0x50021CC8   | unported          | 0x50021CC8   | 0x50021CF4          |

`../kn7000-names-probes/names_reset_sp_check.py` checks each row against the image.

## Call entries in port_names_by_code.py (L-mn10300-names-port-entry)

941 names some routines at the call entry, three bytes after an `add -N, sp` prologue, and the
tool compared them only with B's prologues.  B's `func_<ADDR>_entry` labels are now candidates
too.  Measured on 935 with its own names (`kn7000_b935_own.sym`) left out, so that the four
host-port routines are unnamed again: the tool now carries `DspFullReinit`, `DspWritePMWord`
and `DspWriteDMWord` onto 935's entries 0x4840B10E / 0x4840B1D0 / 0x4840B232, the addresses
the hand port gives them.  `DspRegWrite` stays: its signature has a twin among 941's routine
starts.  The command (scratch output, the source label list replaced by the four entries):

    python3 tools/port_names_by_code.py --a-rom baserom/kn7000_program.rom \
      --a-code 0x80:0x186000 --a-code 0x3b8fd1:0x3f6f01:0x4c000000 \
      --a-sym kn7000_manual.sym kn7000_exports_from_942.sym kn7000.sym \
      --b-rom baserom/kn7000_program_b935.rom --b-base 0x48400000 \
      --b-code 0x80:0x18595c --b-code 0x3b8f6d:0x3f6e9d:0x4c000000 \
      --b-sym kn7000_b935.sym kn7000_b935_manual.sym kn7000_b935_exports.sym \
      --b-src ENTRIES.s --out OUT.sym --unidasm $UNIDASM --title test

with `ENTRIES.s` holding the lines `func_4840B10B_entry:`, `func_4840B1CD_entry:`,
`func_4840B22F_entry:`, `func_4840B3F5_entry:`.

## SD frames and the tick hook's words (L-mn10300-names-sd-frame-labels)

`../kn7000-names-probes/names_sd_frames.py`: 941's 50 bytes at 0x50007E94 are IC18's
`SdFrameR2Cmd*` table byte for byte (IC18 boot file offset 0x48C), five 10-byte frames {u16 clock
mode 2, u16 response type 2, 0x40|n, four argument bytes, CRC 0xFF} with n = 0, 5, 3, 6, 7.  The
data typer had cut them as a 9-byte record (`SdReadBlockCmd_Var_2`) and a 41-byte table starting
at frame 0's CRC byte (`SdReadBlockCmd_Table`).  `kn7000_manual.sym` now names the five frames
and 941's four tick-hook words (`TickHookArg0..3`, the twins of IC18's); `gen_data_s.py` takes a
symbol-file name at a data address as the label (`self.fixed`), so the data sources and the code
that reads them change at the next `make data-and-code-src` (lane mn10300-data2's regeneration;
the names port to 942 / 935 / 893 through `make symbols-*`).

## Handed over (gen_data_s.py, lane mn10300-data2)

- **L-mn10300-names-kn2400-titles.**  `../kn7000-names-probes/names_kn2400_titles.py`: of the
  320 entries of the KN2400's TitleNameTable (0x48414BD8), 278 have a TT_ name in
  `kn2400/src/program/data/gui_ids.inc`, 17 are the firmware's own placeholders (`_TT_13e`) and
  25 are real names no screen registers (`_TT_CTHOMEPAGE`, `_TT_SETONELAYER`, `_TT_DIRPLAY`,
  the seven `_TT_STYLCNV*`, `_TT_VDOUT` and the rest, listed by the probe).  Next step, in
  `gen_data_s.py`: write `gui_ids.inc`'s TT_ rows from TitleNameTable (id 0x000F0000 + i, the
  string without its leading `_`) for the ids no registration names.  The second half of the item
  is done already: `TitleDefaultRecord` is typed (7 x u32).
- **N-61c32961.**  Next step as `../mn10300-data/README.md` says: an indexed form of
  `sentinel_lists` (the list read as `(dI, aT)` with dI stepped by one), for func_4C11B347 /
  func_4861CCC5.
- **N-fb88572c.**  Next step as `../gui-data-region/README.md` says: the frozen
  `src/<build>/data/gui_object_names.tsv`, written once from the current labels, read by
  `obj_names()`.

## Website page draft

*For the technics-docs KN7000 pages (another process publishes them; text only).*

**Start-up.** The reset code puts the stack at the top of a 2 KB block of work RAM; its address
differs between program versions (0x50021CF8 in v1.6, 0x50021CCC in v1.5, 0x50021CC8 in v1.3),
because the variables below it grew.

**PC COMMUNICATION** (from `../presentation-control-probes/song-records.md`): the KN7000
accepts file commands from a computer as Technics SysEx (`F0 50 2C 20 31 1F 7F gg ss .. name 00
cc F7`): load or save a named file of one of the file groups, an SMF, a picture import, or one of
five SD-card operations.  Each frame carries the SD card's CRC-7 before F7.  The instrument echoes
the request, waits for the computer's go-ahead (`F0 50 23 ..`), then answers "done" (`F0 50 28
20 31 1F cc F7`) or a status code (`F0 50 29 20 31 1F ee cc F7`).  The file data never travels
over MIDI.

**Note conversion, kits and part EQ** (from `../ic18-rhythm-rom.md`): a style is written over a
C chord, and each note names one of the firmware's conversion rules: melody rules move each
written scale degree to fit the chord type and transpose by the root, chord rules pick each
note's chord tone and inversion so the voicing stays near where it was written.  A style that
asks for a kit the instrument lacks gets the bank-LSB-0 kit of the same program, else the kit at
that program rounded down to a multiple of 8, else Standard Kit 1.  Each part's two-band EQ
becomes five filter coefficients written into every voice of the part; each variation also names
the parts the style's two DSP effect units apply to (Acc1 and Acc2 by default).

**How a key reaches the tone generator** (from `../work-ram-map.md`): the key bed delivers {key,
velocity} words through a FIFO on tone generator A (0x98050004); the tick task turns each into an
internal message, the keyboard router maps it through the active zone to a part, and the
translator writes a note message into the tone generator's command stream.  Only the factory test
modes divert keys from that path.

**Two sibling names that look like one.** The KN2400's `FilePriorityFunc` and the KN7000's
`SdcPanelSwAsFunc` have the same code because both are two-entry choice parameters of one
template; their choice lists (TECHNICS / SMF and SD-AUDIO / SD-SOUND) tell them apart.
