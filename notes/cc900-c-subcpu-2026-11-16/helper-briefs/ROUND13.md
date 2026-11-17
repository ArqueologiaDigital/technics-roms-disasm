# Round 13 for helpers C and D: the closest switch near misses (read after ROUND12.md; owner's rule stands)

Round 12 ran as oracle run 2026-11-16-97-sub-r12 (listings .../runs/2026-11-16-97-sub-r12/out/v423/Xr/sub/).  All
switches were checkable; none matched.  The closest, with what differs at the first difference (lane_sub's
notes/cc900-c-subcpu-2026-11-16/first_diff.py prints this: `python3 -B notes/cc900-c-subcpu-2026-11-16/first_diff.py
LISTING.asm FUNCTION --cfile C`):
- TVF_Emit_Registers / _Type2 (+1, sub_A_12c): the ROM's frame is `dec 2,xsp` and it saves and loads XIZ (a 32-bit
  pointer kept in XIZ); V4.23 made a 4-byte frame and used IZ.  So: one 2-byte local, and the record pointer as the
  long-lived pointer (V4.23 keeps the most-used pointer across calls in XIZ).
- AudioChannel_Dispatch (+2, sub_B_12b): the ROM loads the switch byte into L (`ld l,(xde+1); and l,0x3f; extz hl`);
  V4.23 into H.  A register choice: try the switch on an int local, an unsigned char local, the expression directly.
- DSP_VoiceCoeffRoute2 (+2, sub_D_12c): the ROM does `ld l,c; and l,0x0f`; V4.23 picked H.  The same register choice.
- VoiceParam_Set_Tone_Option (+8, sub_C_12c): the ROM moves C into A (`ld a,c; extz wa`); V4.23 used another register.
Assignments: C takes Set_Tone_Option, Audio_Cmd_ToneEdit_Dispatch (+11) and TVF_Emit_Registers / _Type2; D takes
AudioChannel_Dispatch and DSP_VoiceCoeffRoute2, and the Algo_SubTable / DSP_AlgoType dispatchers.  2-4 spellings each,
files sub_<TAG>_13a.c / _13b.c / _13c.c.  They run in the same VM job as A, B and E's idiom probes.
