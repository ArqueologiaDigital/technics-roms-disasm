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
| `per_file.py` | each probe file's own verdict per option set and function (idiom probes: one spelling per file)     | `python3 -B notes/cc900-c-subcpu-2026-11-16/per_file.py RUN_DIR 'sub_A_ia*' --tsv OUT.tsv`                                                             |

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

- **Tone-generator writers around inline assembly** (`ToneGen_Write*`, about 30 routines; runs 58 and 62).  Each
  register write is followed by inline `nop`s and a `jr` to the next instruction.  Written with `__ASM(" nop")` /
  `__ASM(" jr $+2")`, V4.23 reproduces the four `*_Mute` writers, which need nothing after the first `nop`.  The
  others save XIZ (`push xiz; ld xiz,xbc`) and keep the record pointer there across the inline assembly; V4.23 does
  not treat `__ASM` as clobbering registers, and `register` did not move the pointer.  **Not a compiler difference**:
  V4.23's pseudo-registers reproduce it.  `ToneGen_WriteVoice_Direct` matches with `__IZ = d; ... = __IZ;` (run 62),
  and V4.23 then saves and restores IZ itself.  So the firmware's C held these values in `__IZ` / `__XIZ`.
- **8-bit narrowing** (helpers A and B, runs 47 / 58): V4.23 computes `unsigned char OP constant`, `uchar << 8` and
  `uchar * N` in 8 bits where the ROM extends first; a cast to `int` gives the ROM's code.  A C idiom, not a compiler
  difference.
- **Odd record strides** (287, 71, 39, 37, 5 bytes): V4.23 rounds a struct to an even size, so these records cannot be
  arrays of structs; the C indexes char arrays.  Whether the firmware's C had a packing option is open.
- **`DSP_Set_MixParam_45B2`** matches only at `-O3 -Xr` (run 47), the payload's only non-`-Xr` match so far.

## Promotion into the build (2026-11-16)

