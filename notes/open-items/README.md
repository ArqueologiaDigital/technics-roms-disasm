# Open-items register (set up 2026-10-31, lane open3/register)

The owner's goal for wave 3: *"work on all open items until nothing else is left open"*.  This directory is
where those items are tracked.

| file                    | what it is                                                                                    |
|-------------------------|-----------------------------------------------------------------------------------------------|
| `collect_open_items.py` | collects every open item from the four sources below and writes the register                  |
| `triage.json`           | the hand triage: one row per item id (status, plan or blocker, size, owner, evidence)         |
| `REGISTER.md`           | the generated register: summary counts, then one table per area                               |
| `opaque-groups.json`    | cache of the opaque-declaration groups, written by every run that does not pass `--no-census` |
| `probes/`               | the scripts behind the measurements the triage quotes (their README says what each answers)   |

## `collect_open_items.py`

**Question it answers:** what is still open in this repository, where is it written down, and what would
close it?

    python3 notes/open-items/collect_open_items.py --write      # regenerate REGISTER.md (about 70 s)
    python3 notes/open-items/collect_open_items.py --check      # exit 1 if any item has no triage row
    python3 notes/open-items/collect_open_items.py --no-census --check   # fast: reuse opaque-groups.json
    python3 notes/open-items/collect_open_items.py --dump items.json     # the collected items, for triage

It reads four sources:

| letter | source                                                      | one register row per                       |
|--------|-------------------------------------------------------------|--------------------------------------------|
| N      | open-items sections of the notes (list in the docstring)    | list item / table row / sub-heading        |
| I      | `.beads/issues.jsonl`, every issue not closed               | issue (id = the issue id)                  |
| T      | `; TODO` / `TODO(port)` comments in the git-tracked sources | (tree, first words of the marker) group    |
| O      | `census: opaque -- unknown-dump` / `-- code` declarations   | (census tree, reason with numbers removed) |

The N sections are the headings "Open", "Open questions", "Open items", "Open work", "Left open", "Still
open", "What remains", "Still unknown", "Follow-up(s)", "TODO" and their variants (the regular expression
`OPEN_HEADING`), plus the sections listed in `EXTRA_SECTIONS` (the WSA1R emulation-gap list and the
2026-10-17 "Pending work") and the repo-root CLAUDE.md "Known Disputed Interpretations".  A note item's id is
`N-` + 8 hex digits of the SHA-1 of its file and its text up to the first "resolved", so a note can mark an
item settled without changing its id.

## Statuses

| status     | meaning                                                                                       |
|------------|-----------------------------------------------------------------------------------------------|
| RESOLVED   | later work settled it; the row cites the commit or note.  The note that listed it now says so |
| ACTIONABLE | work in this repo could close it; the row gives the plan, a size and, if any, the owning lane |
| BLOCKED    | it needs what this repo cannot provide; the row names the exact blocker                       |

Sizes: S = one commit, under two hours; M = one session; L = a lane of its own.  BLOCKED blockers are one of:
an undumped chip (named), hardware access (what to measure on which instrument), a different repository
(upstream MAME, kn7000_mame, `../Mines`, `../llvm-project`) or an owner decision (the question quoted).

## Triage an item

1. `--check` lists the items with no row.  Look the item up at its `source` (file:line).
2. Add a row to `triage.json` under its id: `status`, a short `title`, and `evidence` (RESOLVED), `plan` +
   `size` (+ `owner`) (ACTIONABLE) or `blocker` (BLOCKED).  `area` overrides the default area.
3. If the item is RESOLVED and its note still lists it as open, append
   `(Resolved: <pointer>; open-items register <date>.)` to the item in the note.
4. A tracker issue is closed in `.beads/issues.jsonl` only under the repo-root CLAUDE.md "Issue Closure
   Requirements" (the website documents it; the closing comment has the summary, the pages and the caveats).
   Its close_reason names this register, so the register keeps listing it as RESOLVED.
5. `--write`, and commit `triage.json`, `REGISTER.md` and the notes together.

