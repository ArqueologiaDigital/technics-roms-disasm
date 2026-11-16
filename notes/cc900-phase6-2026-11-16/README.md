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
| `Smf_SetMidiOut`          | `medley.c`               | `file_io/medley.s`         | 9     |

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
    python3 -I -B fn_diff.py ../../../../v10/maincpu/cc900/medley.c Smf_SetMidiOut   # one function, in detail
    python3 -I -B fn_diff.py FILE.c                                                     # one row per function

The detailed form lists the model's instructions with their bytes beside the ROM's (`=` / `!`), MAME's unidasm
reading of the ROM there, and the first differing offset.

### Ledgers

`make doc-quality` after the change (`docs/coverage/doc-quality-2026-11-16-01`): v10's "routines without a header"
fell 5344 -> 5343, "call targets without a header" 2592 -> 2591 and "(number) operand elsewhere" 15812 -> 15810.  The
census does not read `includes/generated/`, so these falls are partly the instructions moving out of its view: the
two numeric operands now live in the generated bodies, written from the C's `ram_8d3e` / `ram_8944`, and the
header-less routine that dropped out is a label whose only line is now an `.include`.  `Smf_SetMidiOut` was given
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
| Smf_GetPlayAsGm                     | medley.c                 | yes         | yes | -O3 -XS -Xr |
| Smf_GetMidiOut                     | medley.c                 | yes         | yes | -O3 -XS -Xr |
| Smf_SetMidiOut                 | medley.c                 | yes         | yes | -O3 -XS -Xr |
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

### The built C under V4.23 (run `2026-11-16-13-p6-firmware`, lane_dash)

lane_dash compiled the 55 milestone-2 C files of all five trees with V4.23, at `-O3 -XS -Xr` and `-Xr`.
- **One file refused.**  V4.23 refused `bitmap_out_routines.c` in every tree with THC1-Error-262: cc900 keeps 31
  characters of an identifier, and `BitMapOut_PrepareRender_CheckBit1` / `_CheckBit2` agree in their first 31.  So
  those 6 functions were not compiled.
