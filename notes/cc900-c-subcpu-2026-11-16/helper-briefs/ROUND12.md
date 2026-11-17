# Round 12 for lane_sub's helpers (read after BRIEF.md, ROUND3-11.md; the owner's rule in ROUND8.md stands)

Round 11 ran as oracle run 2026-11-16-94-sub-r11; 4 of 23 matched, staged.  358 functions per payload are now BUILT from C.

NEW FOCUS (coordinator, 2026-11-16):
1. JUMP-TABLE SWITCHES ARE CHECKABLE.  V4.23 compiles a dense switch to a table in its f_const section (`lda XIX,S5000x`,
   `dw Lx-L5000y`).  Place the table at the ROM's own table with a comment in the C file:
       /* cc900-data: FUNCTION N = LABEL */
   FUNCTION = the C function's name, N = the 1-based number of the f_const object in that function's listing (a
   function with one switch: 1), LABEL = the tree's label of the ROM's table (e.g. DSP_BytecodeInterpreter_CaseOffsets).
   The checker then checks the code with the table at that address (make gate checks the table's bytes later).  Without
   the comment the function reports "has no place in the tree".  Find the ROM table's label in the hand source next to
   the `jp t,(xix+wa)`-style dispatch (`command grep -n` the source).
   Example: DSP_BytecodeInterpreter_Init (helper E, sub_E_4a) with
       /* cc900-data: DSP_BytecodeInterpreter_Init 1 = DSP_BytecodeInterpreter_CaseOffsets */
   now checks to +25, where the only difference is the stack slot of the first local (V4.23 stored it at (XSP+0x0e),
   the ROM at (XSP+0x08)): a local declaration-order question (V4.23 gives the first-declared local the highest offset).
2. BANK-REGISTER ROUTINES: try them (byte locals the ROM keeps in QIZH / QIZL / IZL etc.; V4.23 allocates those itself).
   If V4.23 cannot produce one, say so and why; lane_sub records it as hand assembly.
3. REGISTER / ORDER NEAR MISSES: lane_nmx's index classes them; its README is copied at
   ~/compartilhado/tmp/cc900-tab/lane_sub/nmx_README.md ("What each class needs": register -> temporaries, argument
   order, types; order -> statement order; extend -> char/int types and casts; swap -> comparison written the other way;
   return-form -> one exit vs ret cc; staging -> value through a register vs straight to memory).  Its "Near misses"
   table lists our v142 functions with their classes: pick yours and apply the class's idiom.

Assignments:
- A: TVF_*_Dispatch, Pitch_Get_Patch_Octave_Shift (switches); your register / order near misses.
- B: AudioMod_Apply_Slot_Field29 / _Field2A (bank registers), AudioChannel_DispatchTable, the AudioChannel_Handler_Cmd*
  if they are switches; your near misses.
- C: Audio_Cmd_ToneEdit_Op00, Audio_Cmd_EffParam_TableJump_CaseBase, the DSPUnit / ToneEdit reply cases,
  VoiceParam_Set_Tone_Option* (switches); VoiceParam_CustomTone_Apply_Catalog94 (bank registers).
- D: DSP_AlgoType_Dispatch1/2/3, DSP_SetCoeff_MasterConfig, Audio_Process_DSP, DSP_Cmd2B_AlgoSelect,
  Algo_SubTable_DispatchB/C, CmdHandler2C_TableData (switches); DSP_VoiceCoeffRoute2 (bank registers).
- E: DSP_BytecodeInterpreter_Init (+25 above), DSP_PerParameterTranslator, DSP_Bytecode_Op00_Groups5_ParamMix,
  DSP_Op_0x61_LinearEval (switches).

Files sub_<TAG>_12a.c / _12b.c (/_12c.c).  Same rules; report as before.
