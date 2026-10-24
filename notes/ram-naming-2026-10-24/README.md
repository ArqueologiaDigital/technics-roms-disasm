# KN5000 main-CPU RAM naming (audit WP17 (a), wave 2, 2026-10-24)

WP17 (a) of `notes/repo-audit-2026-10-24/README.md`: name the main CPU's RAM variables and spell the
numeric operands that use them by name, most-used addresses first, in v10, v9 and v7 (v8 is the v9
source). Every name rests on the code that writes and reads the address. Each `.equ` comment says what
that code does with it, and the routine headers earlier lanes wrote were used as a starting point and
then checked against the code. Where the meaning was not clear, the address keeps its number.

## Where the names are

| file (each of `v10/`, `v9/`, `v7/maincpu/`) | what it holds                                                                                         |
|---------------------------------------------|-------------------------------------------------------------------------------------------------------|
| `shared/ram_variables_by_use.s`             | one `.equ` per variable named here, sorted by address; v9's and v7's values are their own (see below) |
| `shared/ram_panel_records.s`                | the live panel records (TLV payloads, RAM 0xF9A0-0xFFBE): the same values in all three trees          |
| `shared/ram_variables.s`                    | the names of earlier lanes (unchanged), and the two `.include` lines that pull the files above in     |

A comment that starts `[N bytes]` marks a record or array. A numeric operand inside one that has no name
of its own is spelled `NAME+offset`, with the offset in decimal (`(PANEL_STYLE+8:16)`,
`(ACC_LANE_READ_POS+4:16)`).

## Tools (all committed)

| script                                             | question it answers / job                                                                                                                                                                                                                   |
|----------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `scripts/analysis/kn5000_ram_candidates.py`        | (existing) which numeric RAM addresses are used most, with their accessors and writers                                                                                                                                                      |
| `scripts/analysis/kn5000_ram_evidence.py`          | (new) the reading dossier for an address: access widths, stores by value, other uses by shape, the routines with their header lines and the code around each use, comments and technics-docs rows that quote it, and its numeric neighbours |
| `scripts/analysis/kn5000_ram_bit_usage.py`         | (new) who sets, clears, toggles and tests each bit of a flag byte (`--name` adds its name)                                                                                                                                                  |
| `scripts/tools/add_kn5000_ram_names.py`            | (new) adds `0xADDR NAME ; why` lines to the three `ram_variables_by_use.s`, runs `name_kn5000_ram.py --apply` per tree, leaves out of v9 / v7 a name the code there does not use, places records by their fields, and spells `NAME+offset`  |
| `scripts/tools/name_kn5000_ram.py`                 | (existing; now compiles its name pattern once and also reads the two new files) rewrites the numeric operands; for v9 / v7 derives each name's address from the same instruction in the same routine                                        |
| `scripts/tools/name_kn5000_panel_records.py`       | (new) names the panel records from `SndParam_BlockRamPtrs` and the default image `SndParamRam_DefaultImage`, after checking that both are identical in v7 / v9 / v10                                                                        |
| `scripts/renaming/rename_wp17_ram.sed`             | (new) the one rename this lane made to its own names (below)                                                                                                                                                                                |
| `scripts/renaming/apply_word_renames.py`           | (new) runs a `.sed` file's whole-word rules over `.s` files byte-safely (the sandbox here refuses `sed -f`)                                                                                                                                 |
| `scripts/analysis/kn5000_shared_ram_crosscheck.py` | (new) does the HD-AE5000 source spell a main-CPU RAM address as a number?  It does not: 0 operands, so there is no shared name to reuse (the sub-CPU has an address space of its own)                                                       |

Commands, from the repository root:

    make all
    python3 scripts/analysis/kn5000_ram_evidence.py --top 20            # or: ... 0x2972 0x10fd
    python3 scripts/tools/add_kn5000_ram_names.py NAMES.txt [--dry-run]  # lines: 0xADDR NAME ; why
    python3 scripts/tools/name_kn5000_panel_records.py [--dry-run]
    make gate                                                           # every image must stay IDENTICAL

## How the v9 and v7 addresses are found

v9's RAM layout is v10's. v7's is not: the accompaniment, chord, UI and MIDI blocks sit 0x9C lower, and
other blocks have not moved. `name_kn5000_ram.py` never assumes a shift. It pairs every v10 routine with the
routine of the same label in the other tree, and only routines with the same number of instructions and
the same shape count. Each numeric operand in the other tree at the place where v10 uses a name is then a
vote, and a name is applied only when all of its votes agree. 161 of the 288 names in v7's
`ram_variables_by_use.s` came out at an address other than v10's; their comment says so. A record whose
first byte no instruction uses is placed from its fields instead: v10's `NAME+k` against the other tree's
number `n` votes for `n - k` (`add_kn5000_ram_names.py`, `derive_records`). The panel records are not
derived: `SndParam_BlockRamPtrs` and the default image are byte-identical in the three trees, so their
addresses are the same. The gate cannot prove a vote right, because a number replaced by a name of the same
value assembles to the same bytes either way. What makes a vote trustworthy is that it is unanimous and
that the instruction shapes match.

