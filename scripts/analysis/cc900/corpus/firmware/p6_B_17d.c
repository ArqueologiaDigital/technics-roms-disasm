/* Phase 6, helper B, round 17, form d: ONE function on purpose (lane_p6: a crash should cost one function only).
   v10 sequencer/sequencer_engine.s (-O3 -Xr).  VoiceChan_PostStatusEvent with integer-constant SCALAR arrays and
   cells (no struct, no member offset), the spelling matched C already uses for `((long *)0x9c4000)[i]`; the hand
   source writes these tables as bare decimal addresses.  Tests whether bug 11 also hits this spelling. */

extern unsigned char __near SEQ_PART_LOOP;

void VoiceChan_PostStatusEvent(void)
{
  ((unsigned char *)0x2546)[SEQ_PART_LOOP] = *(unsigned char *)0x2587;
  ((unsigned int *)0x2526)[SEQ_PART_LOOP] = *(unsigned int *)0x258e;
}
