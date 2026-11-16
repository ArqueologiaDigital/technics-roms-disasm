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
`DSP_StateTable_Save` (then `DSP_StateTable_Reset`) loads its constant address with the 5-byte `ld xix, 0x45ca`, which `-O` would write as
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

## Rules for C writers (runs 43 and 47)

- **`-Xr`, no `-O`.**  Only a match at `-Xr` counts; staged files say `cc900-options: -Xr`.
- **No escapes inside `__ASM("...")`.**  V4.23 copies a `\t` into its listing literally and asm900 then stops with a
  syntax error, so the whole file is lost (sub_B_2c, sub_C_2c).  Write the instruction with a leading space or a
  real TAB character.  `__WA = 0;` (V4.23's register pseudo-variable) is accepted and matched.
- **No float / double return type at `-Xr`.**  V4.23 refuses it (THC1-Error-373), and the file is lost (sub_2rt).
- **One `__near` / `__tiny` declaration per name**, as on the main CPU; a plain extern is a 24-bit operand.
- **cc900 keeps 31 characters of a name**: a longer label gets a short C name and `/* cc900-name: SHORT=Label */`.
- **Calls are checked as absolute `call`s.**  V4.23 writes `cal`; asm900 shortens a call to `calr` only inside one
  module, so a function whose ROM calls are `calr` waits for a module marking, and a staged C file must not join
  functions the ROM calls absolutely into one module (`modules.md`).
- The 287-byte part records and 71-byte voice records have word fields at odd offsets, which a cc900 struct cannot
  give (alignment 2): the C reads them through char arrays and casts.

## Names (2026-11-16)

The helpers' C made these purposes plain; `scripts/renaming/rename_subcpu_dsp_cells.sed` applies them to
`v142/subcpu` (v141 / v140 through their generators; `create_v140_subcpu_source.py`'s pinned span re-pinned), and
`rename_subcpu_dsp_cells_c.sed` to the staged C.  The cells' meanings are in `kn5000_subprogram_v142.s`'s header.

| old                                  | new                        | evidence                                                      |
|--------------------------------------|----------------------------|---------------------------------------------------------------|
| `VoiceCC_DataTable_0280FE` (routine) | `ToneGen_WriteVoice_Reg21` | writes TG register 0x21 (latch voice + 0x840); its own header |
| `DSP_StateTable_Reset` (routine)     | `DSP_StateTable_Save`      | `ldirw` copies 0x91 words from the argument to 0x45ca         |
| `(10215:16)`                         | `MIDI_BacklogCount`        | MIDI_Backlog_Publish / RingBuf_CheckOffset_ClearFlags         |
| `(10214:16)`                         | `RingBuf_OffsetLo`         | RingBuf_SetOffsetLo                                           |
| `(11021:16)`                         | `MIDI_RingBuffer`          | MIDI_Dispatch, RingBuf_ReadByte_MidiRing (mask 0xfff)         |
| `(15200:16)`                         | `DSP2_RingBuffer`          | DSP_RingBuf_Enqueue (mask 0x7ff)                              |
| `(17550:16)`, `0x448E`               | `DSP_ConfigBuffer`         | DSP_GetConfigBuffer, DSP_State_ApplyBuf                       |
| `0x45CA`                             | `DSP_ConfigBuffer_Shadow`  | DSP_StateTable_Save's destination                             |
| `(17852:16)`                         | `DSP_SlotMuteState`        | DSP_SlotMuteState_ReadAndClear                                |
| `(18736:16)`                         | `EFF_SlotActiveFlags`      | one word per effect slot                                      |
| `(18746:16)`                         | `DSP_ChipActiveFlags`      | one word per DSP chip                                         |
| `(18750:16)`                         | `DSP_AlgoChangedFlag`      | DSP_AlgoChange_CheckAndFlag                                   |
| `Payload_Bss_Start+0x649a`           | `ToneDB_RelBase`           | the name core/10's headers already used                       |
| `Payload_Bss_Start+0x649e`           | `ToneDB_RootPtr`           | the name core/10's headers already used                       |

The C names a cell below 0x10000 by its `.equ`; the ToneDB_* cells are expressions of Payload_Bss_Start, which the
C cannot resolve yet, so the C keeps `ram_45310` / `ram_45314` for them.  Proposed but not applied (not yet checked
here): `ram_4531c` the edit-buffer pointer, `ram_4a48` the tone-generator poll state, `ram_4a3a` / `ram_4a3e` the
pointers to the DSP state buffer being applied.

## Near misses and candidate compiler differences

- **Tone-generator writers around inline assembly** (`ToneGen_Write*`, about 30 routines; run 58).  Each register
  write is followed by inline `nop`s and a `jr` to the next instruction.  Written with `__ASM(" nop")` /
  `__ASM(" jr $+2")`, V4.23 reproduces the four `*_Mute` writers, which need nothing after the first `nop`.  The others
  differ at +0: the ROM saves XIZ (`push xiz; ld xiz,xbc`) and keeps the record pointer there across the inline
  assembly, as it does across a call; V4.23 keeps it in XBC, since it does not treat `__ASM` as clobbering registers.
  `register` on the pointer did not change that.  Candidate compiler difference: the firmware's compiler treated
  inline assembly as a call.  Still open: a dummy use or a register variable around the `__ASM`, a few forms per run.
- **8-bit narrowing** (helpers A and B, runs 47 / 58): V4.23 computes `unsigned char OP constant`, `uchar << 8` and
  `uchar * N` in 8 bits where the ROM extends first; a cast to `int` gives the ROM's code.  A C idiom, not a compiler
  difference.
- **Odd record strides** (287, 71, 39, 37, 5 bytes): V4.23 rounds a struct to an even size, so these records cannot be
  arrays of structs; the C indexes char arrays.  Whether the firmware's C had a packing option is open.
- **`DSP_Set_MixParam_45B2`** matches only at `-O3 -Xr` (run 47), the payload's only non-`-Xr` match so far.