- **The other 30 functions.**  Against the ROM through the proxy route
  (`scripts/analysis/cc900/asm_vs_rom.py`: the listing through `to_llvm.py`, which gives each operand the
  firmware's 16- or 24-bit width), they are 30 of 30 at `-Xr` in each of v10, v9, v7, v6 and v5, and 29 of 30 at
  `-O3 -XS -Xr`.  The one that differs is `GetNamingWindowID` (finding (a)).
- **No other function fails.**  The run's "30 of 36" is these 30, and the 6 missing are the refused file.
- **Why compare through the listing.**  asm900's own objects (`rel_vs_rom.py`) differ wherever a function
  addresses a RAM cell below 0x10000: the listing declares every extern `large`, so asm900 writes a 24-bit operand
  where the firmware has a 16-bit one.  That is the address-width question of the preview, not a code difference.
- `GET_COMPUTER_INTERFACE_SELECTION` (32 characters) compiles: V4.23 cuts its public name to 31 characters, and
  `asm_vs_rom.py` finds it by those.

The coverage page (`c_build_coverage.py`, commit 0794fd6a7) showed `BitMapOut_PrepareRender_CheckBit1` / `2` as
"V4.23 differs".  That was the page's name lookup, not V4.23: it looked V4.23's functions up by the tree label,
while the listing names them by the short C names.  Run 18 matches both, 5 of 5 bytes (`asm_vs_rom.py`).
`c_build_coverage.py` now maps the listing's names through the file's `cc900-name:` comments.

**The fix.**  A C file may give a function a shorter name and map it to the tree's label in a comment:
`cc900-name: BitMapOut_PrepRender_CheckBit1=BitMapOut_PrepareRender_CheckBit1`.  The generator, the splice,
`fn_diff.py` and `options_table.py` then use the label.  The generator also stops on two C names that agree in
their first 31 characters, so every built C file stays one that V4.23 can check.  `bitmap_out_routines.c` uses it
in all five trees; v10, v9, v8, v7, v6 and v5 rebuilt byte-identical.

## Batch 3: 45 more small functions (2026-11-16)

Four more hand sources now take their small leaf functions from C, in all five trees.  The functions come from
`leaf_candidates.py`'s list:
- `audio/semenu_routines.s`: 21 setters and two notification routines;
- `sequencer/seq_audio_mode.s`: 7;
- `boot/system_handlers.s`: 6;
- `demo/file_demo_proc.s`: 11.

That is 45 per tree.  v6 and v5 have no `SeMenu_CopyWriteUpdate_Step3_Helper14`, so they have 44.
`port_c_trees.py` now reads 8-, 16- and 24-bit operands, and the older spellings without a width (v7's
`stb_d8 (0x6ad), a`).  It drops a one-line function, and the cells only it used, from a tree that lacks the
function.  Every tree's C was checked against its own ROM with `fn_diff.py` before the splice: 45 of 45 in v10, v9,
v8 and v7, 44 of 44 in v6 and v5.

Left as hand assembly, with the reason:
- `SeMenu_AdvanceSubIndex` loads the byte, increments it in L and stores it.  Neither `++x` nor a local copy gives
  that.
- `SeMenu_SetupMenuDisplay_Section3_End` and `VariScreen_IsHalfRangeAbove` set A or L with an 8-bit `scc`.  V4.23
  never does so in the variants tried (finding (c)).
- `Timer3_Stop` is `res 3,(T8RUN)` on an SFR, where `&= ~8` gives an `and` of memory: hand assembly, or inline asm.
- `SeMenu_SetPartConfigBit3`, `SeMenu_GetPartConfigBit3`, `SeMenu_LoadMasterPtr` and `Sys_CheckPowerStableFlag`
  address a cell below 0x10000 with a 24-bit operand (`(58338:24)`, `(PART_SELECT:24)`, `(0xffcc:24)`).  The build
  chooses the width from the address, as asm900 does for the firmware's own variables.  These accesses look like
  `extern` declarations of another module (the preview's `large` externs).  They need a per-name width in the C
  first.
- The `SeMenu_Get*` / `SeMenu_Load*` rows spelled `ld (xwa), (0x6c5)` / `ldmi16 (xwa), 0x6b4` are misdecoded in the
  hand source and were not tried.

A model refusal met on the way: returning an extern array's name as a pointer (`return ram_25eaa;`, `unsupported:
var`).  `return &ram_25eaa;` with a byte declaration gives the ROM's `lda` and is what the C uses.

## Batch 4: larger leaf functions, V4.23 first (2026-11-16)

Candidates come from a wider scan (`leaf_routines.py`, in `research-scratch`): leaf routines of 5 to 20 instructions
with branches, from a called label to the next one.  633 in v10; this round took those in files that already have
C.  Much of `boot/system_handlers.s` is plainly hand assembly: ring buffers whose comments say "Preserves IX and
XDE", `pushw` / `popw` around a load and a store.  It was left alone.

| function                         | C file              | bytes | model   | V4.23 (run `2026-11-16-20-p6-m8`, `asm_vs_rom.py`) | option set             |
|----------------------------------|---------------------|-------|---------|----------------------------------------------------|------------------------|
| `CheckNotDrawFlag`               | `ui_widget_defs.c`  | 14    | MATCH   | -                                                  | `-Xr` (the file's)     |
| `SeMenu_InterpolateEdgeX`        | `semenu_routines.c` | 9     | MATCH   | -                                                  | default                |
| `SeMenu_StoreAbsoluteValue`      | `semenu_routines.c` | 9     | MATCH   | -                                                  | default                |
| `SeMenu_CheckObjEnabled`         | (not built)         | 13    | DIFF    | MATCH, `int r = -1; if (g == a) r = 0; return r;`  | both                   |
| `SeMenu_SetEditEnable`           | (not built)         | 14    | DIFF    | MATCH, `if (a == 1) g \|= 4; else g &= ~4;`        | both                   |
| `Rhythm_CheckHighBitFlag`        | (not built)         | 13    | DIFF    | MATCH, `return (g & 0x80) >> 7;`                   | **`-O3 -XS -Xr` only** |
| `SeqAcc_UpdateEndPosition`       | (not built)         | 15    | DIFF    | MATCH, a local copy compared and stored            | both                   |
| `SeMenu_SetNameBufferChar`       | (not built)         | 18    | refused | MATCH, `if (i > 15) return; buf[i] = c;`           | both                   |
| `SeqPlay_WriteErrorToVoiceTable` | (not built)         | 21    | DIFF    | differs in all 3 forms                             | -                      |
| `SeMenu_StoreEffectCoeff`        | (not built)         | 13    | refused | differs in all 3 forms                             | -                      |

The five where V4.23 matches and the model does not are model gaps, reported to the coordinator with the run:
- `res` for `&= ~bit` on a byte;
- a shifted byte computed in A and moved to L;
- a local held in WA, not BC;
- a `-1` preloaded before the compare;
- the refusal "a byte into a word".

`Rhythm_CheckHighBitFlag` matches only with `-O`, like `TrimAndPadSmfFilename`: `sequencer_engine.c` is at the
default `-O3 -XS -Xr`.  `SeqPlay_WriteErrorToVoiceTable` uses the memory-to-memory `ld (0x287a),(XBC+WA)`, which no
form gave.

`cc900_splice.py --symbols` now drops an assembler-local `.L` inner label (v6 / v5's `SeMenu_StoreAbsoluteValue`),
but only when a branch earlier in the same body targets it; otherwise the label ends the body.

## Round 8: probes m9 / m9c (runs `2026-11-16-22-p6-m9`, `-23-p6-m9c`)

15 larger leaf functions of `display/graphics_text_vga.s`, `audio/dsp_config_sysex.s`, `demo/file_demo_proc.s` and
`sequencer/seq_event_playback.s`, each in two C forms (`corpus/firmware/p6_m9a.c`, `p6_m9b.c`).  The four
`FileIO_*` bit functions have a third form (`p6_m9c.c`).
- **V4.23 reproduces the ROM** for `FontGlyph_ByteData` (both forms, both sets) and for
  `SysEx_ClampVoiceIndex128_49` / `SysEx_ClampVoiceIndex8_49` (form a, both sets).  The model does not:
  - it refuses `FontGlyph_ByteData`'s form a and differs on form b;
  - on the clamp functions it differs on form a (it indexes with BC from XDE, the ROM with WA from XBC).
  
  These are model gaps.
- **The model disagrees with V4.23** on the clamp functions' form b (`return T[a < 0x80 ? a : 0];`).  The model
  gives the ROM's bytes, V4.23 does not.  So form b is not the firmware's C; the clamp functions wait for the gap
  on form a.
- **Shift by a variable count.**  For `1 << a` and for `1U << a` alike, V4.23 writes the arithmetic `sla A,BC`.
  The ROM has the logical `sll A,BC` (`slla bc`) in the `FileIO_*` bit functions.  The model writes `sll` for the
  unsigned form, in the `v4.23` personality too.  So the model disagrees with V4.23, and agrees with the ROM.
  v10 holds both forms (126 `slaa`, 44 `slla`, 4 `sraa`, 40 `srla`), which fits a Technics rule "logical shift
  for an unsigned value", where V4.23 always uses the arithmetic one.  This is a candidate `kn5000` rule, reported
  to the coordinator.  With `1U << a` and the clear written `&= (1U << a) ^ 0xffff` (the ROM complements with
  `xor BC,0xffff`, V4.23 and the model with `cpl` for `~`), the model gives the ROM's bytes for three of the four.
  They are not built until the rule is decided in the model: built now, they would change as soon as the model's
  `v4.23` personality is corrected.
- **Memory-to-memory moves.**  `Demo_SelectEntry_LoadPattern` and batch 4's `SeqPlay_WriteErrorToVoiceTable` store
  an indexed table entry with one `ld (mem),(XBC+WA)`; V4.23 loads it into WA and stores WA.  v10 holds 275
  memory-to-memory moves (217 `ld`, 58 `ldw`), 38 of them from an indexed source.  This is a candidate
  `kn5000` rule, or partly hand assembly; reported.
- **Constant-pointer indexing.**  `SetPaletteRGB`, `Table_LookupDword` and `_Read_VGA_Register` index from a
  constant address loaded with the 5-byte `ld xR, imm`.  V4.23 differs from both forms at +2 / +5, and the model
  refuses them.  The C is unknown.

`to_llvm.py` learned the shift-by-A forms: the listing's `sla` / `sll` / `sra` / `srl A,r` become llvm-mc's
`slaa` / `slla` / `sraa` / `srla r`.  `asm_vs_rom.py` also tries a label with a leading underscore, which the
listing's name prefix hides (`_Read_VGA_Register`).

Coordinator decision, same day: the unsigned shift becomes a firmware rule, `KN_SHIFT_UNSIGNED_SLL`.  Like
`KN_LOOP_INVERT`, it is off in the model and on in `cc900_firmware_c.py`'s `FIRMWARE_RULES`.  The model's `v4.23`
personality gets `sla`, as V4.23 has.  The three `FileIO_*` functions are built once the rule is in the model.  The
memory-to-memory move stays a candidate, until more firmware functions need it.

## Round 9: `sequencer_engine.s` (probe m11, run `2026-11-16-24-p6-m11`)

`corpus/firmware/p6_m11.c`: 13 larger leaf functions of `sequencer/sequencer_engine.s`.  The model and V4.23 agree
with the ROM, at both option sets, on three; they are built in all five trees (`sequencer_engine.c`; v6 / v5 read
the part count at 0x2885, v10 / v9 / v7 at 0x28a1):
- `Seq_ValidatePartNumber`: 17 B;
- `Seq_ValidateTempoValue`: 17 B;
- `SeqScan_ClearNoteRange`: 13 B.

The rest, with V4.23 also differing, need other C:
- the six `PartCtrl_*` accessors of the 256-byte part records at 0xb0000, which the model refuses
  ("complex pointer");
- `Rhythm_ComputeNoteIndex`;
- `VoiceAlloc_InitBitMap` and `SeqBuf_ClearRange` (an end pointer computed with `lda`, +155 / +6);
- `SeqStatus_SetOrClearBit`.

## Round 10: files without C yet, 20-80 bytes (probe m13, run `2026-11-16-26-p6-m13`)

The next candidates come from `leaf_routines.py` at 6 to 40 instructions, in hand sources that have no C yet.  There
are 504 in v10; `sequencer/accompaniment_engine.s` has 133 and `audio/note_voice_mapping.s` 50.  This round took
`sequencer/bmdredit_routines.s` (`corpus/firmware/p6_m13.c`, 7 functions).

| function                       | bytes | model                                      | V4.23                    |
|--------------------------------|-------|--------------------------------------------|--------------------------|
| `BmDrEdit_DecrementDelayA`     | 21    | DIFF: tests bit 7 with `and` + `cp`        | MATCH (both sets)        |
| `BmDrEdit_DecrementDelayB`     | 21    | DIFF: the same                             | MATCH (both sets)        |
| `BmDrEdit_LoadAlternateState`  | 35    | DIFF                                       | DIFF: copies through WA  |
| `BmDrEdit_AlignDisplayGrid`    | 21    | refused ("constant condition")             | DIFF                     |
| `BmDrEdit_AlignGridBackward`   | 33    | DIFF                                       | DIFF                     |
| `BmDrEdit_CheckSlotsAvailable` | 30    | refused ("complex pointer index")          | DIFF                     |
| `BmDrEdit_SaveSongPosition`    | 34    | refused ("local o")                        | DIFF                     |

The two delay functions are a model gap: V4.23 tests `(a & 0x80)` with `bit 7,A` / `ret eq`, where the model
writes `ld C,A` / `and C,0x80` / `cp C,0`.

`BmDrEdit_LoadAlternateState` copies four globals into four others.  The ROM does it with memory-to-memory moves
(`ldmm16` / `ldmm8`); V4.23 loads into WA and stores.  v10 holds 397 `ldmm16` and 169 `ldmm8`, besides the 275
`ld (m),(m)` forms of round 8.  The memory-to-memory candidate rule now has much wider evidence: the Technics
compiler copies a value from memory to memory directly.

## Round 11: `note_voice_mapping.s` (probe m14, run `2026-11-16-27-p6-m14`)

`corpus/firmware/p6_m14a.c` / `p6_m14b.c`: five larger leaf functions, two C forms each.
- **`LinkVoiceSlots_LoadReg`** (22 B): V4.23 gives the ROM's bytes with form a
  (`if (p[c].b == c) return 0; return 1;`) at **`-Xr` only**.  So this part of `note_voice_mapping.s` was built
  without `-O`: the file carries both `-O` markers (154 `lda` / 150 `ld` constants), like
  `accompaniment_engine.s`.  The model refuses it ("memory load member"): a gap.
- **`FileIO_InitTrackSlots` / `SysexRingBuf_Init`**: a 2048-byte ring buffer at a constant address.  V4.23 matches
  the first 18 of 44 bytes (form a); the clear loop's body differs.  The model refuses both ("lvalue index").
  V4.23 writes the members of a struct at a constant address as numeric absolute operands (`ldw (0xd0a8),0x0`),
  which `to_llvm.py` could not translate; it now can (the same 8 / 16 / 24-bit width rule).
- `Voice_SetDecayTimer` and `SndParam_CompactLookupStub` need other C.
- The chord routines (`NoteDisplay_*`, `VoiceSlot_Epilogue_Block`) address `CHORD_FLAGS` and the other chord
  variables (0xcede..) with 24-bit operands.  They wait for a per-name width in the C, the preview's `large`
  externs.

## The memory-to-memory rule's condition (census, 2026-11-16)

The coordinator decided the moves are the Technics compiler's own idiom, to become the firmware rule
`KN_MEM_TO_MEM` (off in the model, on in `FIRMWARE_RULES`), and asked when it applies.  The census is
`python3 notes/cc900-phase6-2026-11-16/mem_copies.py v10/maincpu [--by-file]`.

**The hardware.**  The TLCS-900 has two memory-to-memory moves, byte and word only:
- `ld (#16),(mem)`: the destination a 16-bit absolute address, the source any mode;
- `ld (mem),(#16)`: any destination, the source a 16-bit absolute address.

There is no 32-bit form, and no form with two 24-bit sides.

**When the firmware uses them: in the `-O` files.**  The marker of `-O` is a 32-bit constant of 8..0xffff loaded
with `lda`, which V4.23 writes only with `-O` (round 7).  Per hand source, the moves and the dead register copies
that have a 16-bit absolute side (8 / 16 bits):

| file                             | moves | reg copies | lda 8..0xffff | ld 8..0xffff |
|----------------------------------|-------|------------|---------------|--------------|
| sequencer/sequencer_engine.s     | 406   | 28         | 376           | 188          |
| sequencer/accompaniment_engine.s | 57    | 218        | 80            | 232          |
| audio/note_voice_mapping.s       | 92    | 2          | 154           | 150          |
| audio/audio_control_engine.s     | 68    | 11         | 58            | 137          |
| sequencer/bmdredit_routines.s    | 67    | 5          | 14            | 2            |
| sequencer/seq_step_routines.s    | 64    | 1          | 2             | 0            |
| sequencer/rhythm_routines.s      | 0     | 41         | 0             | 4            |
| display/scoop_display.s          | 0     | 34         | 0             | 336          |
| sequencer/accompseq_routines.s   | 0     | 31         | 0             | 15           |
| storage/flash_floppy_handlers.s  | 23    | 0          | 44            | 25           |
| sequencer/seq_audio_mode.s       | 0     | 18         | 0             | 50           |
| audio/semenu_routines.s          | 16    | 0          | 16            | 2            |
| storage/fdc_routines.s           | 14    | 0          | 4             | 0            |
| sequencer/smf_event_processor.s  | 0     | 11         | 0             | 50           |
| midi/midi_dispatch_handlers.s    | 9     | 0          | 32            | 163          |
| sequencer/smf_tonegen_core.s     | 0     | 8          | 0             | 146          |
| ui/ui_control_panel.s            | 5     | 0          | 0             | 15           |
| audio/audioinit_routines.s       | 4     | 0          | 6             | 0            |
| ui/setwall_routines.s            | 0     | 4          | 0             | 40           |
| file_io/disk_operations.s        | 3     | 0          | 17            | 29           |
| audio/sound_editor_ui.s          | 2     | 1          | 16            | 23           |
| sequencer/smf_playback.s         | 0     | 3          | 0             | 15           |

- **Files without the `-O` marker** (`rhythm_routines`, `scoop_display`, `accompseq_routines`, `seq_audio_mode`,
  `smf_event_processor`, `smf_tonegen_core`, `setwall_routines`, `smf_playback`) have **no move at all**: 0 of their
  150 copies.  They copy through a register even when a move was possible.
- **Files with the marker** move almost everywhere.  `accompaniment_engine.s` has both markers, so it holds code
  of both kinds; it is large enough to be several original source files.  `ui_control_panel.s` (5 moves, no
  `lda`) has too few constants to tell.
- **V4.23 never moves**, at any of the four option sets (run 26's `BmDrEdit_LoadAlternateState`: `ld WA,(src)` /
  `ld (dst),WA` at none, `-O3 -XS`, `-Xr` and `-O3 -XS -Xr`).

**The condition, as far as the census shows.**  With the Technics compiler's `-O`, a copy whose value is not used
again is a memory-to-memory move when:
- its size is 8 or 16 bits (a 32-bit copy always goes through a register: 14 in the `-O` files, no move);
- one side is a 16-bit absolute address.  With the destination absolute it is `ld (#16),(src)`, and the source
  may be any mode: absolute (533), indexed `(xrr+rr)` (36), indirect, displacement or stack.  With only the source
  absolute it is `ld (dst),(#16)`, for example a stack slot (64), indirect (28) or a displacement (11).

Without `-O` it is never a move.  Open:
- About 110 dead register copies of 16-bit globals remain in `-O` files.  Many of them are in groups just before a
  call (`audio_control_engine.s` `MidiCtrl_Mode3_Handler`, `VoiceMode3_EvType4`).  Either they come from a source
  file without `-O` merged into the same hand source, or the following call matters.  A probe can tell.
- Whether a value used again afterwards (`reused`, kept in its register) prevents the move in `-O` code.  The
  census sees reused copies only as register copies, as expected, but has not tested the reverse.

## Larger targets and the -O question (2026-11-16, after milestone 2)

The reference model refuses the C of both larger targets, so V4.23 in the oracle VM was used as the local
checking aid.  `scripts/analysis/cc900/rel_vs_rom.py` compares a run's object file (asm900's bytes) with the ROM,
function by function, and prints only MATCH or the first differing offset.  Three runs:
- `2026-11-16-9-p6-m3`, `corpus/firmware/p6_m3.c`;
- `2026-11-16-10-p6-m3b`, `p6_m3b.c`;
- `2026-11-16-11-p6-m3c`, `p6_m3c.c`.

All at the holdout options.  For example, from `scripts/analysis/cc900`:

    python3 -I -B rel_vs_rom.py ~/compartilhado/cc900-oracle/runs/2026-11-16-10-p6-m3b/out/v423/O3XSXr/firmware/p6_m3b.rel \
        FormatMedleyNumber fmt

| function (v10)          | C                            | V4.23 -O3 -XS -Xr          | V4.23 -Xr      | reference model                     |
|-------------------------|------------------------------|----------------------------|----------------|-------------------------------------|
| `FormatMedleyNumber`    | `p6_m3b.c` `fmt_e`           | MATCH, 108 B               | MATCH, 108 B   | refuses (`goto`; at -O a register)  |
| `TrimAndPadSmfFilename` | `p6_m3.c` `trim_a` (8 forms) | first 42 of 55 B identical | differs at +0  | refuses                             |

- **`FormatMedleyNumber`.**  The C that gives the ROM's bytes uses `goto`.  The 0xff and 0xfe arms set the
  character and fall into the space padding; any other entry jumps to the number code.  `if` / `else` and `switch`
  forms give the same instructions, but V4.23 then places the padding after the first arm.  Both option sets give
  the same bytes, so this function says nothing about `-O`.  The model refuses the C: without `-O`, `goto` is
  unsupported; at `-O3 -XS -Xr`, "ld A,C over the live parameter p in WA".  That was a model gap, reported to the
  coordinator.  **Built since batch 361** (lane_o3 fix 25: `goto` and these shapes): `fmt_e` is now
  `FormatMedleyNumber` in `medley.c` of all five trees, 108 of 108 bytes (`fn_diff.py`).  Its six inner labels
  (`FmtNum_CheckMarked` ... `FmtNum_WriteTwoDigits`) keep their names and addresses: `cc900_splice.py --symbols`
  takes the function's extent from the size of its compiled C and writes each inner label after the include as
  `.set FmtNum_WriteM, FormatMedleyNumber + 61`, its offset read from the symbols reference.
- **`TrimAndPadSmfFilename`** (`file_io/smf_operations.s`).  With a character variable and two pointers that start
  equal, V4.23 at `-O3 -XS -Xr` gives the ROM's first 42 bytes:
  - the whole first loop, whose compound `&&` condition is tested at the bottom, entered by a jump;
  - the counter in IX, the read pointer in XHL, the character in E.
  
  At `-Xr` the bytes differ from the first instruction.  So this function was built with `-O`.  Its padding loop is
  the only difference.  The ROM tests `i < n` before entering and again at the bottom.  V4.23 compiles every form
  tried to a jump to a bottom test: `while`, `for`, an explicit `if (...) do ... while`, and two hand-made `goto`
  loops.  That is a candidate `kn5000` rule (loop inversion for a simple condition, not for a compound one),
  reported to the coordinator for the rule list.
  
  **Since batch 362** (lane_o3 fix 26, `ASSIGN_TARGET_WRITE`), the model compiles `trim_a` as V4.23 does.  With the
  rule loop-entry-copy (lane_p6 fix p6-02, `KN_LOOP_INVERT`, which only the firmware build switches on), it gives
  all 60 bytes of `TrimAndPadSmfFilename`, `TrimPad_NullTerminate`'s tail included (`fn_diff.py`).  The first form
  of the rule (fix p6-01) was on for the whole `kn5000` personality.  It lost library and `ide2003` micro functions
  in the full ledger and was backed out.  `rules.md` has the account.  **Built since batch 363** (p6-02 in the
  model): `smf_operations.c` in all five trees, the function being identical in each.  Its eight `TrimPad_*` inner
  labels are kept as `.set` offsets.  `make -j3 gate` passed.

**Loop shapes across v10** (the idiom census for that candidate rule): `python3
notes/cc900-phase6-2026-11-16/loop_shapes.py v10/maincpu`, 2026-11-16.  A loop is a backward conditional branch;
its entry is read from the instruction before its top (the script's docstring defines each shape):

| shape                  | loops |
|------------------------|-------|
| fall-in                |  2113 |
| inverted, same test    |   332 |
| jump-to-test, simple   |   270 |
| inverted, other test   |   229 |
| djnz                   |   118 |
| jump-to-test, compound |    74 |
| total                  |  3136 |

It classifies both of `TrimAndPadSmfFilename`'s loops as the ROM has them: the padding loop "inverted, same test",
the first "jump-to-test, compound".  Both shapes are common with a simple condition, and both occur in the same
files (`audio/note_voice_mapping.s` holds 100 inverted and 69 jump-to-test simple loops).  Neither the kind of
compare (register, immediate or memory) nor the branch condition separates them.  So "a simple condition is
inverted" is not the rule.  In `TrimAndPadSmfFilename` the ROM's entry test stands exactly where V4.23 put its
`jr` to the bottom test, which suggests the firmware's compiler replaces a jump to the test with a copy of it.
What decides is the length of the test (`--test-blocks`).  The block a jump-to-test loop jumps to (from the jump's
target to the bottom branch) is one instruction in 29 loops, two in 40, three in 75 and four or more in 200.  An
inverted loop's copied test is a single compare.  So 332 loops whose bottom test is one compare and branch have
that test copied to the entry.  Only 29 such loops jump to it instead, 7 of them in `audio/sprintf_core.s`, the
Toshiba library code that V4.23-like tools built.  Two things that do not separate the shapes, checked the same
day with throwaway queries: whether another branch targets the loop's entry, and the loop body's length (medians
15 and 17 instructions).

The candidate rule is now: **the firmware's compiler copies a loop test of one compare and branch to the loop
entry; for a longer test it jumps to the test; V4.23 always jumps**.  Its exceptions are the 22 one-compare
jump-to-test loops outside the library.  Some of these may be hand assembly (`storage/fdc_routines.s`, the
self-test bit loops in `ui/ui_mode_handlers.s`); `--list` and the file list name them for checking.
`--list "<shape>"` prints every loop of a shape with its file, line and label.  The census reads the source, so
hand assembly is counted too (`fall-in` also holds do-while loops and retry branches).

**What this says about the options.**  `GetNamingWindowID` (`ui/ui_widget_defs.s`) matches only without `-O`, and
`TrimAndPadSmfFilename` (`file_io/smf_operations.s`) only with it.  Two explanations fit:
- the source files were built with different options;
- the firmware's compiler at `-O` lacks V4.23's rule that loads a 32-bit constant of 8..0xffff with `lda`.

Telling them apart needs one function that both loads such a constant and is shaped by `-O` (a loop, or a value
kept in a register).  The candidates are leaf routines with a loop and a 32-bit load of a value below 0x10000, almost
all of them addresses of RAM buffers.  There are 59 in v10 (`python3 -B
notes/cc900-phase6-2026-11-16/const_loop_leaf.py v10/maincpu`, from the repository root), and they come in both
forms.  `StyleConv_ClearWorkBuffer` (`sequencer/accompaniment_engine.s`) is `-O`-shaped (the end pointer is
computed from the start register, and the loop has no entry test) and uses the 4-byte `lda xbc, (0x488c:16)`.
`FloppyIO_ClearTrackParseBuffer` (`sequencer/smf_tonegen_core.s`) uses the 5-byte `ld xix, 0x106e` and `djnz`.
Probe `corpus/firmware/p6_m4.c` (run `2026-11-16-12-p6-m4`) was to compile both at both option sets.  Instead,
V4.23's code generator crashed at every option set, before emitting a function (a page fault reading 0x4890, four
bytes past the C constant pointer 0x488c), and asm900 then refused the output.  The crash is reported to the
coordinator as a V4.23 bug.  The isolation run `2026-11-16-14-p6-m4-split` compiled one function per file
(`p6_m4_<function>.c`, `corpus/p6_m4_split-sources.txt`).  Only `sc_b` and `va_b` crash: a `for` loop whose
condition compares the pointer with a constant pointer plus an offset, `p < (unsigned char *)0x488c + 32`.  The
crash happens at every option set; at `-O3 -XS` `va_b` stops with exit 1 instead of the page fault.  The same
loop written with an end pointer variable (`sc_a`, `sc_c`, `va_a`) compiles.

Against the ROM (`rel_vs_rom.py`), no variant is byte-identical, but the first instruction decides the question:
- the ROM's `StyleConv_ClearWorkBuffer` loads the buffer address with the 4-byte `lda` of an absolute below
  0x10000, then copies it and adds 32 for the end pointer;
- V4.23 at `-O3 -XS -Xr` (`sc_a`) writes that same first instruction, then folds the end address differently;
- V4.23 at `-Xr` writes the 5-byte `ld` of the 32-bit constant and differs from the first byte.

So the firmware's compiler does use V4.23's `-O` rule (`lda` for a 32-bit constant of 8..0xffff) in this
`-O`-shaped function of `sequencer/accompaniment_engine.s`.  `GetNamingWindowID`'s `ld` then points to its file
being built without `-O`: **per-file options is the better explanation**, not a compiler without the rule.  The
caveat: here the constant is a pointer, there an integer.  V4.23 treats both alike at `-O`; a compiler that
distinguished them would be a new behaviour, and nothing seen so far suggests one.
`FloppyIO_ClearTrackParseBuffer`'s `ld xix, 0x106e` with `djnz` matches neither option set from `fl_a` / `fl_b`
(both differ at +0); it may be hand assembly or another C.  `ui_widget_defs.c` stays at `-Xr` because that is the set that reproduces all 16 of its
functions; the choice is recorded in its `cc900-options:` comment.

## Names from the GUI (2026-11-16, owner)

`medley.c`'s two RAM cells are the SMF DIRECT PLAY page's toggles (`ui_widgets/naka_disk_menu_file_io.c`):
- PLAY AS (GM 1 / TECH 0) is `SmfPlayAsGm`;
- MIDI OUT (on / off) is `SmfMidiOut_OnOff`.

The cells are 0x8942 / 0x8944 in v10 and v9, 0x88a6 / 0x88a8 in v7, 0x888a / 0x888c in v6 and v5, each defined in
the tree's `shared/ram_variables.s`.  Their functions were renamed:

| old name            | new name          |
|---------------------|-------------------|
| `GetPlayState1`     | `Smf_GetPlayAsGm` |
| `GetPlayState2`     | `Smf_GetMidiOut`  |
| `SmfMedley_RawData` | `Smf_SetMidiOut`  |

- **The C** now uses the names (`extern unsigned char SmfPlayAsGm;`), so `medley.c` is no longer per-tree.
- **The scripts.**  `scripts/renaming/rename_smf_direct_play.sed` renames the functions.  The cells, and their five
  numeric operands per tree (`smf_operations.s`, `medley.s`), are renamed by `rename_smf_direct_play_cells_<tree>.sed`,
  one per tree because the addresses differ.  `ui/password_slot_routines.s`'s header, which called the cells
  "password values" and their getters `SysData_F92C0E` / `F92C13` "password getters", is corrected by
  `rename_smf_direct_play_password_header.sed`.
- **`corpus/firmware/tiny.c`** keeps the C name `SmfMedley_RawData`: it is the input of oracle run
  `2026-11-09-3-proxy-tiny`, a ledger row.  `check_bytes.py --alias SmfMedley_RawData=Smf_SetMidiOut` maps it.

## V4.23 builds the firmware C (owner, 2026-11-16): staging, probes m15 / m16

The owner paused the compiler-modelling research.  A function now counts as done when **Toshiba V4.23** reproduces
its ROM bytes at its file's option set; the reference model no longer matters.  `make` is being switched to compile
the firmware C with V4.23 in the oracle VM (lane_vmb).  Until that lands, the build still uses the model, which
refuses many V4.23-confirmed functions, so those wait in a staging directory:

- `<tree>/maincpu/cc900-staged/*.c`, in all five trees.  Each file holds only the new functions of one hand source
  (`semenu_routines.c`, `sequencer_engine.c`); a hand source with two option sets gets two C files
  (`note_voice_mapping_xr.c`, `cc900-options: -Xr`).  The build does not read the directory.
- `staged_v423.py --corpus DIR` prepares one oracle run for every tree's staged C.  `--check RUN DIR --record`
  compares each function with its tree's ROM (`asm_vs_rom.py --cfile`) and writes `staged_v423.tsv`.
- `probe_v423.py RUN [PATTERN]` summarises a probe run: per function, the forms and option sets that match.

Run `2026-11-16-28-p6-m15` checked the staged C.  The six functions of round 7's m8 / m10 and `LinkVoiceSlots_LoadReg`
matched in all five trees, but only by the operand widths of the old check (below), so they are checked again with
`__near` declarations.

**Loops (m15 a / b).**  `if (c) do { ... } while (c);` does **not** give the firmware's copied loop test: V4.23 folds
the guard into a jump to the bottom test, as for `while (c)`.  `TrimAndPadSmfFilename` still differs at +42.

**Shift by a variable count (m15 c).**  The shift instruction V4.23 writes depends on how the C is spelled:

| C spelling                                            | V4.23 writes |
|-------------------------------------------------------|--------------|
| `1 << a`, `1U << a`                                   | `sla A,BC`   |
| `(unsigned int)1 << (unsigned int)a`                  | `sll A,BC`   |
| `unsigned int m = 1; m <<= a;`                        | `sll A,BC`   |

The ROM's `FileIO_*` bit functions have `sll`, so they are within V4.23's reach after all.

**Operand widths (m16, run `2026-11-16-29-p6-m16`).**  V4.23 does not pick an absolute operand's width from the
address.  It writes every access to a named object the same way, and declares each object's attribute at the end of the
listing:
- a plain extern is `large`: 24-bit operands;
- `__near` is `medium`: 16-bit;
- `__tiny` is `small`: 8-bit.

Objects defined in the file go to the matching sections, `f_area`, `n_area` and `t_area`.  asm900 encodes exactly that
width: the `.rel` has the c2/d2/f2 forms, c1/d1/f1 and c0/f0.  It also uses the 16-bit `lda` (f1 #16 33) for the
address of a `__near` object.  The qualifier changes the code too: a plain array indexed by a char is read with
`(XBC+WA)`, a `__near` / `__tiny` one with `extz XWA` / `add XWA,XBC` / `(XWA)`.  A numeric absolute operand (a member
of a struct at a constant address, `(0xd0a8)`) is narrowed by its value: run 27's `.rel` has f1 for 0xd0a8.

So every RAM cell in firmware C is declared with the qualifier that gives the ROM's operand width: `__tiny` for 8-bit,
`__near` for 16-bit, plain for 24-bit.  The chord variables (0xcede..), which the ROM reaches with 24-bit operands
though they lie below 0x10000, are plain.  `asm_vs_rom.py` now takes each named operand's width from the listing's
attributes; `--by-address` gives the old narrowing.  The earlier V4.23 verdicts were made with that narrowing, and so
did not check widths.

## The firmware's -O files are `-O3 -Xr` (probe m18, run `2026-11-16-32-p6-m18-olevels`)

**The question.**  At `-O3 -XS -Xr`, V4.23 jumps to a loop's bottom test, whatever the C: m15 and m17 tried a guarded
do-while, goto, and a reversed guard.  At `-Xr` it copies the test to the entry, as the ROM does, but it then
allocates other registers than the ROM.

**The run.**  m18 compiled 195 probe functions at seven option sets.  These are the functions that match the ROM at
each set, with their bytes:

| options        | functions | bytes |
|----------------|-----------|-------|
| `-O3 -XS -Xr`  | 35        | 1,838 |
| `-Xr`          | 37        | 2,110 |
| `-O1 -Xr`      | 35        | 1,596 |
| `-O2 -Xr`      | 42        | 2,011 |
| `-O3 -Xr`      | 48        | 2,381 |
| `-O2 -XS -Xr`  | 32        | 1,609 |
| `-O1 -XS -Xr`  | 31        | 1,499 |

**The result.**  Every function that matches at `-O3 -XS -Xr` also matches at `-O3 -Xr`, except one:
`Sprintf_InsertCarry`, in `sprintf_core.s`, the file whose loops jump to their test.  Nine functions match only
without `-XS` (474 B), among them `TrimAndPadSmfFilename`: its plain `while` C gives the ROM's copied loop test with
the `-O` registers.  So the loop-entry copy (`KN_LOOP_INVERT`) is not a Technics rule but V4.23 at `-O3` without
`-XS`.  The coordinator approved a new option label, `O3Xr` = `-O3 -Xr`, as the firmware's `-O` set.
- `sprintf_core` stays `-O3 -XS -Xr`.
- The files without `-O` stay `-Xr`: seven functions match only there, such as `AudioInit_SelectPriority` (220 B).

**The FileIO shifts.**  `(unsigned int)1 << a` gives the ROM's bytes for `FileIO_BuildRecordPath_Done`,
`FileIO_FormatName_Loop` and `FileIO_BuildRecordPath_Return` at every set.  Casting the count as well adds an
`extz WA` that the ROM does not have.

**Round 1 of the helpers** was four background agents, each given a pool of leaf routines and the brief
(`~/compartilhado/tmp/cc900-tab/lane_p6/scan/BRIEF.md`, `ROUND2.md`).  Their probes are `corpus/firmware/p6_{A,B,C,D}_*.c`.
Run 31 checked them with the listing's own widths: 41 of 165 functions match, 2,632 B.  m18, with `-O3 -Xr`, raised
that to 56 functions and 3,222 B, counting the m-probes.

**Staging.**  `stage_probe.py` moves each matched function, with the declarations it uses, into
`v10/maincpu/cc900-staged/<hand source>.c`.  The file's option set decides the suffix:
- no suffix: `-O3 -Xr`;
- `_xr`: `-Xr`;
- `_xs`: `-O3 -XS -Xr`.

A function that matches at both `-O3 -Xr` and `-Xr` goes with the others of its hand source.  `port_staged.py` makes the
other trees' files from v10's.  It compares each function's v10 bytes with the tree's bytes at the tree's own label,
and takes the tree's value of every address the C names from the same bytes.  A function whose bytes differ anywhere
else is left out of that tree: `AudioInit_*` in v7 / v6 / v5, two accompaniment functions in v6 / v5, and
`PartCtrl_AppendToEventQueue`, which v7 / v6 / v5 lack.  `staged_v423.py` has the last word, per tree.

## The staged C built with V4.23 (2026-11-16)

The V4.23 build landed on main (70c34fd09, lane_vmb) and was merged into this branch.  `promote_staged.py` then moved
every tree's staged C into `<tree>/cc900/`.  Staged `-O3 -Xr` C was appended to the tree's existing file of that
hand source.  It went to a sibling file instead (`file_demo_proc_b.c`, `sequencer_engine_b.c`) when that file declares
one of its names differently, and to `_xr` / `_xs` / `_o3xr` files for other option sets.  Each function was then
spliced into its hand source (`cc900_splice.py --symbols --sizes staged_v423.tsv`), and the staging files were
removed in the same commit.

After the promotion, `<tree>/cc900/` defines 226 functions in v10, 226 in v9, 210 in v7, 199 in v6 and 199 in v5.  `make
gate` is byte-identical with V4.23 building all of them.

The splice learned two things on the way:
- **The cut is measured.**  A routine's hand lines may run past its compiled body.  `S2cTtl_InitOnTitleChange` has a dead
  second `ret`, and `AccPatch_ComplexDataBlock_Helper2` is a lone `ret` followed by unlabelled code.  `cc900_splice.py`
  measures the hand instructions with llvm-mc and cuts where their bytes reach the C body's size; the rest stays.
- **`--sizes`.**  The sizes come from staged_v423.tsv, and the functions are read from the C's text, so C that only
  V4.23 compiles can be spliced.

## Finding candidates

`leaf_candidates.py TREE [N]` lists routines of at most N instructions that end in `ret`, contain no call, jump or
branch, are not entered by falling through, and are the target of at least one `call` / `calr`.  On v10 with N = 4
(after milestone 1) it lists 281: 101 of one instruction (empty functions), 120 of two, 36 of three and 24 of four.
Some are data decoded as code (`SeMenu_*` rows such as `ld (xwa), (0x6c5)`) and must be skipped.

    python3 notes/cc900-phase6-2026-11-16/leaf_candidates.py v10/maincpu 4

## The build compiles with Toshiba V4.23 (2026-11-16, lane_vmb)

By default `make` and `make gate` now compile the firmware C with Toshiba cc900 V4.23, which runs in the oracle VM.
`make CC900_COMPILER=model ...` builds the same C with the reference model instead, without the VM.  Both give the
same bodies, and `make gate` passes with either (Makefile, "Firmware C code"; `scripts/build/cc900_firmware_c.py`).

- **Cache.**  `scripts/build/cc900_v423.py fill` keeps V4.23's listings in `build/cc900-v423/` (git-ignored: Toshiba
  output, never committed).  Each entry is keyed by the SHA-256 of what decides the listing:
  - the C text and its base name;
  - the `cc900-options:` flags (any flag string; a file that names none is compiled at `-O3 -Xr`, the firmware's own
    option set, run `2026-11-16-32-p6-m18`);
  - the `#include "..."` headers;
  - the V4.23 tree's id;
  - `oracle/job.sh`.

  Identical texts in several trees are one compile.
- **One VM job per make.**  A make compiles all uncached files in ONE VM job: `oracle/run_vm.sh` with
  `VM_SNAPSHOT=1` (`-snapshot`), in a slot of the VM pool (`oracle/vm_slot.sh`).  The build writes nothing into the oracle tree.  A fully
  cached make does not touch the VM, so it builds with no VM at all.
- **No fallback.**  When a file is not cached and the VM is unusable, the build stops.  It lists the files and
  what the VM lacks, then gives the flag `make CC900_COMPILER=model`.
- **The model's limits.**  The model is paused, and it does not cover everything V4.23 compiles; near/tiny arrays
  are one example.  When `CC900_COMPILER=model` meets such C, the step names the C file and the function or
  declaration, says the model does not support it and the default V4.23 build does, and writes no body.
- **Operand widths come from the declarations** (probe m16):
  - `__tiny` gives 8-bit operands, `__near` 16-bit, plain 24-bit;
  - V4.23 qualifies only the first declarator, so a qualified extern names one object;
  - V4.23's listing says each width (`extern small|medium|large`), and `model/to_llvm.py` takes it from there,
    checked against the C;
  - a symbol without a width stops the build;
  - `scripts/tools/cc900_near_qualifiers.py` gave the built C its qualifiers, from the widths the hand assembly
    uses.
- **C that V4.23 does not reproduce is not built.**  It would go to `<tree>/cc900/unbuilt/`, which `make` skips
  and `c_build_coverage.py` still checks.  None is there: TrimAndPadSmfFilename, which needed the model's
  KN_LOOP_INVERT at -O3 -XS -Xr, is reproduced by V4.23 at the firmware's own `-O3 -Xr` (run
  `2026-11-16-32-p6-m18`).

How make decides.  While it reads the Makefile, `cc900_v423.py index` rewrites `build/cc900-v423/index.tsv` (each
file's key, cached or missing) only when it changed, and the compiler choice goes to `rebuilt_ROMs/cc900-compiler.txt`
the same way.  The VM job is the rule for `build/cc900-v423/filled.stamp`, which depends on the index; the bodies
depend on that stamp and on the choice file.  So `make -q` (which `assert_byte_identical.py` asks) sees an
up-to-date tree as up to date.  A phony "force" prerequisite would not do that.

Timings (this machine, 2026-11-16, `make -j6`):

| run                                                                       | time           |
|---------------------------------------------------------------------------|----------------|
| `make gate`, V4.23, cold cache (whole worktree already built)             | 5 min 38 s     |
| its one VM job: 26 distinct texts of 75 files                             | 92 s           |
| VM job after the switch to `-O3 -Xr`: 25 distinct texts                   | 59 s           |
| VM job for one changed file                                               | 47 s           |
| `cc900_v423.py fill`, all 80 files cached                                 | 0.4 s          |
| `make gate`, V4.23, nothing changed (no fill, no body rebuilt)            | 2 min 35 s     |
| `make CC900_COMPILER=model gate`, after a V4.23 build (80 bodies rebuilt) | 3 min 39 s     |
| `make CC900_ORACLE=<missing> cc900-firmware-c`, cache complete            | 1.1 s (exit 0) |

Most of a warm gate is the gate's own checks, not the firmware C.  The first make in a fresh worktree builds
everything else too: 10 min 32 s, model build, before this change.

## Calls and tail calls: asm900 relaxes CAL / J (probe calrel, 2026-11-16, lane_vmb)

V4.23 writes every call `cal` and every tail call `j`.  These are asm900's optimising forms ("J" or "CAL" "used for
optimization", README/HIS96AE0.TXT; ASM900 `-O` is "No optimization").  The ROM's 9,477 `calr` and its jr / jrl
tail calls come from asm900, not from the compiler.  Probe calrel (`scripts/analysis/cc900/corpus/firmware/
p6_calrel*.c`, run `2026-11-16-42-p6-calrel`, assembled with `-l` and `-l -O` through job.sh's new `asmflags.txt`)
shows the rule:

| V4.23 writes                 | target                                                            | asm900 assembles (llvm-mc spelling) |
|------------------------------|-------------------------------------------------------------------|-------------------------------------|
| `cal`                        | a function of the same file (public or static), any distance seen | `calr` (1e d16)                     |
| `j` (tail call)              | the same, within reach of jr                                      | `jr` (68 d8)                        |
| `j` (tail call)              | the same, beyond jr (about 200 B in the probe)                    | `jrl` (78 d16)                      |
| `cal`                        | an extern, large (plain)                                          | `call` (1d a24)                     |
| `j`                          | an extern, large                                                  | `jp` (1b a24)                       |
| `cal`                        | an extern `__near` or `__tiny` function (listed `medium`)         | `call16` (1c a16)                   |
| `j`                          | an extern `__near` function                                       | `jp16` (1a a16)                     |
| `cal` / `j` with ASM900 `-O` | anything                                                          | `call` / `jp`, 24-bit               |

Static and public targets behave alike.  The >32 KB case is still open: p6_calrel_far.c's 49 KB pad stopped V4.23
(THC1-Fatal-150, "Too large string", one macro-expanded line); it needs a generated pad, one statement per line.

Our C files group functions by hand source, not by the firmware's original module.  lane_sub found functions of
one C file that call each other with an absolute call, so they came from different modules.  So file membership
says nothing.  A callee is module-local only when the comment `cc900-module: Label1 Label2 ...` (blank- or
comma-separated, any number of comments) names it: a tree label that shared the caller's original module and
section.  An inferred module map (lane_sub's modules.py, lane_p6's modules_main.py: a calr joins two routines into
one module, a near absolute call separates them) can propose the list.  For a named callee, `model/to_llvm.py`'s
MODULE gives `calr` / `jr`, and llvm-mc, which assembles each image as one unit, widens a jr to
jrl where it does not reach.  It does that only for labels that are not `.globl`, as the trees' are.  An entry is a
claim about the original build, and `make gate` checks it; its evidence is the hand assembly's calr / jr / jrl to
that label.  Both paths read it (`cc900_firmware_c.module_names`), so the model and V4.23 still give the same
bodies.

`python3 -I -B scripts/analysis/cc900/calrel_check.py FILE.asm FILE.lst` translates a whole V4.23 listing the
build's way and compares every function with ASM900's list file.  On the probe, all 15 functions of p6_calrel.c and
all 4 of p6_calrel_q.c MATCH.  `c_build_coverage.py` lays a function and its module-local targets out at their ROM
addresses, so its V4.23 and model columns check such calls too.

Beyond reach (probe calrel-far2, run `2026-11-16-61-p6-calrel-far2`): when a same-file target is more than 16 bits
away, asm900 writes `cal` as call #24 and `j` as jp #24, in both directions.  `cc900_firmware_c.far_fallback` does the
same for a module-local callee.  It uses the tree's symbols reference to measure the distance from the instruction's
own offset, and rewrites calr / jr / jrl as call / jp when the target is out of reach.

## Constant data: switch tables, FP constants, initialised arrays (`cc900-data:`, 2026-11-16, lane_vmb)

V4.23 puts a function's constant data in the `f_const` section, and the linker places that section apart from the
code.  The data can be:
- a switch's jump table (`dw L35-L50002`, read through `lda XIX,S50003` / `add XWA,S50000`);
- an FP constant (`fdatad`);
- an initialised local array.

In the ROM such an object sits in the module's constant area, at a label of its own: lane_sub's
`DSP_BytecodeInterpreter_CaseOffsets`, lane_hd's `HDAE5000_LyricBoxProc_CaseTable1`.  A C file names that place with
a comment `cc900-data: FUNCTION N = LABEL`, where N is the function's N-th f_const object in listing order, starting
at 1.  The build then:
- writes the object's code references as LABEL;
- writes the object itself, translated by `to_llvm.translate_data`, as `includes/generated/cc900/LABEL.s`.  The
  translation keeps `.balign`, and `.short` differences of the function's local labels (renumbered as the body's).
  An `fdata` / `fdatad` value becomes its IEEE bytes.

The tree includes that file at LABEL, in place of the hand data, the same way a function's body is included.  A
reference to f_const data with no `cc900-data:` place stops the build and names the comment to write.
`c_build_coverage.py` reads the same comment: it resolves the reference to LABEL's address and checks the
function's bytes.  The data is checked by `make gate` once it is included.

## The sub-CPU and HD-AE5000 trees build firmware C too (2026-11-16, lane_vmb)

The firmware-C rule now covers more trees than the main CPU's:
- the sub-CPU payloads v142 / v141 / v140 (`<v>/subcpu/cc900/*.c`);
- the four HD-AE5000 trees: `hdae5000`, `hdae5000_v2_01i`, `hdae5000_v1_15i`, `hdae5000_v1_10i` (`<tree>/cc900/*.c`).

They share the V4.23 cache, the fill and the coverage page (ROM offsets: the payload's split map, and
address - 0x280000).

An older HD-AE5000 tree assembles with `-I hdae5000` after its own directory.  Its C therefore reads the names of the
trees it includes (`cc900_firmware_c.INCLUDE_TREES`), and its image depends on their bodies.  Toshiba's runtime
routines go by the trees' names through `scripts/build/cc900_runtime_names.tsv`, whose tree patterns pick the most
specific row:
- `C9H_*` -> `Math_*` holds for `*/maincpu` only;
- lane_hd's `HDAE5000_*` names hold for `hdae5000*`.

End-to-end check, reverted afterwards:
- lane_hd's staged `HDAE5000_Lyrics_ClearBuffer` and `HDAE5000_Lyrics_CheckHeaderChunk` went into `hdae5000/cc900/`.
  The second calls SwapBytes16 / 32 relatively by `cc900-module:`, the same list `module_calls.py hdae5000` proposes,
  and MemCmp absolutely.
- They were spliced into hdae5000_ui_display.s and built through V4.23.  The generated body has `calr
  HDAE5000_SwapBytes32` / `16` and `call HDAE5000_MemCmp`.
- `rebuilt_ROMs/hd-ae5000_v2_06i.llvm.rom` was byte-identical to the ROM.

The same was done for two of lane_sub's staged dsp2_init.c functions in v142.  cc900_splice.py still refuses some
hand shapes (for example HDAE5000_SwapBytes32: "no run of hand instructions ... is 37 bytes long"), so the lanes'
promotion has to check each function.
