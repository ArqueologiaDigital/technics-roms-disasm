# cc900 phase 6: firmware functions built from C (2026-11-16, lane_p6)

Phase 6 of `notes/cc900-compat-plan-2026-11-08/PLAN.md`: matching decompilation inside the disassembly.  Its
done-when is "the first firmware function built from our C is byte-identical in `make gate`; the ROM status diagram
gets a compiled C code class".  The owner decided on 2026-11-16 to start it before phases 3-5 finish.

## Milestone 1: the build rule

Four v10 main-CPU functions are now assembled from C, by our own tools only:

| function                     | C (`v10/maincpu/cc900/`) | hand source it replaces    | bytes |
|------------------------------|--------------------------|----------------------------|-------|
| `SetLswFilter`               | `ui_widget_defs.c`       | `ui/ui_widget_defs.s`      | 8     |
| `SetRootObject`              | `ui_widget_defs.c`       | `ui/ui_widget_defs.s`      | 6     |
| `BitMapOut_StorePresetValue` | `bitmap_out_routines.c`  | `ui/bitmap_out_routines.s` | 5     |
| `SmfMedley_RawData`          | `medley.c`               | `file_io/medley.s`         | 9     |

The chain, all of it in this repository or the pinned LLVM build:

1. `scripts/build/cc900_firmware_c.py` compiles `<tree>/cc900/<file>.c` with the cc900 reference model
   (`scripts/analysis/cc900/model/`: clang's front end, then `codegen.py`) at the options the six preview functions
   were matched with, `-O3 -XS -Xr` (`--opt O3XS --adecl`, personality `kn5000`).  The `CC900_*` environment
   variables are cleared first, so the build always runs the model's defaults.
2. `model/to_llvm.py` writes each function in our llvm-mc syntax with asm900's encodings.  With `to_llvm.SPELL`
   set, a named operand keeps the tree's name (`ld (LSW_FILTER:24), xwa`); the value, read from the tree's `.equ`,
   only picks the 16- or 24-bit form.  A RAM cell the tree has not named yet is written `ram_<hex>` in the C
   (`extern unsigned char ram_8d3e;`) and comes out as the number, as the hand assembly had it.
3. Each body goes to `<tree>/includes/generated/cc900/<function>.s` (git-ignored, removed by `make clean`).  The
   hand source keeps the label, its header comment and its place, and includes the body on the label's line:

       SetLswFilter:	.include "includes/generated/cc900/SetLswFilter.s"	; C: cc900/ui_widget_defs.c

4. `make` regenerates a C file's bodies when the C, any model module, the generator, the tree's sources (their
   `.equ` values choose operand widths), clang or llvm-mc change (Makefile, "Firmware C code").  `make gate` is the
   proof: the image must stay byte-identical.

No Toshiba program, listing or file is read: an audit hook on the generator's `open` calls (2026-11-16) saw only the
C file, the tree's `.s` files, the model's own `.py` files and clang's temporary files; nothing under
`~/compartilhado/cc900-oracle` and no model cache (`CC900_CACHE` is cleared).

Evidence, 2026-11-16:
- `make -j3 gate` in this worktree: exit 0, "PASS: every rebuilt ROM is byte-identical", every other gate check
  green.  The baseline run before the change was green too.
- The C is really in the chain: changing `medley.c`'s `(c != 0)` to `(c == 0)` and running
  `make rebuilt_ROMs/kn5000_v10_program.llvm.rom` changed exactly one byte, file offset 0x192c1b, the `scc`
  condition (0x7e `nz` to 0x76 `z`); restoring the C restored the image.
- `python3 scripts/analysis/data_range_census.py --images v10` reconciles (2,097,152 of 2,097,152 B) and reports
  "of CODE, compiled from firmware C ... v10 28 B" (9 + 8 + 6 + 5).

Not built from C, although the preview (`phase6-preview.md`) matched them: `TrimPad_NullTerminate` and
`FmtNum_WriteSpacePad` are not functions.  They are the last blocks of `TrimAndPadSmfFilename` and
`FormatMedleyNumber`, reached by `jr` and by falling through, so their match with a one-statement C function is a
coincidence of the tails.  They stay hand assembly; the whole routines are candidates for later.

### The ROM status diagram and the census

`scripts/analysis/data_range_census.py` keeps its five buckets.  A CODE region whose source file is under
`<tree>/includes/generated/cc900/` gets `compiled_c=True`, the results a `code_c` byte count, and the report a
line "of CODE, compiled from firmware C".  `scripts/build/generate_rom_status_diagram.py` paints those regions in a
seventh class, "Compiled C code (cc900 model)" (olive), and the former "Compiled C" class is now called "Compiled C
data (clang .incbin)".  Run against a scratch docs directory on 2026-11-16 it drew the class (28 B in main CPU
v10, shown in the block's caption as bytes while it is under 0.1%).  The website's copy of the diagram is not
regenerated in this lane.

### The diff tool

`scripts/analysis/cc900/model/fn_diff.py`, built on `check_bytes.py` (now importable: `assemble()`,
`load_reference()`), compiles a C file as the build does but with every name written as its address, so one
function assembles on its own:

    cd scripts/analysis/cc900/model
    python3 -I -B fn_diff.py ../../../../v10/maincpu/cc900/medley.c SmfMedley_RawData   # one function, in detail
    python3 -I -B fn_diff.py FILE.c                                                     # one row per function

The detailed form lists the model's instructions with their bytes beside the ROM's (`=` / `!`), MAME's unidasm
reading of the ROM there, and the first differing offset.

### Ledgers

`make doc-quality` after the change (`docs/coverage/doc-quality-2026-11-16-01`): v10's "routines without a header"
fell 5344 -> 5343, "call targets without a header" 2592 -> 2591 and "(number) operand elsewhere" 15812 -> 15810.  The
census does not read `includes/generated/`, so these falls are partly the instructions moving out of its view: the
two numeric operands now live in the generated bodies, written from the C's `ram_8d3e` / `ram_8944`, and the
header-less routine that dropped out is a label whose only line is now an `.include`.  `SmfMedley_RawData` was given
the header comment it lacked anyway; a second run after that gave the same counts, so the fall is the view, not
new documentation.

`make dispatch-census` after the change: "nothing rose" against `dispatch-census-2026-11-07-01`, and the new snapshot
differed from it only in its header line, so it was not committed.  `SetLswFilter` is a NAKA Function-table target
(`NAKA_FUNC_SetLswFilter`); its label is unchanged, and the census still sees it land on code.

## Milestone 2: 36 functions, in all five main-CPU trees

36 small leaf functions of Matsushita's code (getters, setters, two with a test) are built from C.  They are the
milestone-1 four and 32 more from `leaf_candidates.py`'s list, in 11 C files, one per hand source
(`<tree>/cc900/<hand source's name>.c`, whose header names the file: "Functions of ui/ui_widget_defs.s").
`scripts/tools/cc900_splice.py TREE FILE.c` replaces each function's hand body (its label up to its `ret`, with no
other label inside) with the include line, and leaves the header comment.

