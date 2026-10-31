# Lane open4/misc (2026-10-31): tooling, media and documentation items

Wave 4 lane `misc`: the unowned ACTIONABLE N-* rows of the register's media, tooling and documentation
sections, the BLOCKED rows whose blocker was in this repository's own notes, the stale website text the
register lane found, the two LLVM bugs `../Mines/LLVM_TLCS900_BUGS.md` listed as active, and the KN5000 tone
generator's crystal.  Probes are in `probes/` (see `probes/README.md`).

## N-64f1f64d: 'J KD' LZSS is the KN5000's SLIDE8K, encoder included

**CLOSED.**  `probes/slide8k_vs_lzss_j.py` decodes each of the table data's six SLIDE8K help streams
(`original_ROMs/help_db_<lang>_compressed.original.bin`) with `floppy/tools/kd/lzss_j.py` and with
`scripts/build/decompress_slide8k.py` (same output), then re-encodes the decoded 0x9000 bytes with
`lzss_j.encode` (H. Okumura's LZSS.C, N = 8192, F = 10) and compares the decisions:

| stream       | factory stream | read by the decoder | encode() | decisions                                   |
|--------------|----------------|---------------------|----------|---------------------------------------------|
| english      | 13,471 B       | 13,470 B            | 13,470 B | all 7,366 the same, every byte the same     |
| german       | 13,717 B       | 13,716 B            | 13,716 B | all 7,539 the same                          |
| french       | 14,631 B       | 14,630 B            | 14,630 B | all 8,120 the same                          |
| spanish      | 14,819 B       | 14,818 B            | 14,818 B | all 8,148 the same                          |
| indonesian   | 13,767 B       | 13,766 B            | 13,766 B | all 7,589 the same                          |
| german_stale | 16,111 B       | 16,110 B            | 9,402 B  | the 5,339 up to output 0x55E0 the same      |

The byte each live stream has past what the decoder reads is the alignment pad (0x20, 0x7F, 0xCF, 0xCD,
0xCE).  german_stale parts at output 0x55E0, exactly where `table_data/help_databases.s` says the block was
cut (the Music Stylist pointer tables overwrote its tail): encoding only those first 0x55E0 bytes gives its
5,339 decisions exactly (encoding all 0x9000 decoded bytes parts at item 5,339).  So the factory SLIDE8K encoder is Okumura's, and the help databases need no
reference stream:

- `scripts/build/compress_slide8k.py`: without `--reference` it now runs `lzss_j.encode` (the old greedy
  coder is kept as `compress_slide8k_greedy`); `--pad BYTE` appends the alignment byte.
- `Makefile`: the five live payloads are built with `--pad $(HELP_DB_PAD_<lang>)`; the pad values are
  recorded there.  Only german_stale (verification only, not a ROM input) is still replayed.
- `table_data/help_databases.s` and `scripts/tools/mark_census_generated.py`: the census markers and the
  module header no longer say "replayed"; the header's claim that the last flag byte's unused bits are
  NONZERO "in these blocks" was wrong for the five live blocks (they are zero; only the cut stale stream
  ends in 0xA0) and is corrected.

Also measured (a finding, no build change): **SLIDE4K is the same encoder with N = 4096, F = 18.**
`probes/slide4k_vs_okumura.py` re-encodes the 19 demo presets and the three Sub-CPU update images
(v1.40/v1.41/v1.42) with `lzss_j.encode` re-parameterised, and all 22 make the factory decisions.  Two preset
slices carry bytes past the end of their stream: `demo_preset_17_compressed.original.bin` is 19,314 B but its
stream (header size 0x1700) is 3,357 B, and preset 18's is 27,956 B for a 27,881-byte stream.
`scripts/build/compress_lzss.py` could therefore also drop its reference for the stream part; the slices'
tails would still need a source of their own.  Not done here: listed as a follow-up below.

## N-77efbd0e: the semantic score and the doc-quality census rate KN7000 builds 935 and 893

**CLOSED** (commit "semantic score rules 6, doc-quality census: rate KN7000 program builds 935 and 893").
`scripts/analysis/semantic_score.py` (RULES = 6) and `scripts/analysis/doc_quality_census.py` list
`program935` (`kn7000/src/b935/program.s`, `build/kn7000_program_b935.rom`) and `program893`
(`src/b893/...`) beside `program942`, rated by the same rules.  At the base `130735749`:

| image      | bytes (source / image)          | names (semantic / rated)  | local labels left out |
|------------|---------------------------------|---------------------------|-----------------------|
| program935 | 4,148,024 / 4,194,304 (98.90 %) | 12,540 / 19,328 (64.88 %) | 321                   |
| program893 | 4,149,297 / 4,194,304 (98.93 %) | 12,534 / 19,318 (64.88 %) | 320                   |

`doc_quality_census.py --compare` against `doc-quality-2026-10-31-02` lists both as `new`.  It also reports
`v6` (a) 7,827 -> 7,828 and `v5` 7,829 -> 7,832 routines without a header as ROSE: this lane touches no v6 /
v5 source, so the rise is in the base (the wave-3 merges after that snapshot).  The badges and the ledger
snapshots are the integrator's.

## N-6a782984: name_kn5000_ram.py's block-delta fallback reviewed, now off by default

**CLOSED.**  The fallback placed a v9 / v7 RAM name that had no vote by the common delta of its voted
neighbours.  `probes/ram_block_delta_review.py` (output: `probes/ram_block_delta_review.out.txt`) lists the
names only it places: 24 in v9 and 25 in v7.  No code line of either tree spells any of them, and each is at
v10's address in the tree or has no `.equ` there (the six BOOTSERIAL_* names, RHYTHM_PATTERN_SEL_A / _TYPE);
the only non-zero guesses are v7's RHYTHM_PATTERN_SEL_A / _TYPE (-0x9C).  So the fallback had changed no
source line, and a guess from layout is not evidence: the script now applies it only with
`--infer-block-delta` (which keeps the old cascading behaviour) and otherwise prints the guesses with their
addresses.  `notes/ram-naming-2026-10-24/README.md` follow-up 4 is closed.

## N-94797258: the format of IC307's 71 unmatched waves

**BLOCKED on a dump of IC306.**  The 8-bit / 16-bit flag of a recording is in its directory P word, which is on
IC307's partner IC306 (`../sound-2026-10-31/README.md`, section 3), and none of the 71 has a KN7000 recording
with the same audio, so the byte-correlation reading (`../media-files-2026-10-30/README.md`, 31 8-bit, 40
16-bit) is all the dumped chips give.  `../media-files-2026-10-30/README.md` now says so.

## Stale website text (technics-docs 6a38c50)

| page                        | was                                                                 | now, and the evidence                                                                                                                                                                                                |
|-----------------------------|---------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `rom-reconstruction.md`     | v7 6,591 B verbatim (at 3417969c0); "v1.40 has no source tree"      | v7 0 B since d89e64558; v6 13,756 B and v5 15,910 B, all seventeen measured images 29,666 B (`kn5000_source_coverage.py` at 130735749); v1.41 and v1.40 trees since 2026-10-24                                       |
| `display-subsystem.md`      | 42 main-CPU and 5 HD-AE5000 images; "SlideMove" = slide animation   | 61 and 6 committed PNGs; SlideBase / SlideMove are `BitmapIDProc` bitmap IDs 2 and 3 (`BitmapID_Names` at 0xEAB8D8; files slide.bmp / slmove.bmp in `BitmapID_FileNamePtrTable`), beside MixerControl / MixerPoint |
| `midi-subsystem.md`         | CC 0x95 / 0x97 / 0x9C = chorus on/off, chorus depth, delay on/off   | glide pedal, sustain length, key scaling (`Voice_CC_GlidePedal` -> `Voice_CC_SetGlidePedal` etc., v142)                                                                                                             |
| `control-panel-protocol.md` | IDs 25 / 26 / 27 breath / foot / expression; A/D 0 / 1 mod / volume | from the events posted: ID 25 pitch bend (0xB1 -> `MidiCC_ChannelDispatch_CtrlFlags`, 0xE0), ID 26 CC 1 (0xB2), A/D 0 CC 1 or CC 11 (0x2880 = 182 / 183), A/D 1 channel pressure (0xB4 -> 0xD0); ID 27 not established |
| `audio-subsystem.md`        | (48 kHz assumed)                                                    | X301 = 33.8688 MHz = 768 x 44.1 kHz, so very probably 44.1 kHz; section "Clock and Output Rate"                                                                                                                    |

The control-panel reading, in the source: record 22's action `PanelAction_Event22` (v10
`audio/audio_control_engine.s`) splits the byte into two 7-bit values and posts tag 0xB1;
`Audio_MainPeriodicUpdate` hands a queued panel event to `SoundProgram_DispatchTable[tag]`, whose 0xB1..0xB4
handlers (`MidiCh_IterateVolume_Reverse`, `MidiCh_IterateVolume_Forward`, `MidiCh_IterateExpression`,
`MidiCh_IteratePan_Forward` -- names that predate this reading) pass the tag on as the status of
`MIDI_DispatchCC`; its table `MidiDispatchCC_HandlerTable` sends 0xB1 to `MidiCC_ChannelDispatch_CtrlFlags`
(`or a, 0xe0`, `MidiTx_PartTargets_PitchBend`), 0xB2 to `_Ctrl1` (CC 1), 0xB3 to `_Ctrl3` (CC 11) and 0xB4 to
`_CtrlFlags2` (`or a, 0xd0`, `MidiTx_PartTargets_ChannelPressure`).  Renaming the `Encoder_Process*` /
`MIDI_CC_*` labels after it is tracker item kn5000-3c7 (not this lane's).  The EXP / AFT signal names are
the register lane's reading of the service manual; this lane did not re-check the schematic.

Tracker item kn5000-3ei (the website's verbatim figure) is closed with a comment (commit "issues: close
kn5000-3ei").  The repo-root CLAUDE.md Architecture table still quotes v6 17,159 B and v5 19,978 B (2026-10-29);
this lane leaves CLAUDE.md to the integrator.

## The KN5000 tone generator's crystal

**Website: CLOSED** (`audio-subsystem.md`, "Clock and Output Rate").  **MAME side: BLOCKED on the MAME
repository.**  The 48 kHz is not in this repository's `mame_driver/` reference copies (they hold no tone
generator); it is `kn5000_tonegen.cpp`'s stream rate in the kn7000_mame overlay
(`src/mame/matsushita/kn5000_tonegen.cpp`: "Create stereo output stream at 48kHz", `SAMPLE_RATE = 48000.0`
in the envelope-rate law, and `/ 48000.0` in the filter and pitch-step code).  Changing it to 44.1 kHz is
device work in that repository (and upstream MAME), and every constant derived from 48 kHz there has to be
re-derived with it.

## Mines: LLVM bugs 10 and 11

**CLOSED** (Mines `5fe280f`).  `../Mines/LLVM_TLCS900_BUGS.md` (until now untracked in Mines) said 2 active.
Bug 10 is not a bug (llvm-project `116dc9423e53`: the report assumed XBC carries the first argument; the
convention is XDE first, `CCAssignToReg<[XDE, XBC, XIX, XIY]>`); bug 11 is fixed (`eba2fe6622ee`, EXTS32 /
EXTZ32 set no flags, squashed into `e90ba8f16b19` on `tlcs900_backend`, an ancestor of the pinned
`a3a81863f87d`; at that commit `TLCS900InstrInfo.td` keeps them out of `Defs = [SR]`).  Mines `8b1d85e`
removed both workarounds.  The file now says 9 fixed, 2 not a bug, 0 active, and keeps the original reports
with a resolution each.  Mines' own CLAUDE.md still lists both under "LLVM Backend Bugs (Active
Workarounds)"; this lane did not edit that CLAUDE.md (left to the owner).

