# cc900 C for the sub-CPU payload (lane_sub, 2026-11-16)

Goal (owner, 2026-11-16): write C for the sub-CPU payload `v142/subcpu` (v141 / v140 are generated from it) that
Toshiba cc900 V4.23 compiles to exactly the ROM's bytes.  The method is lane_p6's
(`notes/cc900-phase6-2026-11-16/README.md`); this directory holds the sub-CPU's survey, probes' verdicts and the
staging ledger.  The HD-AE5000 went to another lane on 2026-11-16; nothing about it is here.

## Scripts

| script        | question it answers                                                                                 | command (repository root)                                                                                                                              |
|---------------|-----------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| `survey.py`   | which routines look compiled from C, their size, calls and marks; leaf / absolute-call candidates   | `python3 -B notes/cc900-c-subcpu-2026-11-16/survey.py --md notes/cc900-c-subcpu-2026-11-16/survey.md --tsv notes/cc900-c-subcpu-2026-11-16/survey.tsv` |
| `pools.py`    | the candidates not yet tried, split by hand source into the helpers' pools (`pools/pool_<TAG>.txt`) | `python3 -B notes/cc900-c-subcpu-2026-11-16/pools.py`                                                                                                  |
| `modules.py`  | where the original C modules lie: `calr` joins routines, a near absolute `call` separates them      | `python3 -B notes/cc900-c-subcpu-2026-11-16/modules.py --md notes/cc900-c-subcpu-2026-11-16/modules.md`                                                |
| `sub_v423.py` | which functions V4.23 reproduces from which C and option set (`corpus`, `check`, `record`, `one`)   | see its docstring                                                                                                                                      |

`sub_v423.py` compares a V4.23 listing with the payload ROM through `model/to_llvm.py` and llvm-mc, as
`scripts/analysis/cc900/asm_vs_rom.py` does for the main CPU, with the payload's address map: ROM offset 0 is
address 0x400 (256 bytes), offset 0x100 is address 0xf000 (the Makefile's `kn5000_subprogram_v142.llvm.rom` rule).

## The survey (`survey.md`, `survey.tsv`)

742 routines (call targets after a flow end), 123,145 B.  103,236 B carry the marks of compiled C (extz / exts /
muls / stack frames / retd) and no hand mark; 7,720 B carry hand marks (ei / di / reti / ldc / swi / `.byte`):
the kernel, the inter-CPU link, the serial handlers and Toshiba's double library (`subcpu_fp_math.s`).  So the
payload is mostly C: `core/05` .. `core/14` are almost wholly compiled code.

The bank-register forms (`ldto_berp a, 0xfb` = `ld A,QIZH` and the like) are V4.23's own: it allocates the byte
parts of the index registers, so they do not mark hand assembly.

## Option set: `-Xr` (run `2026-11-16-43-sub-r1`)

`scripts/analysis/cc900/corpus/firmware/sub_1a.c` / `sub_1b.c`: 31 small leaf functions, two spellings, at
`-O3 -Xr`, `-Xr` and `-O3 -XS -Xr`.  24 match the ROM (343 B).  Every one matches at `-Xr`; ten match only there
(the clamps, `Unsigned_Max_Select`, `BitTest_Bit0_L`, `DList_Unlink_SelfLink`, `DSP_VelocityToVolume`,
`BlockCopy_Words_BC_to_HL`, whose loop test is copied to the entry as `-Xr` does); none matches only with `-O`.
`DSP_StateTable_Reset` loads its constant address with the 5-byte `ld xix, 0x45ca`, which `-O` would write as
`lda`.  So the payload was compiled **without `-O`, with `-Xr`**; staged C states `cc900-options: -Xr`.
Verdicts: `verdicts/2026-11-16-43-sub-r1.tsv`.

## Modules (`modules.py`, `modules.md`)

V4.23 writes every call as `cal`; asm900 shortens it to `calr` only for a target in the same module.  So a `calr`
joins two routines into one original C file, and an absolute `call` to a routine within `calr` reach separates
them.  The payload has 905 `calr` pairs and 1,756 such near absolute calls.  The fewest boundaries that satisfy both
make 27 modules (`modules.md`: address ranges and first routines); a real file may be smaller, but no file boundary
lies inside a `calr`-joined span.  Nine near calls contradict the rule, all inside the kernel's ring-buffer
routines of `core/03_task_scheduler_kernel.s` (hand assembly).  This is the input a `cc900-module:` marking
needs: functions that call each other with `calr` must be compiled in one C file.