With the sub-CPU build support in main (adfc47c94), the staged C moved into `<tree>/subcpu/cc900/` for v142, v141 and
v140: 239 functions per tree are now built from C by `make` (Toshiba V4.23 in the VM).  v142's hand sources were
spliced with `scripts/tools/cc900_splice.py v142/subcpu FILE.c --symbols symbols/subcpu_symbols_reference.txt --sizes
SIZES` (SIZES: function<TAB>bytes, from `staged_v423.tsv`'s MATCH rows); v141 and v140 were regenerated from v142 by
their generators, which carry the `.include` lines over, and each tree builds from its own C (`port_staged.py`'s
cells).  The three payload ROMs are byte-identical and `make -j2 gate` passes.

Held back in `<tree>/subcpu/cc900-staged/`: 28 functions that V4.23 reproduces (checked by `sub_v423.py`) but the
build cannot yet build, each file with a note saying why (`hold_back.py` moves them):
- `*_kernel.c` (6): calls into the shared kernel (`wsa1/kernel/kernel.s`), whose labels the build's lookup does not
  see;
- `*_runtime.c` (12): calls to the C runtime (C9H_mulls / C9H_divls ...), which the build does not map to
  Math_Multiply32 / Long_SignedDiv;
- `*_callnames*.c` (5): calls a callee by its short `cc900-name`, which the build's call lookup does not apply;
- `*_inlinejr.c` (5): inline `jr $+2`, whose `$` the build's translation does not map to llvm-mc's `.`.
These are tool gaps reported to lane_vmb; the functions move into `cc900/` when they close.

**Second promotion (after main's name resolver, 9d5299ac5).**  The kernel, runtime and short-name files, and every
function verified since (rounds 6 .. 10, the -O3 -Xr serial loop), moved into `cc900/` (`promote.py` writes the sizes
and the list): **358 functions per tree** are built from C, the three payloads byte-identical.  Still held back, each
waiting for a translator form the build lacks (my checker, `sub_v423.py`, has them):
- `*_inlinejr.c` (5): `jr $+2` in inline assembly;
- `*_qizinc*.c` (5): `inc 0x1,QIZH` / `QIZL` (llvm-mc's `inc1b_erp`);
- `*_qwa.c` (2): `and QWA,n` (`and_erpw`);
- `*_modjump.c` (1): a conditional jump to a module-local function keeps the listing's `.` name.

**Third promotion (after main's splice-robust translator bundle, 642470321).**  Those 13 held-back functions and
every function verified in rounds 11 .. 16 moved into `cc900/` (`promote_run.sh LIST SIZES`: git mv in the three
trees, the v142 splice, the v141 / v140 generators): 39 more, **397 functions per tree** built from C, the three
payloads byte-identical, `make -j2 gate` PASS.  Held back in `cc900-staged/` (4 files): the six jump-table switches
(AudioChannel_Dispatch, Audio_Cmd_ToneEdit_Dispatch, TVF_Emit_Registers, TVF_Emit_Registers_Type2,
TVF_BuildEmit_Short_Dispatch, Pitch_Get_Patch_Octave_Shift), until the build splices their generated table at the
tree's label (lane_vmb's fix: the table began with V4.23's own `align 2`).

**Fourth promotion: the six switches (main's table fix, 508e4b243).**  `promote_v423_run.sh LIST WORK` moved their
four files into `cc900/`, built the v142 payload so the V4.23 cache held them, and spliced with
`cc900_splice.py ... --v423 build/cc900-v423 --work WORK`: each body and its offset table (six tables in
`v142/subcpu/subcpu_data_tables.s`, now `.include`s of generated data at their labels) checked against the built
image.  **403 functions per tree** built from C; `cc900-staged/` is empty; `make -j2 gate` PASS.

**Fifth promotion: round 17's 44 (run 2026-11-16-126, verified per tree in run 127).**  The same script, all 16
files through the `--v423` splice: 44 bodies and four more offset tables (DSP_Translator_CaseOffsets,
Algo_SubTable_Bit15Dispatch_CaseOffsets, Algo_SubTable_DispatchC_CaseOffsets, TVF_Build_CaseOffsets).
**447 functions per tree** built from C; `make -j2 gate` PASS.  Before it, Voice_ComputePitch_InlineData was
renamed Int_ClampSignedToRange_B (`scripts/renaming/rename_subcpu_clamp_b.sed`): 17 bytes of code, now built
from C too.

**Sixth promotion: round 18's 30 (run 2026-11-17-7, verified per tree in run 2026-11-17-9).**  12 files, 30
bodies and six more offset tables (DSP_BytecodeInterpreter_CaseOffsets, Algo_SubTable_DispatchB_CaseOffsets,
DSP_EFFPARAM_APPLY_JUMPTABLE, VOICE_DSPOUT_A_JUMPTABLE, VOICE_DSPOUT_B_JUMPTABLE,
VOICE_DSPOUT_SECOND_A_JUMPTABLE).  **477 functions per tree** built from C, DSP_BytecodeInterpreter_Init
(1,933 B) among them; `make -j2 gate` PASS.

**Seventh promotion: round 20's 18 (2026-11-18; runs 2026-11-18-3, -6 and -8 matched them, -8 and -9 verified them
per tree).**  9 files through `promote_v423_run.sh`: the six AudioChannel_Handler_Cmd*, Voice_InterpolateNoteCurve,
Voice_PortaLevel_Compute, Voice_ScanSlots_ReassignSources, the switches Voice_CtrlChange, Voice_SystemMsg and
DSP_AlgoType_Dispatch1/2/3 with their case tables, and the first floating-point functions, DSP_ParamInterp_FPComplex,
DSP_VolumeCurve_FP, DSP_ReverbCurve_FP and DSP_AlgoParam_Decode with their constants.  18 functions, 7,012 B per tree
(staged_v423.tsv's rows of runs -8 / -9); **495 functions per tree** built from C (`c_duplicates.py`).  The ready
list of the near-miss index offered nothing new (`ready_check.py`: all 137 lane_sub rows were already built).
`scripts/tools/cc900_splice.py` learned that a cc900-data object may start on its label's own line (`Label:\t.double
2.0`, how the FP constants are written) and that .float / .double are data.  `make -j2 gate` PASS.

**Eighth promotion: round 21's 17 (2026-11-18; matched in runs 2026-11-18-18, -19, -21 and -22, verified per tree in
-19, -21, -22 and -23).**  10 files: AudioChannel_AllVoices_Update_Variant3, Voice_ModWheel_Apply,
Voice_ToneTableApply_Filter / _Pitch, Voice_Allocate_1of4 / _Typed, Voice_Env_ApplyVelocity_Type0,
Voice_MakePartHandle, Partial_Build_Present_Word, RoutingFlag_Encode, VoiceAlloc_Apply_Algo_Group0 / 1,
VoiceBuf_TypeSelector_MatchEpilogue, CheckStatusBits_Zero, DSP_RingBuf_Read, RingBuf_ReadByte and the switch
DSP_SetCoeff_MasterConfig (706 B, with DSP_SETCOEFF_MASTERCONFIG_JUMPTABLE).  17 functions, 4,287 B per tree
(staged_v423.tsv's MATCH rows of runs -19 / -21 / -22 / -23); **512 functions per tree** built from C
(`c_duplicates.py`).

**Ninth promotion: run 2026-11-18-29-sub-r21f's 13 (verified per tree in run 2026-11-18-32-sub-r21g-staged).**  6 files:
Voice_Calc_LevelPair_Full / _PatchAtk, Voice_UpdateAllLFO, Audio_Tick_ServiceVoices_B, AudioMod_Apply_Porta_Curve (a
switch, with AudioMod_PortaCurve_CaseOffsets), VoiceModWheel_DataTable_02A061 (helper AG); Voice_Allocate_Type2,
Voice_NoteOn_Type3, Voice_OpSlot_WriteParams, Voice_Part_Assign (helper AH); DSP_SetCoeff_RouteComplex,
DSP_VoiceParamReadWrite, VoiceAlloc_Apply_Algo_Group2 (helper AI).  13 functions, 4,841 B per tree; **525 functions per
tree** built from C (`c_duplicates.py`); `make -j2 gate` PASS.  The work was wound down after it (owner, 2026-11-18):
HANDOFF-2026-11-18.md.

**Tenth promotion: round 23's 32 (2026-11-19; matched in runs 2026-11-19-5, -10 and -11, verified per tree in run
2026-11-19-12-sub-r23s-staged).**  7 files through `promote_v423_run.sh`: 27 tone-generator writers (ToneGen_WriteVoice_*,
ToneGen_WriteExtParam*, ToneGen_WriteNote2ch, ToneGen_WriteEnvSegments, ...) and Voice_AllVoices_PortamentoReset, all
open at +0 since round 3; DSP_VoiceState_Dispatch; AudioMod_Apply_Slot_Field29 / _2A and NoteOn_RoutePacket (helper AM);
Voice_Part_SetStateAndReinit (helper AL).  32 functions, 3,253 B per tree (staged_v423.tsv's MATCH rows of run -12);
**557 functions per tree** built from C (`c_duplicates.py`).

**Eleventh promotion: helper AO's 15 writers (2026-11-19; matched in run 2026-11-19-16-sub-r23o-tg-dsp, verified per
tree in run 2026-11-19-20-sub-r23t-staged).**  voice_noteon_and_tonegen_ao_23a.c: ToneGen_WriteExtParams_15 / _15_Alt /
_15_Banked / _56b / _TypeDispatch, ToneGen_WriteGlobalConfig, ToneGen_WriteLevelBurst, ToneGen_WriteLevelPair,
ToneGen_WriteReg0440_0480, ToneGen_WriteReg0840_Shadow2E, ToneGen_WriteVoice_TvfRegs_Dup and ToneGen_Write_Reg0180 /
0440 / 0480 / 04C0, all written with `__asm`.  15 functions, 1,787 B per tree; **572 functions per tree** built from C
(`c_duplicates.py`).

**Twelfth promotion: round 24's 2 (2026-11-19; matched in run 2026-11-19-24-sub-r24a, verified per tree in run
2026-11-19-25-sub-r24s-staged).**  DSP_VoiceCoeffRoute (365 B, open at +0 since round 3; helper AP rewrote it from the
built DSP_VoiceCoeffRoute2) and Voice_StereoLevel_Compute (625 B, its IZ int a plain local, no `__IZ`).  2 functions,
990 B per tree; **574 functions per tree** built from C (`c_duplicates.py`).

**Thirteenth promotion: EnvTranspose_UpdateLoop (2026-11-19; matched in run 2026-11-19-27-sub-r25a, verified per tree
in run 2026-11-19-28-sub-r25s-staged).**  439 B per tree (helper AL, round 25: the frame order rec, t, keys and the
key stores value first); **575 functions per tree** built from C (`c_duplicates.py`).

**Fourteenth promotion: Voice_Freq_WriteLeft and Voice_Pitch_Compute (2026-11-19; matched in run
2026-11-19-30-sub-r26a, verified per tree in run 2026-11-19-31-sub-r26s-staged).**  voice_params_and_tvf_ap_26a.c
(helper AP): 929 B per tree; **577 functions per tree** built from C (`c_duplicates.py`).

**Fifteenth promotion: WaveSel_Cache_VelSplitPtr (2026-11-19; matched in run 2026-11-19-35-sub-r27a, verified per
tree in run 2026-11-19-38-sub-r27s-staged).**  dsp_voice_params_al_27a.c (helper AL: path 1's +4 as a member of a
struct cast, idiom (z)): 154 B per tree; **578 functions per tree** built from C (`c_duplicates.py`).

**Held back: Audio_Process_DSP (1,409 B, helper AN's sub_AN_26c.c).**  It matches v142 and v141 (run -31) but not
v140 (DIFF at +24): in v1.40 the function is 1,491 bytes, because DSP_Cmd2B_SetParam is 82 bytes longer and the
reply / write paths differ (scripts/generators/create_v140_subcpu_source.py's edits 2-4).  v140's source is v141's
text with those byte-string edits applied, so splicing the function into v142 / v141 would remove the text the edits
rewrite.  It stays in `<tree>/subcpu/cc900-staged/audio_process_dsp_and_effects_an_26c.c` until v140 gets C of its
own for that span (a v1.40 form of the 0x2B SetParam case) and its generator learns to keep it.

### The firmware's inline assembly is `__asm` (round 23, runs 2026-11-19-7, -8 and -10)

V4.23 knows two spellings of inline assembly and treats them differently.  With `__ASM("...")` it assumes the block
touches no register, so a value live across it stays in the scratch register it arrived in (the writers' record pointer
in XBC).  With the lower-case `__asm("...")` it assumes the block clobbers the scratch registers, and such a value goes
to the callee-saved XIZ family (XIZ, IZ, QIZH, QIZL, IZH), pushed and popped, which is what the ROM does.
ToneGen_WriteVoice_Reg07 matched with plain C and `__asm` (sub_lane_23p2.c), and `gen_lane_23w.py` respelled the earlier
writer probes: 27 open functions matched at once.  So the record pointer never needed `__XIZ` / `__IZ` (bug candidate 12
is no longer in the way of these functions).  `#pragma asm` is unknown to V4.23 (THC1-Warning-618, sub_lane_23p1.c).
Functions built earlier with `__ASM` still match: their inline blocks have nothing live across them.

Other round-23 verdicts: memcpy(d, s, 11) is a library call in V4.23, not an inline copy, and `#pragma pack(1)` is
ignored silently, so the odd-size record copies (11, 71, 295 bytes) stay blocked (sub_lane_23a/b.c);
DSP_MixerCoeff_Compute keeps its +1 (a 16-byte frame where the ROM has 20) in ten more spellings (`gen_lane_23m.py`).
Helper AM found that `open_list.py` still lists DSP_WriteParameter and WaveSel_StageA2_FromVelZone, which are built
(dsp_control_routines_e_10a.c, dsp_voice_params_d_10a.c): their MATCH rows predate the ledger.

Round 21's lessons (helper-briefs/ROUND21.md has round 20's):
- A first `case` whose body only leaves the switch loses its compare; Variant3 needed a `case 4:` before
  `case 0x20: case 8: break;` to keep the 0x20 test (helper AD).
- A file that names `__IZ` next to a pointer kept in memory crashes V4.23 (bug candidate 12) and loses every
  function in it: run 2026-11-18-18 lost helper AI's three files whole; without ToneGen_ReadPitch_AndScale they
  compiled (sub_AI_21*.c).  Keep `__IZ` probes in files of their own.
- An argument that the ROM builds in XWA and copies to its register (`lda xwa,...; ld xbc,xwa`) is an address
  expression such as `&ram_45216[0]`, not the bare array (DSP_SetCoeff_MasterConfig, helper AF).
- A byte assigned to an int register variable through an int temporary gives the ROM's `extz wa; ld r,wa`; char
  sums need `(int)` operands or V4.23 adds in 8 bits (helpers AG, AI).

### Floating point at -Xr (runs 2026-11-17-7 and 2026-11-17-9)

- A register-convention function may not return float or double: V4.23 says `THC1-Error-373: Illegal function
  return type`, for prototypes too (sub_fp_18a/b/c.c were refused whole).  A `__cdecl` function may
  (sub_fp_19c.c), and the math library is declared `double __cdecl pow(double, double);` and so on.
- The ROM's callers show the same split: arithmetic and conversions pass ADDRESSES (XWA destination, XBC / XDE
  operands; nothing returns in a register), the math library takes its doubles on the stack with a pushed result
  pointer and the caller pops 20 bytes.  So the firmware's FP functions are plain C with float / double locals.
- Library names V4.23 calls (`fp_names.py` on sub_fp_19a/b.asm): `._fadd_f ._fsub_f ._fmul_f ._fdiv_f ._fneg_f
  ._fcmp_f ._fcmp_zf`, the same with `_d`, conversions `._fld_XY` (df, fd, lf, ulf, ld, fl, ful, dl, dul), and
  `_pow _sin _cos _tan _fabs`.  Their pairing with the tree's FP_* labels is NOT confirmed yet: each pair goes
  into `scripts/build/cc900_runtime_names.tsv` when a function that uses it matches.

### Floating point matched (round 20, 2026-11-18; runs 2026-11-18-2, -3 and -6)

DSP_ParamInterp_FPComplex (305 B, sub_fp_20d), DSP_VolumeCurve_FP (329 B) and DSP_ReverbCurve_FP (297 B,
sub_fp_20i) are the payload's first floating-point functions V4.23 reproduces.  They confirm twelve library names,
now rows of `scripts/build/cc900_runtime_names.tsv` (`*/subcpu`): `._fld_fl` FP_SP_CallWithBuf8, `._fld_lf`
FP_ftoi, `._fld_df` FP_ftod, `._fld_fd` FP_dtof, `._fadd_f` / `._fsub_f` / `._fmul_f` / `._fdiv_f` FP_fadd /
FP_fsub / FP_fmul / FP_fdiv, `._fmul_d` / `._fdiv_d` / `._fsub_d` FP_dmul / FP_ddiv / FP_dsub, `_pow` FP_pow.  The
other candidates stay in `sub_v423.py` only (helper AC's, from the routines' bodies); `._fld_ulf` has none.

What the spellings taught (every call address matched from the first run; only frames and folds differed):
- **Frame rule at -Xr.**  Locals whose address is taken (every float / double / long the library reads or writes
  by address) take slots top-down in declaration order, the first declared at the highest offset, just below the
  spilled parameters; compiler temporaries go below them; a register candidate spilled across calls gets the
  lowest slot.  So the ROM's offsets give the declaration order.
- **Constant folding.**  V4.23 folds `(float)x * 30.0F * 44100.0F` into one multiply by 1323000 (a cast int, a
  comma or a float cast around the first product do not stop it); a unary plus does: `+((float)x * 30.0F) *
  44100.0F` keeps the ROM's two multiplies.
- **Temporary order.**  In `y = 1.0 - pow(...)` V4.23 took the difference's temporary before the call's result
  slot; `y = (float)(1.0 - pow(...))` gives the ROM's order.
- Each floating constant is its own object, one `cc900-data:` line each, in the order the source uses them.

| script                | question it answers                                                                                                                                                                                                                                   | command                                                                                          |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| `hold_back.py`        | moves verified functions the build cannot build yet out of `cc900/` into `cc900-staged/`                                                                                                                                                              | `python3 -B notes/cc900-c-subcpu-2026-11-16/hold_back.py FILE.c TAG "WHY" FUNC...`               |
| `promote.py`          | the sizes (function<TAB>bytes) the splice needs, and the staged files to promote                                                                                                                                                                      | `python3 -B notes/cc900-c-subcpu-2026-11-16/promote.py sizes OUT.tsv` / `list --except inlinejr` |
| `c_duplicates.py`     | is any label defined by two C files of cc900/ and cc900-staged/                                                                                                                                                                                       | `python3 -B notes/cc900-c-subcpu-2026-11-16/c_duplicates.py`                                     |
| `bad_lines.py`        | which translated lines of a listing function llvm-mc refuses (by shape)                                                                                                                                                                               | `python3 -B notes/cc900-c-subcpu-2026-11-16/bad_lines.py LISTING.asm FUNCTION`                   |
| `first_diff.py`       | our bytes and the ROM's around one function's first difference, with the ROM's code                                                                                                                                                                   | `python3 -B notes/cc900-c-subcpu-2026-11-16/first_diff.py LISTING.asm FUNCTION --cfile C`        |
| `stage_probe.py`      | writes one probe's matched functions into a staged file (prototypes, names, module, data)                                                                                                                                                             | called by `stage_matches.py`                                                                     |
| `stage_matches.py`    | stages every MATCH of a verdict file into `v142/subcpu/cc900-staged/`                                                                                                                                                                                 | `python3 -B notes/cc900-c-subcpu-2026-11-16/stage_matches.py VERDICTS.tsv --own-file`            |
| `port_staged.py`      | ports v142's staged C to v141 / v140 (BSS cells shifted)                                                                                                                                                                                              | `python3 -B notes/cc900-c-subcpu-2026-11-16/port_staged.py`                                      |
| `promote_run.sh`      | promotion with sizes from `staged_v423.tsv` (git mv, splice v142, regenerate v141 / v140)                                                                                                                                                             | `bash notes/cc900-c-subcpu-2026-11-16/promote_run.sh LIST.txt SIZES.tsv`                         |
| `promote_v423_run.sh` | promotion with the build as size source; needed for jump tables (`--v423` splice)                                                                                                                                                                     | `bash notes/cc900-c-subcpu-2026-11-16/promote_v423_run.sh LIST.txt WORKDIR`                      |
| `unpromote_run.sh`    | moves files back from `cc900/` to `cc900-staged/` before a commit                                                                                                                                                                                     | `bash notes/cc900-c-subcpu-2026-11-16/unpromote_run.sh LIST.txt`                                 |
| `idiom_scan.py`       | which near misses stop at one of the probed idioms (bytes at the first difference)                                                                                                                                                                    | `python3 -B notes/cc900-c-subcpu-2026-11-16/idiom_scan.py --tsv OUT.tsv`                         |
| `gen_r14_probes.py`   | writes rounds 14-15's DSP_TuneOffset / DSP_AlgoDescriptor_Emit spelling probes                                                                                                                                                                        | `python3 -B notes/cc900-c-subcpu-2026-11-16/gen_r14_probes.py`                                   |
| `span_refs.py`        | can a switch spanning several labels be one C function (outside references to inner labels)                                                                                                                                                           | `python3 -B notes/cc900-c-subcpu-2026-11-16/span_refs.py FILE.s START END [TABLE]`               |
| `fp_names.py`         | which library routines V4.23 calls in each function of a listing (names only)                                                                                                                                                                         | `python3 -B notes/cc900-c-subcpu-2026-11-16/fp_names.py LISTING.asm ...`                         |
| `open_list.py`        | which attempted functions still do not match, with each one's best attempt (HANDOFF's count)                                                                                                                                                          | `python3 -B notes/cc900-c-subcpu-2026-11-16/open_list.py`                                        |
| `syntax_check.sh`     | gcc C89 pre-check of probe files before a VM run                                                                                                                                                                                                      | `bash notes/cc900-c-subcpu-2026-11-16/syntax_check.sh FILE.c ...`                                |
| `ready_check.py`      | which lane_sub rows of the near-miss index's ready.tsv are really new (built, staged, or NEW)                                                                                                                                                         | `python3 -B notes/cc900-c-subcpu-2026-11-16/ready_check.py [--new]`                              |
| `never_tried.py`      | which pool candidates no probe has compiled yet, largest first, with totals per pool                                                                                                                                                                  | `python3 -B notes/cc900-c-subcpu-2026-11-16/never_tried.py`                                      |
| `crash_check.py`      | which C files of an oracle run made V4.23 crash (page fault in the log, truncated listing)                                                                                                                                                            | `python3 -B notes/cc900-c-subcpu-2026-11-16/crash_check.py RUN_DIR ['sub_*']`                    |
| `helper-generators/`  | the helpers' generators of their probe forms, and their diff tools `idiff.py` / `ctx.py` (instruction-level diff of a listing function against the ROM); `fpconst.py` prints every FP constant of the payload with an exact C literal (`fpconst.txt`) | read each file's head; run from the repository root                                              |

## Where the helpers stopped (round 11, 2026-11-16)

Rounds 1-11 (runs 43 .. 94) gave 375 sub-CPU labels C that V4.23 reproduces; 358 per tree are built.  The pools
(`pools/pool_*_remaining.txt`) are close to exhausted for V4.23 as it stands.  What is left, by cause:
- **Jump-table switches** (`lda XIX,S5000x`): checkable now.  `sub_v423.py` reads `cc900-data: FUNCTION N = LABEL`
  like the build; e.g. DSP_BytecodeInterpreter_Init with `cc900-data: DSP_BytecodeInterpreter_Init 1 =
  DSP_BytecodeInterpreter_CaseOffsets` checks to its first difference (+25 / +112 in runs 62 / 65).  The other
  switches: Audio_Process_DSP, DSP_Cmd2B_AlgoSelect, DSP_AlgoType_Dispatch*, DSP_SetCoeff_MasterConfig,
  TVF_*_Dispatch, Pitch_Get_Patch_Octave_Shift, the ToneEdit / DSPUnit / EffParam cases.
- **Register allocation and evaluation order** that no C spelling has moved yet: a value stored to a stack local
  and still used from its register (V4.23 reloads it), a constant register argument loaded in argument order
  (V4.23 loads constants last), a char argument passed unextended (V4.23 extends it), the choice of IZ / XIX / XIY
  for a pointer.  lane_nmx's index classes these.
- **The V4.23 crash** (bug candidate 12): the tone-generator writers that keep a pointer in XIZ or on the stack next
  to a value in IZ need __XIZ, or __IZ beside a memory-held pointer.
- **Bank-register routines** (AudioMod_Apply_Slot_Field29 / 2A, VoiceParam_CustomTone_Apply_Catalog94,
  DSP_VoiceCoeffRoute2): byte locals in bank registers; not tried in C yet.
- **Hand assembly**: the kernel ring buffers (RingBuf_Init_*, FIFO_*, READ/SAVE_BYTE_TO_RING_BUFFER,
  RING_BUFFER_HAS_OVERRUN; helper E's -O3 guesses for the last three did not match), DSP_Init_Channels /
  DSP_Write_Channel, MemClear_DRAM_And_ExtRAM, core/03 and core/04 apart from the serial loop.
- **Floating point**: the DSP_*_FP curves and the coefficient routines call the double library; float returns are
  refused at -Xr, and the FP helpers' runtime names are not mapped.

## Idioms found by systematic probes (run 2026-11-16-99-sub-r13-idioms)

One probe file per C spelling of the same statement (`scripts/analysis/cc900/corpus/firmware/sub_A_ia*.c`,
`sub_E_ib*.c`, `sub_B_ic*.c`), each compiled at -Xr, -O1 -Xr and -O2 -Xr; per-file verdicts in
`verdicts/2026-11-16-99-idioms-{ia,ib,ic}.tsv` (`per_file.py`).

| class                                                                                     | probe functions                         | spelling that gives the ROM's form (-Xr)                                                                                                                                                     | evidence                                                                                                                   |
|-------------------------------------------------------------------------------------------|-----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------|
| (a) reload after store: ROM stores a value to a stack local and keeps using XWA           | TVF_Build_Short, Voice_PitchPack_RouteB | a second plain local that receives the value, the kept local assigned FROM it, the next uses through the second one: `u = P(v,23); t = u; f(v, u[17]);`                                      | ia06 MATCH both; the 17 other spellings (volatile, chains, comma, inner block, casts ...) stay at +15                      |
| (b) constant argument loaded in argument order (`ldw bc,0x79` before the other arguments) | DSP_TuneOffset, DSP_AlgoDescriptor_Emit | the constant through a local: `k = 0x79;` (initialised, assigned, const, register all work), with or without a prototype; casts, enum, #define, suffixes do not                              | ib06/07/08/14/19/20 move TuneOffset +8 -> +24 (its next, unrelated difference); the literal spellings stay at +8           |
| (c) char argument passed unextended (`ld c,(xbc+wa)`, no `extz`)                          | Voice_ToneTableRamp_Down                | the callee's parameter declared plain (signed) `char` (prototype `(int, char)` / `(int, signed char)`, or a K&R definition `char depth;`), the argument an unsigned char expression, no cast | ic03 / ic04 / ic10 MATCH; unsigned char / int parameters, no prototype, casts at the call (ic13), a char table stay at +18 |

Class (b) is only half found.  In DSP_TuneOffset the local puts `ld bc,0x79` where the ROM has it, and the next
difference (+24) is a separate one: the ROM copies the returned pointer XHL to XDE before reading through it.  In
DSP_AlgoDescriptor_Emit the same local gets a register of its own (DE, loaded early: +13 becomes +11); the ROM loads
the stack parameter into XHL first and then `ld bc,0x78`, so that function still needs another spelling.

-O1 -Xr / -O2 -Xr: no spelling matches at either (class (a) +15 / +17, class (b) +0, class (c) +1 for every
spelling).  So these are -Xr idioms of the firmware's own C, not an option difference.  The matches are staged
(`v142/subcpu/cc900-staged/*_ia06.c`, `*_ic03.c`).  Round 13's switch near misses (sub_C_13*, sub_D_13*) did not
match: TVF_Emit_Registers / _Type2 stay at +1 (frame size and XIZ vs IZ for the record pointer), DSP_VoiceCoeffRoute2
at +2 (L vs H for `sel & 15`).

### Applying them (run 2026-11-16-101-sub-r14)

`idiom_scan.py` sorts the unmatched functions' best attempts by the bytes at their first difference
(`idiom_scan.tsv`: 22 of 159 looked like one of the idioms).  Helpers G, H and J applied the idioms to them
(`sub_G_14*`, `sub_H_14*`, `sub_J_14*`).  Five new functions match:

- ToneGen_Process_Notes: the ROM loads a constant POINTER argument first; a register local `m = (unsigned char *)0x4a42;`
  set before the call does it (idiom (b) for a pointer).
- VoiceState_SwapSlot_Guarded: the byte compared unsigned in 8 bits (`(unsigned char)k`), not through `(int)k`.
- ScaleTune_Get_User_Offset / ScaleTune_Set_User_Offset: an index built as `extz wa; add wa,12` comes from an
  unsigned initializer `unsigned int i = n;` indexed with `(int)i + 12` (round 2's form plus the cast).
- DSP_TableWalk_SearchWithState: the parameter itself, not a copy of it, holds the pointer the result is stored through.

Only one of the eight "extend" functions was really idiom (c); the bytes-only guess is a pointer, not a verdict.

Two more rules:

- **Stack arguments are pushed left to right** (lane_hd's finding, confirmed here): in a non-`__cdecl` function the
  LAST parameter has the lowest stack offset (`__cdecl` library calls are the reverse).  Read the parameters' order
  from the ROM's `(xsp+N)` offsets.  DSP_AlgoDescriptor_Emit's search length is its last parameter (+14), not `type`
  (+18): our C passed the wrong parameter.
- **A result kept in a parameter's register**: DSP_TuneOffset's `ld xde,xhl` / `ld a,(xde)` after the call is
  not a new pointer local (sub_F_ra01..10 all keep XHL) but most probably the parameter `tbl` (in XDE) reused:
  `tbl = DSP_TableWalk_Search(tbl, ...); v = *tbl;` (round 15, sub_F_ra11..14).

### Round 15 (run 2026-11-16-106-sub-r15)

Four more functions match (939 B): DSP_TuneOffset, DSP_Config_Init, VoiceParam_CustomTone_Apply_Catalog80,
TVF_Calc_Cutoff_NoKeyFollow.

- **Result kept in a parameter's register: confirmed.**  `tbl = DSP_TableWalk_Search(tbl, k, mode, &st); v = *tbl;`
  gives the ROM's `ld xde,xhl` / `ld a,(xde)` (sub_F_ra11, ra12, ra14); with a literal constant instead of the local
  `k` (ra13) the function is back at +8, so idiom (b) is needed with it.
- **A copy through WA before a store** (`ld wa,iz` / `ld (port),wa`): a temporary, `r = i; port = r;`
  (DSP_Config_Init, sub_J_15b).
- **A value computed before the address it is stored to**: the value through a byte temporary first
  (Catalog80, sub_G_15a).
- DSP_AlgoDescriptor_Emit still stops at +11 / +13 with the corrected third argument (sub_F_rb15..18): open.

### Round 16 (run 2026-11-16-112-sub-r16) and the switches

Ten more functions match (2,150 B): Audio_Cmd_ToneEdit_Dispatch (656 B), TVF_Emit_Registers and
TVF_Emit_Registers_Type2, DSP_WriteLUTParamSet, DSP_ParamInterp_Div0xC6, DSP_MixSendConfig,
Voice_PortamentoTarget_ComputePitch, CustomTone_CopyToneRecord, Voice_Build_OutputLevel, Voice_InitVoiceState.
With AudioChannel_Dispatch, TVF_BuildEmit_Short_Dispatch and Pitch_Get_Patch_Octave_Shift (found by lane_nmx's
index; `sub_v423.py` left a function's own label address, the `lda xix, <case base>` of a switch, unrelocated until
then) six jump-table switches now match.  `stage_probe.py` carries the `cc900-data:` lines into the staged file.

Spellings that did it:

- **Doubling by add** (`add wa,wa`, not a shift): `w = table word; b = w + w;` on a local (`* 2` and `<< 1` shift).
- **A product copied before a sum** (`ld xwa,xhl`, then the other term built in XHL): the product through a
  conversion or its own local, `r = (v0 >> 8) + (long)(unsigned long)(q * t);`.
- **Idiom (e) on the second parameter**: DSP_MixSendConfig's pointer is its second parameter (XBC), reassigned
  from the call's result.
- **A two-way switch that compares the byte in place** is an `if (c != 1) { } else { }`.
- **A record pointer in XBC with a store through (XBC+8)**: a byte-pointer local without a struct cast,
  `*(unsigned long *)(s + 8) = ...`.
- **Switch bodies in the ROM's order** (case 13 between 11 and 12), a catalogue index in a local evaluated before
  the other arguments, and a plain `char` parameter for the unextended byte (idiom (c)) made
  Audio_Cmd_ToneEdit_Dispatch match.

Still open: DSP_AlgoDescriptor_Emit (+17), EGEnv_Compute_A / _B (+129), DSP_VoiceCoeffRoute2 (+2),
VoiceParam_Set_Tone_Option (+12).