`name_kn5000_ram.py`'s older fallback still applies: a name with no vote whose voted neighbours within 0x100
(at least five) all moved by one delta takes that delta. As more names were added, more neighbours voted, so
this fallback now places a few names that it left out before. It placed them only where nothing numeric
used them, so no operand changed because of it. The fallback deserves a review (follow-up 4).

## Results

`python3 scripts/analysis/doc_quality_census.py`, row (b) "(number) operand elsewhere" (numeric absolute
memory operands outside the image: RAM, I/O, other ROMs), before the lane and after its last commit:

| tree | before | after  | removed |
|------|--------|--------|---------|
| v10  | 29,079 | 19,417 | 9,662   |
| v9   | 29,049 | 19,387 | 9,662   |
| v7   | 28,877 | 19,294 | 9,583   |

Names: 288 in `ram_variables_by_use.s` (19 of them records) and 75 in `ram_panel_records.s` (the 74 record
payloads and `PANEL_RECORDS`), so 363 distinct addresses. All 288 are defined in v9 and v7 as well. Count
them with `grep -c '^\s*\.equ'` on each file. `make gate` reported every image IDENTICAL after every batch.

## Corrections made on the way

- `ACC_EVENT` (0x342D, 6 bytes): `docs/accompaniment-style-reader.md` (a MAME trace) gives the fields as
  status, position in the beat, note, velocity, and a 2-byte duration. The first comment had called +1 a
  channel and the byte forced to 1 a velocity. It is the duration that is forced to 1.
- 0x0420 had been named `ACC_TRANSPORT_STATE` after ssf-presentation.md's "sequencer transport lane".
  Reading `INTTR4_HANDLER` showed that it gates the 0x417 / 0x418 counters. The accompaniment clock
  (`ACC_CLOCK` / `ACC_BEAT`) is gated by 0x041E, which the `AccPlayMode_StartAccPlay` / `AccAutoPlay_*` code
  uses. 0x0420 is now `PLAY_TRANSPORT_STATE` and 0x041E is `ACC_TRANSPORT_STATE`.
- `SndParamRam_DefaultImage`'s header says that the bytes after 0xFDA1 "may be the image continued".
  `name_kn5000_panel_records.py` shows that they are: the TLV walk continues through tags 0x17, 0x18, 0x98,
  0x91, 0x93, 0xC0-0xD7, 0x49 and 0x9A, and every one of those payloads is the address
  `SndParam_BlockRamPtrs` holds for its tag. The header comment was left for the lane that owns that file.

## Follow-ups

1. The flag bytes and masks with the most numeric uses are still numbers. Each one needs a per-bit analysis
   before it can be named:
   - 0xC1FE / 0xC594 / 0xC596 / 0xC598 / 0xC59C, the audio-configuration state;
   - 0x287B, 0x28B2, 0x28B3 and 0x28C5, the sequencer play state;
   - 0x28A8 / 0x28AA / 0x28C6 / SEQ_SONG_RECORD+30 (0xF19E) / 0xFFEC, the track masks of play and record;
   - 0x32F4, 0x332C, 0x3283, 0x34CD, 0x35B0 and 0x3312-0x3318, accompaniment state;
   - 0xE3E2, the sound editor and Composer flags.

   `scripts/analysis/kn5000_ram_bit_usage.py` prints who sets, clears and tests each bit, which is where
   that analysis starts.
2. The remaining per-lane arrays of the accompaniment engine: 0x32B5[6], 0x33EB[6], and the D4-D7
   rhythm-channel quads (0x32C3, 0x32C7, 0x332F). Name them once their contents are understood. The lane
   records named here show the pattern.
3. Data lines were out of this lane's scope. `SndParam_BlockRamPtrs` (`ui_widgets/widget_dispatch.s`) could
   become `.long PANEL_PART_RT1, ...`. Many routine headers still quote the addresses as numbers (`0x0D57`
   where the code now says `SQSTEP_CLOCK`), and a header lane could respell them.
4. Review `name_kn5000_ram.py`'s block-delta fallback (above). It could be limited to names that already have
   a vote in another tree, or dropped.
5. The sequencer edit titles' parameters (0x25FA-0x2662, `EVT_GET_RAM_ADDRESS` per title in
   `SqedtFunc_StateChainB_On*`) form one table per title, and could be named record by record from those
   switch tables.