A note item whose text changes gets a new id: `--check` then reports it as untriaged and the old row as an
orphan; move the row to the new id.

## 2026-10-31 wave 3-4 (lane open5/register-refresh)

The register brought up to date with what the wave-3 and wave-4 lanes recorded in their notes (their outcome
blocks were already applied, `outcomes-2026-10-31/`).  No new research: every status below is what a lane note
says.  The edit script and this section's generator are in `~/compartilhado/research-scratch`,
`sessions/2026-10-31_tmp/refresh_triage.py` and `readme_section.py` (its commit d758081).

| status                | REGISTER.md as committed at 615249d66 (c843cad10's triage) | script at 615249d66 (full run) | after   |
|-----------------------|------------------------------------------------------------|--------------------------------|---------|
| RESOLVED              | 185                                                        | 353                            | 405     |
| ACTIONABLE            | 342                                                        | 151                            | 178     |
| BLOCKED               | 57                                                         | 60                             | 75      |
| UNTRIAGED             | 0                                                          | 137                            | 0       |
| total                 | 584                                                        | 701                            | 658     |
| orphan rows, in error | -                                                          | 102, 20                        | 39, 0   |

The brief's 134 untriaged / 93 orphans / 19 in error were a `--no-census` run on the old opaque cache; the full
run (census included) found 137 / 102 / 20: three new opaque groups and nine gone.  What changed:

- **57 rows moved** to the new id of their rewritten item (status and evidence kept; the old id is in the row's
  `was`).  Six old rows were merged into the item that now holds them and dropped as duplicates: N-fa218ac5 into
  N-5b252fce; N-398ba2d0, N-141a8cab and N-eadb1f7f into N-b8f49b1e (with N-e3880498); N-c7e9fbae and N-eb1f0d7a
  into N-dd1e93d8.  References to them in other rows were rewritten.  Notes that still quote an old id (for
  example `notes/floppy-others-2026-10-29/README.md` quotes N-e3880498) are found through `was`.
- A moved row changed status only where the lane's own note closes an item whose row predates that lane:
  N-239f5bab, N-5b252fce, N-395531b4 (HD-SX3, lane mn10300-rest) and N-af89e68e (`mem_ptrs`), all RESOLVED at
  112141bd7.
- **80 new rows**: 11 tracker issues lane kn5000-b opened (kn5000-ax7 ... kn5000-rzg), 32 note items, the three
  new opaque groups, and 34 answer rows that the collector reads as items because their section heading names
  the question (`notes/open4-kn5000-b/hdae/README.md` "kn5000-44c: the filesystem's open questions", 21 rows;
  `wsa1/notes/FINDINGS-prom_b-f44018-module.md` "WorkspaceDefaults -- and a partition deliberately left open",
  13 rows): RESOLVED, with the lane's commit.
- **The in-error row** left after the moves: `O-kn7000-ic21own-unknown-dump-d531ff` was BLOCKED, but lane
  ic21-rest typed that residue (5fdd6311d, no `census: opaque` left in `kn7000/src/ic21own`): RESOLVED.  The
  O- titles now quote the census's current counts.
- **The 39 orphan rows that stay** are all RESOLVED and are written to the register from their row: the 3 listed by
  hand (L-) and 36 items that left their source once resolved: 24 TODO-marker groups whose markers the lanes
  removed, 9 opaque groups the lanes typed, the CLAUDE.md dispute row N-ff7d2e8d (the table row became a
  "Resolved" paragraph), N-1837e44c (its heading no longer says open) and tracker issue kn5000-3ei (closed by
  lane kn5000-b).  `--check` exits 0.
- The two owner decisions of the brief: the WSA1R join/split phase A3 stays BLOCKED (below); the Preset Data
  Destination dispute (N-ff7d2e8d and its checklist N-9924787c, N-9ec6fccd, N-19abcd15) and the style_bank_extra
  readings (N-2d252457) are settled, RESOLVED.

### BLOCKED, by blocker (75 items)

**Undumped chips and images** (21)

- KN5000 wave ROMs IC306 (QSIGT3C32A01), IC304, IC305:
  - `N-2c574534` Format of the 71 IC307 waves with no KN7000 counterpart is inferred
  - `N-612f98d6` IC307: the 74 items without a rate, the P/Q words and loops; classes 0-3
  - `N-b77afdc6` Where IC307 loops are (likely the X chip)
  - `kn5000-d38` Waveform ROM (IC304-IC307) documentation
  - `kn5000-mrx` Waveform samples as WAV: done for IC307; sample rates, loops, root notes open
- KN5000 sub-CPU boot ROM IC30, a redump (the image is BAD_DUMP):
  - `kn5000-a9y` Which chip decodes the sub CPU's 0x130000 register block
  - `kn5000-1oy` DSP effects algorithms: finish the uPD6383 decode and the reverb micro-topology
  - `kn5000-b0h` Sub-CPU emulation accuracy: timing, DMA, interrupt, audio-sync requirements
- KN5000 main program v1-v4:
  - `N-424fcc19` Which firmware wrote the 43-record panel blocks
  - `T-floppy-kn5000-todo-the-older` KN5000 .LSW: panel records of an older firmware revision (ptlv_raw)
- SX-KN3000 program ROM:
  - `O-kn5000-floppy-unknown-dump-bb12e1` KN5000 floppy ca5000r 03FOLKS2.TM: a KN3000 SOUND RAM image, not decoded
- SX-KN7000 program builds older than 893 (v1.0-v1.2):
  - `N-74abdb18` Writer of the 76 01ctmini settings without 941's part tails
- SX-KN7000 v1.4 update disk 1 (a lost file):
  - `N-94416e15` v1.4 program update disk 1 (kn7-14_1.exe -> JK1.SLD, build 929) lost
- SX-KN7000 IC19 from a later production run:
  - `N-b8c1448a` Whether IC19 (picture ROM) differs between production runs
- SX-KN6000 program older than v7.1:
  - `N-74a16d86` Writer of the KN6000 bank's settings with part 3 all 0xFF
- SX-KN1500 IC15 program ROM, a good redump:
  - `N-054f83bd` SX-KN1500 IC15 program dump is half blank (its whole boot blocker)
- SX-KN2400/KN2600 IC12/IC13 program flash, the 0x48000000 half:
  - `N-1adf5657` KN2400/KN2600: the 4 MiB half of the IC12/IC13 program-flash pair at 0x48000000
- SX-WSA1R prom_b, a second build (SX-WSA1 keyboard or another WSA1R version):
  - `N-0eab77c6` prom_b orphan run 3: the array's 3-slot tail (39 slots vs 0xFE2F8C)
  - `N-2566c304` prom_b orphan tables: the vestigial-index reading needs a second build
- SX-WSA1 domestic (Japanese) program ROMs or disk:
  - `N-25f9f42b` Fonts: the Japanese text behind the private kanji encoding
- SX-WSA1R panel MCU M37471M2196S mask ROM:
  - `N-735e7eb4` Gap P: the panel's reply to the seven SC1 commands (commands mapped)

**Hardware access, measurements and datasheets** (26)

- a KN5000 (board continuity, line-out recordings, captures):
  - `N-457cb583` Does the KN5000 board cross IC14 A19/A21, or is the dump wrong?
  - `N-40b34f27` KN5000 audio: signal levels (line out, headphones)
  - `N-dab5bb4e` KN5000 audio: the LINE OUT and AUX IN nets are inference
  - `N-8cd6477f` 8-bit gain law fitted in emulation, not derived
  - `N-13b60687` The 8-bit gain law (code field high bits, REC_END code)
  - `kn5000-a8s` Establish emulation validation procedures with real-hardware baselines
- an HD-AE5000 board or its service manual:
  - `kn5000-mzz` HD-AE5000 interface cable (W3 / HSQ OPTION) pinout
- a KN7000 (the owner's unit):
  - `N-9c325eeb` Which chip (IC18 ROM or IC20 flash) sits at the owner's KN7000 site
  - `N-9d50b49c` Whether user DRAM 0x50180000..0x50297FFF survives power-off ~80 min
  - `N-cf2facde` Which value TgStrapProbe returns on real hardware (slide-show pool size)
- an SX-WSA1R (in storage abroad) or IC4 TC183C230002's datasheet:
  - `N-50026418` Gap I: key-scan status value 2 (the reader of RAM 0x008517 is answered)
  - `N-e4cf98bf` Gap H: what the 64 write pairs to the key-scan port 0x108000 configure
  - `N-e4995227` Gap A: what each 0x0010C000 tone-generator register does (synthesis)
  - `N-f1964717` prom_c 0x0010C000 registers 0x900..0xA40: second / third envelope, meaning unstated
  - `N-878b8e86` Gap O: which panel button and LED is which bit
  - `T-wsa1-todo-no-template` WSA1R key codes 0x1A/0x1C/0x1D/0x1F: no panel template emits them
  - `T-wsa1-todo-nothing-on` WSA1R key code 0x0E: nothing on the panel raises it
- an SX-WSA1R, for the L7A1429 (no datasheet):
  - `N-29d37587` L7A1429: absolute scale of register chan+0x00C0 (POSITION)
  - `N-456269f6` L7A1429: register 0x0800 (0x1100 once at power-on) global or block 0x20 ch 0, and its role
  - `N-575b5b39` L7A1429: what Curve_Muting_Cutoff_Q13_128 is (role of the Q13 companion)
  - `N-a9375486` L7A1429: which rate Curve_Fitting_Exp2Decay_256 is applied at
  - `N-da75dd11` L7A1429: what RESO SCALE sounds like
  - `N-ebc02f57` L7A1429: coupled-waveguide reading of Pack104_SolveCoupledDetune (STRONG, not PROVEN)
  - `N-e2c3f78e` L7A1429: inputs of the six solver calls the ROM leaves undetermined (element 3)
- the SX-WSA1 keyboard (its service manual or the instrument):
  - `N-8e553797` What each of CPU 1's six analogue channels is, on the variant that reads them
- the uPD6383GF instruction set (no datasheet exists):
  - `N-805ef6f1` DSP: let the upd6383 execute (ISA not measured-decoded); audio output

**Other repositories** (22)

- MAME upstream (mamedev/mame) and the kn7000_mame overlay:
  - `N-ef8127ae` tmp95c061 defect 1: prescaler taps fc/128.. instead of the databook 8/32/128/2048
  - `N-540fcf33` tmp95c061 defect 2: 16-bit up-counters never counted, INTTR4-7 never raised
  - `N-02ec6f12` tmp95c061 defect 3: T4MOD/T5MOD CLE bit ignored
  - `N-5c311c03` tmp95c061 defect 4: the two 16-bit comparators chained with else-if
  - `N-f9c64015` tmp95c061 defect 5: TRUN b4/b5 Stop & Clear cleared the wrong slots
  - `N-afd95026` tmp95c061 defect 6: an 8-bit timer match did not set m_check_irqs
  - `N-ee58a28c` tmp95c061 8-bit prescaler taps and 16-bit timers 4-7 (overlay fix, not upstream)
  - `N-6007ef91` WSA1R driver: the three D6383GF DSPs (IC5, IC6, IC30) have no MAME device
  - `N-88605105` WSA1R: a upd6383gf device would only make the DSP traffic inspectable (optional)
  - `N-b80b5580` WSA1R: no uPD6383GF device, so the decoded CPU 2 DSP upload goes nowhere
  - `N-b5f75e0a` MAME has no uPD72070 device; the WSA1R driver substitutes upd765a
  - `N-d35c2767` upd6383 device reads I-RAM word 395 (>383) every sample; widen iram_map for captures
  - `N-c1322a24` Record a CONTROL-track session in MAME, save, census, replay
  - `T-mame_driver-todo-configuration-helpers` mame_driver tmp96c141.h: upstream MAME's 'configuration helpers' TODO
  - `kn5000-0eo` MAME: ghost panel events after boot (voice dialog, transpose B)
  - `kn5000-0o6` MAME: emulate the audio path from the sub-CPU/tone-generator findings
  - `kn5000-1vz` MAME input/control subsystem milestone (epic)
  - `kn5000-a0k` MAME storage subsystem milestone (epic)
  - `kn5000-qhm` MAME HLE device for the control panel: finish buttons/LEDs/encoders/analog
  - `kn5000-y18` MAME audio subsystem milestone (epic)
  - `kn5000-dbi` Phase 1 completion: all MAME blockers resolved (epic)
- the LLVM TLCS-900 backend (../llvm-project):
  - `N-33949aba` No LLVM spelling for ldcf/stcf A,RH3 (still .byte)

**Owner decisions** (1)

- WSA1R join/split phase A3: may the shared kernel carry per-CPU .if/.else and take over the KN5000 sub-CPU kernel's text? (wsa1/notes/HANDOFF-join-split-kernel.md):
  - `N-8c52a3ed` Join/split plan: phases A3, A4 (KN5000 half) and B3 after the shared kernel

**Material nobody holds (no image, file or record has it)** (5)

- a CUSTOM bank saved with user effects or SOUND EDIT sounds:
  - `N-00e19224` IC21 0x42-byte dependency records and 0x2C8 SOUND EDIT records: strides only
- another factory custom-data set (the residue's source records):
  - `N-e40c8c93` KN7000 factory CUSTOM banks: the 157 opaque residue bytes
  - `O-kn7000-customdata-unknown-dump-25be5c` KN7000 factory CUSTOM banks: 157 B of residue splinters no record holds
- Technics' factory authoring tool or records:
  - `N-6558bfa7` Where the factory CUSTOM sets were made (one tool built them in sequence)
- who typed the respelled one-touch names:
  - `N-46580c3b` Who typed the respelled one-touch names (Metallic Dance ...) into the KN6000 file

### ACTIONABLE, by area (178 items)

Each row's plan and size are in `REGISTER.md` ("Next wave" and the area tables).  Sizes: S / M / L.

**KN5000** (26)

- S `N-29e0f8b4` KN5000 audio: the EQUALIZING sections' responses
- S `N-edb08959` KN5000: the style-bank renames lane kn5000-style found but did not make
- S `kn5000-1gu` Main-CPU sender of sub-CPU system sub-command 0x09 (voice allocation mode A/B)
- M `N-0b145a01` KN5000 panel: 125 bytes keep f<offset> names
- M `N-10dad9c5` Sound record: envelope pair order, LFO captions, controller groups (pointer to N-b64487fc)
- M `N-1fe9a5df` Scoop unknowns: Str_TuningEq 2nd scheme, Unref_* tables, ClockConfig_Select_Table, 0x09s
- M `N-2f640c1d` 65 NAKA Viewable elements have no typed record (straddling members, DRAM, string blocks)
- M `N-45db7885` 73 numeric ROM addresses in the NAKA C (75 in v6/v5)
- M `N-52dcf02a` What IC307 sequence words encode
- M `N-583fb77c` KN5000 DSP slot packing for 16 effects
- M `N-7c99f0f2` 81 titles have no menu path (most TITLE_SE* pages)
- M `N-c49a6232` C side types split string runs as one member (East_ResNames_3EC_Strings[252])
- M `N-d352b868` IC307 entries with no selector (page 1, 0, 2 leftovers?)
- M `N-e40b7174` Sequencer edit titles' parameters 0x25FA-0x2662 per title
- M `kn5000-a1f` Song controller events 0xD0/0xD1/0xD3: which sub-CPU records they become
- M `kn5000-i2m` Effects DSP: the reverb micro-topology
- M `kn5000-j8z` KN5000: RhythmProc_ChannelMapTable spelled as code; MainSysCtrl case callees, HdaeRom_* misnamed
- M `kn5000-rld` KN5000 generic-label batches g1/g3/g5: 100 records not reviewed
- M `kn5000-rzg` Accompaniment: SYNCHRO & BREAK while running, and synchro stop
- M `kn5000-zc1` Rename the VoiceSlot_* song-memory family (scoop_display.s)
- L `N-51b2e19c` Flag bytes with most numeric uses (audio config, seq play state, accompaniment, SE flags)
- L `N-d8cf1242` 525 field_XX members in NAKA C (533 in v7/v6/v5)
- L `T-kn5000-v5-todo-port` KN5000 v5: 137 TODO(port) .byte rows with no v6 line
- L `T-kn5000-v6-todo-port` KN5000 v6: 93 TODO(port) .byte rows with no v7 line
- L `kn5000-3qp` Accompaniment: transposing rhythm-ROM pattern notes to the recognized chord
- L `kn5000-ax7` uPD6383 decode: the R1 cascade (bit-11 alternate lo12, f31 3..7, ACT 0x0B, classes 0/1/4)

**WSA1R** (1)

- M `kn5000-wxn` WSA1R naming leads of 2026-10-06/07 not yet checked

**KN7000** (91)

- S `N-01128b1c` Which image's SD-card reflection table is mispaired (KN2400 or KN7000)
- S `N-1666f99a` IvSDPlayTimer / IvSDFwdRewTimer field D may be 1 byte, not 2
- S `N-1af8fb95` StyleVariationNameGet misnamed: returns a count-in pattern record
- S `N-44a0a9c3` Odd wave entry Main_P00_E0AF (P bit 9 set)
- S `N-652c2321` Tail 0x170 of the 0x3C00 PANEL MEMORY copy slot unreferenced
- S `N-68397a99` 2 KB after PICTURE_PLANE2 (0x5011F080..0x5011F880) unreferenced
- S `N-716ca83b` GUI rect right / bottom inclusive is an inference
- S `N-79b9c8d3` Recording boundaries: run-out and pad sit inside the previous item
- S `N-8b2b22bb` Why every demo song opens with tempo value 250
- S `N-8ef7dde2` Order of part_more's nine fields in the part-field table
- S `N-a39cce89` Work-RAM 0x5000000C..0x50000010 (4 bytes after the jump stubs)
- S `N-b68f78f0` USER HP pictures' true box sizes (views behind GetBox)
- S `N-c62a74fa` Bitmaps without MT_GetBitCount assumed 4 bpp only when pixels end at next label
- S `N-c7bd31b3` Boot stack 0x500214F8..0x50021CF8: bottom inferred
- S `N-c94956b2` End of .bss 0x501749E8..0x50180000 (0xB618) unreferenced
- S `N-cc575880` P bit 12 (always set): meaning unknown
- S `N-cc77e1d6` 4 bytes past the slide-show pool end constant (0x50297FFC)
- S `N-ccdc980d` Rename SndCmdStreamWrite to the firmware's TgcBufWrite
- S `N-fb88572c` Invented names of 6,309 GUI objects with empty ResName are unstable
- S `N-ff12bec3` Bytes no longer typed after mn10300-typer (0xFFFFFFFF terminators, records, 935 map)
- S `T-kn7000-todo-after-the` KN7000 table: the 0x00 byte after the last pad, nothing reads it
- S `T-kn7000-todo-its-unit` KN7000 IC18 boot: PanelAtnCountdown, the unit it counts in
- S `T-kn7000-todo-memory` KN7000 IC18 boot: bus-controller register 0x32000010 not identified
- S `T-kn7000-todo-not-read` KN7000 IC18 boot: values not read by the reset code (0x8001 font word ...)
- S `T-kn7000-todo-nothing-in` KN7000 IC18 boot: PanelLinkConst7D read by nothing, PanelIrqSlot0 set by nothing
- S `T-kn7000-todo-only-the` KN7000 IC18 boot: 0x34004002 only the older link writes it
- S `T-kn7000-todo-purpose-unknown` KN7000 893: one byte after the library loader descriptor, before erased flash
- S `T-kn7000-todo-sdspiportsetup-writes` KN7000 IC18 boot: TGA_04 / TGA_10 tone-generator registers SdSpiPortSetup writes
- S `T-kn7000-todo-the-numbers` KN7000 IC18 boot: FatMountFailImage, nine words that describe no usable volume
- S `T-kn7000-todo-their-consumers` KN7000 IC18 boot: consumers of the TickJobs request bits
- S `T-kn7000-todo-their-roles` KN7000 IC18 boot: roles of PanelFrameDecode's frame bytes
- S `T-kn7000-todo-two-more` KN7000 IC18 boot: font header words beyond width and height
- S `T-kn7000-todo-whether-the` KN7000 table: JPEG placeholders ('27\n'): whether the Feature Demo asks for them
- S `T-kn7000-todo-which-device` KN7000 IC18 boot: which device the update status lamps are (StatusLedOff)
- S `T-kn7000-todo-who-sets` KN7000 IC18 boot: who sets SdUpdateWaitFlag
- M `N-027de254` Records whose pointer fields point into their own tail (switch descriptors)
- M `N-044cdbc6` Blocks handed only to memcpy / strcpy / LibStrlen stay rows
- M `N-1ad3d4d4` Name 935's and 893's own DSP host-port routines (0x48404D10..0x48407CA8)
- M `N-271d0bab` A rhythm note's last three bytes: length and class
- M `N-34fa7d2c` Pad +0x12..+0x15, TPAD +0x10..+0x15, TCMP variation head bytes: no reader
- M `N-3d2fa559` 'ZZZJ': what the 220 records and their eight entries select
- M `N-44e56012` What keeps the keyboard silent during the whole PICTURE LOAD screen
- M `N-564dcd72` KN7000 wave ROM page order: permutation of whole pages not excluded
- M `N-719cf65f` Drum kits' own key names (keys outside GS/GM range)
- M `N-71feb370` CC97 / CC94 / CC96 / CC80-83 effect on the sound not traced into the TG
- M `N-8af92404` Trace the type-4 Technics bulk SysEx handler 0x484C1B72
- M `N-92b0bf4c` Array record counts are inferences where readers check no bound
- M `N-a0f81837` Meaning of the wave directory's split list
- M `N-a504af0f` Meaning of the A/B halves of intros and endings
- M `N-a883f3f0` IC18 count-block bytes after the 220 and style byte +0x89 have no reader
- M `N-b562cfc1` Trace the 0x80 panel-memory recall set handler and the SysEx source tag
- M `N-cbaf135a` What plays after a recording's loop (release segment?)
- M `N-d8d7954f` {u32 key, code} dispatch tables named by shape; readers cited only where seen
- M `N-f5cfab22` Sound-unit keys 0x0044 / 0x1111 / 0x0B12 in units 0xB040 / 0xB050
- M `N-f839ba10` Name the unknown song-record event ids
- M `T-kn7000-todo` KN7000 styles: +0x89 byte (1 in every style, 173x); one IC18 SD R2 frame note
- M `T-kn7000-todo-what-the` KN7000 table: what the 220 ZZZJ SRAM default records configure
- L `N-2468beef` Fields stay offset-named (f0, p8, x2)
- L `N-90175c82` 893's func_ labels and its SD-card code (SdSnd* accessors) named only where 941 ports
- L `N-ad82330c` Blocks whose pointer a routine stores (SetApTimer, PutM3Em, _tr_init) stay rows
- L `N-b8f49b1e` IC21 fields still to trace: m<id> panel fields, voice-record single fields + 0x27-byte header, TCMP/style +0x70/pad bytes, the 24-field part set-up reader
- L `N-d753af29` 701 of BASEEXT.XAP's indirect calls go through non-framework MILK objects
- L `N-f3c6a3ea` IC21 factory banks: field-level questions (pointer to custom-data-ic21.md)
- the opaque groups (28): kn7000-b893 7, kn7000-b935 7, kn7000-program 7, kn7000-sp7001 7.  Work list: `kn7000/notes/mn10300-rest/README.md` section 7, "Readers found, typing not written in this lane"

**MN10300 siblings** (50)

- S `N-345ce6f1` KN2400: what func_4870587E does with the three words of each RamCodeTrailer record
- S `N-439d5da2` KN6000: four of the 13 bitmap procedures are func_<ADDR>
- S `N-61c32961` 29 / 8 bytes per sibling moved from typed tables into reader rows by the new joins
- S `N-986ec818` KN2400: title ids 0x000F000F / 0x000F0102 named by records but never registered
- M `N-0a03a134` KN6000: bitmap pixel order inferred; TABLE-tone/voice-record names not re-traced
- M `N-1f66216a` Siblings' reader walk lacks the KN7000 ext rules (field returns, loop slots, bounds)
- M `N-44fb32d4` KN6000: tables reached by computed offsets may still be split in two
- M `N-9eca4678` KN6500: 10,320 entries still func_<ADDR>; sibling-to-sibling name porting not done
- M `N-b318c54c` Sibling one-touch records: the bytes the PM_* macros keep as hex
- M `N-e7ed1928` KN2400: reflection-table procedures in the RAM-linked range are not paired
- M `N-f3294592` KN6000: 10,288 entries still func_<ADDR>; sibling-to-sibling name porting not done
- M `T-kn2400-todo` KN2400 built-in style: the byte at +0x89, 1 in every style, no reader found
- M `T-kn6000-todo` KN6000 built-in style: the byte at +0x89, 1 in every style, no reader found
- M `T-kn6500-todo` KN6500 built-in style: the byte at +0x89, 1 in every style, no reader found
- L `N-05cd19fe` KN6500: part of the data region is still .incbin_range
- L `N-4a4e97bc` KN6000: RAM and I/O addresses are numbers in the source
- L `N-5cad02df` KN2400: RAM and I/O addresses outside the RAM image are numbers in the code
- L `N-82a73a67` KN6500: RAM and I/O addresses are numbers in the source
- L `N-afa3d40e` KN6000: part of the data region is still .incbin_range
- L `N-be2b9da5` KN2400: 11,958 entries still func_<ADDR> (README says 11,993)
- L `N-cf9c7754` KN2400: the data region's remaining binary pieces
- the opaque groups (29): hdsx3 7, kn2400 8, kn6000 7, kn6500 7.  Work list: `kn7000/notes/mn10300-rest/README.md` section 7, "Readers found, typing not written in this lane"

**floppies** (7)

- S `N-391cb1d1` WSA1R floppy: block 838's 0xDF 0xF7 run
- S `O-wsa1-floppy-unknown-dump-66b9a5` WSA1R .SEQ: 250 B of free-block bytes that are not song events
- M `N-4c66be6c` KN6000: which path changes a sound without recomputing the .TM checksum
- M `N-b64487fc` Sound record: envelope pair order, LFO byte captions, controller groups
- M `N-e140c8dc` KN6000 / KN7000 .SQT: 1,768 + 5,270 stale bytes no event order explains
- M `O-kn6000-floppy-unknown-dump-397763` KN6000 .SQT: 126 x 1,768 B stale cell bytes neither event order explains
- M `O-kn7000-floppy-unknown-dump-397763` KN7000 .SQT: 96 x 5,270 B stale cell bytes (the demo cells' RAM noise, mostly)

**tooling** (2)

- M `N-700df83b` compress_lzss.py: encode SLIDE4K with lzss_j.encode instead of replaying decisions
- M `N-f67b155c` Move the shared callers to name-carrying macros (kn7asm and llvm-mc)

**documentation** (1)

- S `N-3a365d90` CLAUDE.md v6 / v5 verbatim figures and the Mines LLVM-workarounds section are stale