**Every main-CPU tree** (policy 9, multi-version sync): v9, v7, v6 and v5 have their own `cc900/*.c`, and the v9
tree's also builds v8.  The trees differ only in the addresses of the RAM cells written `ram_<hex>`.  v9 has v10's
addresses; v7, v6 and v5 have their own (v6 = v5), e.g. v10's `ram_8d3e` is `ram_8ca2` in v7 and `ram_8c86` in
v6 / v5.  The map was read from each tree's hand bodies of the same functions, before the splice, by `port_c_trees.py`
(here; it needs the unspliced sources, so it no longer reproduces from this commit), and every
tree's C was then checked with `fn_diff.py --tree <t>/maincpu --rom ... --symbols ...` against its own ROM: 36 of 36
in v9, v8, v7, v6 and v5.  The Makefile's `CC900_FIRMWARE_C` template gives each tree its stamp rule, and each
image's object depends on its tree's stamps.

**Options per function**.  `ui_widget_defs.c` is built at `-Xr` without `-O` (`cc900-options: -Xr`), because
`GetNamingWindowID` matches only there; every other function matches at either set.  `python3 -B
notes/cc900-phase6-2026-11-16/options_table.py` (v10, 2026-11-16):

| function                          | C file                   | -O3 -XS -Xr | -Xr | built with  |
|-----------------------------------|--------------------------|-------------|-----|-------------|
| BitMapOut_ByteData_DiskCheck      | bitmap_out_routines.c    | yes         | yes | -O3 -XS -Xr |
| BitMapOut_StorePresetValue        | bitmap_out_routines.c    | yes         | yes | -O3 -XS -Xr |
| BitMapOut_SetDefaultTimer         | bitmap_out_routines.c    | yes         | yes | -O3 -XS -Xr |
| BitMapOut_GetRenderMode           | bitmap_out_routines.c    | yes         | yes | -O3 -XS -Xr |
| BitMapOut_PrepareRender_CheckBit1 | bitmap_out_routines.c    | yes         | yes | -O3 -XS -Xr |
| BitMapOut_PrepareRender_CheckBit2 | bitmap_out_routines.c    | yes         | yes | -O3 -XS -Xr |
| Get_Region_Code                   | boot_routines.c          | yes         | yes | -O3 -XS -Xr |
| GET_COMPUTER_INTERFACE_SELECTION  | dsp_config_sysex.c       | yes         | yes | -O3 -XS -Xr |
| Display_SetBackgroundColor        | graphics_text_vga.c      | yes         | yes | -O3 -XS -Xr |
| GetPlayState1                     | medley.c                 | yes         | yes | -O3 -XS -Xr |
| GetPlayState2                     | medley.c                 | yes         | yes | -O3 -XS -Xr |
| SmfMedley_RawData                 | medley.c                 | yes         | yes | -O3 -XS -Xr |
| GetDialEnableState                | presentation_sound_nav.c | yes         | yes | -O3 -XS -Xr |
| SetDialEnable                     | presentation_sound_nav.c | yes         | yes | -O3 -XS -Xr |
| AccPlay_GetCurrentPart            | seq_event_playback.c     | yes         | yes | -O3 -XS -Xr |
| SeqData_SetErrorCode              | sequencer_engine.c       | yes         | yes | -O3 -XS -Xr |
| Xapr_GetPresentFlag               | test_init.c              | yes         | yes | -O3 -XS -Xr |
| GetCurrentPartSelect              | ui_control_panel.c       | yes         | yes | -O3 -XS -Xr |
| GetPartSelect                     | ui_control_panel.c       | yes         | yes | -O3 -XS -Xr |
| SeqState_HasModeChanged           | ui_control_panel.c       | yes         | yes | -O3 -XS -Xr |
| SetLswFilter                      | ui_widget_defs.c         | yes         | yes | -Xr         |
| ResetLswFilter                    | ui_widget_defs.c         | yes         | yes | -Xr         |
| SetRootObject                     | ui_widget_defs.c         | yes         | yes | -Xr         |
| GetRootObject                     | ui_widget_defs.c         | yes         | yes | -Xr         |
| GetRootEvent                      | ui_widget_defs.c         | yes         | yes | -Xr         |
| SetRootEvent                      | ui_widget_defs.c         | yes         | yes | -Xr         |
| GetRootParam                      | ui_widget_defs.c         | yes         | yes | -Xr         |
| SetRootParam                      | ui_widget_defs.c         | yes         | yes | -Xr         |
| GetFocusObject                    | ui_widget_defs.c         | yes         | yes | -Xr         |
| GetTitleNow                       | ui_widget_defs.c         | yes         | yes | -Xr         |
| GetTitleOld                       | ui_widget_defs.c         | yes         | yes | -Xr         |
| GetModeNow                        | ui_widget_defs.c         | yes         | yes | -Xr         |
| GetModeOld                        | ui_widget_defs.c         | yes         | yes | -Xr         |
| GetCurrentTarget                  | ui_widget_defs.c         | yes         | yes | -Xr         |
| SetCurrentTarget                  | ui_widget_defs.c         | yes         | yes | -Xr         |
| GetNamingWindowID                 | ui_widget_defs.c         | no          | yes | -Xr         |

