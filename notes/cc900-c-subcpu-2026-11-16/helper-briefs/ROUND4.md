# Round 4 for lane_sub's helpers (read after BRIEF.md and ROUND3.md)

Round 3 ran as oracle run 2026-11-16-58-sub-r3 (listings: ~/compartilhado/cc900-oracle/runs/2026-11-16-58-sub-r3/out/v423/Xr/sub/
sub_<TAG>_3{a,b,c}.asm; only Xr this time).  Your verdicts: ~/compartilhado/tmp/cc900-tab/lane_sub/r3_<TAG>.tsv.  Overall 65 of
165 functions matched, 4,769 B; all are staged.  The payload now has 220 staged functions.

New facts:
- Inline assembly without escapes assembles (leading space and real TAB both work; `$+2` too).  The four *_Mute writers match.
  The other tone-generator writers differ at +0: the ROM saves XIZ (`push xiz; ld xiz,xbc`) and keeps the record pointer
  there across the inline nops; V4.23 does not treat __ASM as clobbering registers, and `register` did not change that.
  Leave them unless you have a new idea (try at most two, in one form).
- Long callee names: a 31-character prefix shared by several labels cannot be resolved
  (Voice_Build_GateCommand_NoParti..., WaveSel_StageB_Build_Reg040_Foo...).  Declare such a callee under a short C
  name with `/* cc900-name: SHORT=FullLabel */`, as helper B did.
- V4.23's long multiply (C9H_mulls / C9H_mullu) now resolves to the payload's Math_Multiply32, so routines calling
  Math_Multiply32 are in scope (long `*`).  Int_SignedDiv_AltEntry and FP_* are still out.
- An idiom from the HD-AE5000 lane: the ROM's `lda xR,(sym+field)` after an index comes from writing the address as an
  integer, `*(T *)((unsigned long)&sym[field] + offset)`; every pointer spelling makes V4.23 fold the field into the index.
- V4.23 narrows `unsigned char OP constant` to 8 bits: cast to int where the ROM extends first (helper A's finding).
- Names: some cells now have names in the tree (MIDI_BacklogCount 0x27e7, RingBuf_OffsetLo 0x27e6, MIDI_RingBuffer
  0x2b0d, DSP2_RingBuffer 0x3b60, DSP_ConfigBuffer 0x448e, DSP_ConfigBuffer_Shadow 0x45ca, DSP_SlotMuteState 0x45bc,
  EFF_SlotActiveFlags 0x4930, DSP_ChipActiveFlags 0x493a, DSP_AlgoChangedFlag 0x493e); DSP_StateTable_Reset is now
  DSP_StateTable_Save and VoiceCC_DataTable_0280FE is ToneGen_WriteVoice_Reg21.  Use the names in new C.
- Avoid #define in probes when you can: staging expands macros, but plain C stages more cleanly.

Round 4: files sub_<TAG>_4a.c / _4b.c (/_4c.c).  Refine the closest misses (read the Xr listing beside the ROM), then
new functions from your pool, now including the Math_Multiply32 callers.  Same rules; report as before.