## BLOCKED rows checked

| id         | outcome                                                                                                                                                                                                                                         |
|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| N-ff7d2e8d | the owner's decision it waited for is in main: `130735749` ("the Preset Data Destination dispute is resolved (owner confirmed 2026-10-31)") -- CLOSED                                                                                            |
| N-33949aba | still BLOCKED on the LLVM backend: the pinned llvm-mc (`a3a81863f87d`) rejects `ldcf a, rh3` / `stcf a, rh3` (and `ldcf a, h`); `TLCS900InstrInfo.td` has only the memory forms `LDCFA_m` / `STCFA_m` (`ldcf a, (mem)`), no register form; no later commit on `tlcs900_backend` |

No other BLOCKED row's blocker is in technics-docs or in this repository's notes: the rest wait for a chip,
hardware, another repository or an owner decision that is not yet taken.

## N-abb7ecb5: the v7 byte-region converters write the tree's spelling

**CLOSED.**  The respelling of step 8 (analysis/v7-harmonize-2026-10-24) is now a function,
`respell_lines()` in `scripts/tools/respell_v7_new_lines_like_v10.py` (its `main()` calls it on the lines
`git blame` gives to `--commit`, exactly as before: a dry run at the base reports the same counts, 224
fallback / 170 v10-match / 7 changed, with the old and the new script).  `v7_byte_region_to_insns.py` (new
step 5 of its docstring) and `reframe_byte_runs_by_decode.py` (step 7) call it on the lines they write, so
their output is in the tree's form (tab after the mnemonic, `call cc, (X:24)`, v10's notation where the same
label's v10 block has the instruction, hex for RAM operands, masks and large constants elsewhere) instead of
llvm-objdump's.

`probes/v7_converter_rerun_check.py` puts the dump's bytes of a committed block back as `.byte` rows, re-runs
`v7_byte_region_to_insns.py` on it and compares (output: `probes/v7_converter_rerun_check.out.txt`).  Of the
seven blocks of two step-5 regions (BitMapOut_CopyExtTable_Check and CmpStepTitle_OnPaint), six come out
IDENTICAL; in the seventh one operand differs, `(0x8c9b:16)` where the tree says `(PREVIOUS_TITLE:16)`: the
RAM name a later lane applied with `scripts/tools/name_kn5000_ram.py`, which is that tool's job, not the
converter's.

The dry run's 7 changes are lines of `v7/maincpu/sequencer/accompaniment_engine.s` blamed to d89e64558 whose RAM
operands are still decimal (`ld a, (12873:16)`); they were so at the base too and are left for the next run of
step 8 or of `name_kn5000_ram.py`.
