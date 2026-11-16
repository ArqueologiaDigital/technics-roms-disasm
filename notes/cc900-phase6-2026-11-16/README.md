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

## Finding candidates

`leaf_candidates.py TREE [N]` lists routines of at most N instructions that end in `ret`, contain no call, jump or
branch, are not entered by falling through, and are the target of at least one `call` / `calr`.  On v10 with N = 4
(after milestone 1) it lists 281: 101 of one instruction (empty functions), 120 of two, 36 of three and 24 of four.
Some are data decoded as code (`SeMenu_*` rows such as `ld (xwa), (0x6c5)`) and must be skipped.

    python3 notes/cc900-phase6-2026-11-16/leaf_candidates.py v10/maincpu 4