Evidence, 2026-11-16: `make -j3 gate` exit 0, every image byte-identical.  `python3
scripts/analysis/data_range_census.py --images v10,v9,v8,v7,v6,v5` reconciles all six, with 232 B of CODE compiled
from firmware C in each.  `make doc-quality` (`doc-quality-2026-11-16-02`): nothing rose; in each tree, the
header-less routines and call targets fell by 31 (6 in v10, where milestone 1 had taken its share and the
`ui_widget_defs` getters had headers) and the numeric operands by 12 (10 in v10).  As with milestone 1, these are
labels and operands leaving the census's view, not new documentation.  `make dispatch-census`: nothing rose, and the
snapshot differed from `2026-11-07-01` only in its header line, so it is not committed.

### What the oracle said (run `2026-11-16-5-p6-m2a`, V4.23, `corpus/firmware/p6_m2a.c`)

The probe compiles variants of three v10 functions that the model did not reproduce from the first guess.  Read
against the ROM:

- (a) `GetNamingWindowID` returns the 32-bit constant 10, and the ROM loads it with the 5-byte `ld XHL,0xa` form.
  At `-O3 -XS -Xr`, V4.23 loads a 32-bit constant between 8 and 0xffff with `lda`, which asm900 assembles (the
  run's object file) to the 3-byte form our translator also writes.  The model has that rule, so the model is right.
  At `-Xr` without `-O`, V4.23 uses `ld`, the ROM's form.  So this function, and perhaps the whole source file it came
  from, was built without `-O`, or by a compiler that lacks the `-O` rule.  This bears on the `kn5000` personality.
  The other 15 functions of `ui_widget_defs.c` cannot tell the two option sets apart, and neither can the 20 in the
  other files.  A larger function with locals and branches is needed to settle each file's options.
- (b) `Medley_GetPlaybackStatus` clears HL with `xor` and then loads L from the byte at 0x1155, with no extension
  after.  None of six C variants gives that sequence at either option set.  The nearest, an int local set to 0 and
  then to the byte, at `-Xr`, clears HL with `ld` and extends after the load.  The C is unknown; the function stays
  hand assembly.
- (c) `VariScreen_IsHalfRangeAbove` shifts A right once, compares it with C and sets L with an 8-bit `scc`.  V4.23
  sets HL (16-bit `scc`) for all five variants, whatever the return type, so the C is unknown and the function stays
  hand assembly.

The same probe found three places where the model and V4.23 differ (bitfields, a narrowing cast of an int variable,
a compare of a promoted shifted char).  They were reported to the coordinator, who assigned them to a model lane.
None of them is in a built function.

### Tried, not built yet

`TrimAndPadSmfFilename` (55 B, two loops) through the model: the instruction choices differ from the ROM's from
the first instruction (counter in HL, not IX; the read pointer in XDE, not XHL; the character compared in memory,
not first loaded into E).  The C needs a character variable and probably a different loop shape.  This is the next
kind of target: big enough to tell `-O3 -XS -Xr` from `-Xr`.

## Finding candidates

`leaf_candidates.py TREE [N]` lists routines of at most N instructions that end in `ret`, contain no call, jump or
branch, are not entered by falling through, and are the target of at least one `call` / `calr`.  On v10 with N = 4
(after milestone 1) it lists 281: 101 of one instruction (empty functions), 120 of two, 36 of three and 24 of four.
Some are data decoded as code (`SeMenu_*` rows such as `ld (xwa), (0x6c5)`) and must be skipped.

    python3 notes/cc900-phase6-2026-11-16/leaf_candidates.py v10/maincpu 4
