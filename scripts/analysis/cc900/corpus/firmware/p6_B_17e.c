/* Phase 6, helper B, round 17, form e: ONE function on purpose (lane_p6: a crash should cost one function only).
   v10 sequencer/sequencer_engine.s (-O3 -Xr).  SeqScan_StoreResultB with integer-constant scalar arrays, the
   source cells as __near externs (form d has them as constant addresses too). */

extern unsigned char __near SEQ_PART_LOOP;
extern unsigned char __near ram_2587;
extern unsigned int __near ram_258e;

void SeqScan_StoreResultB(void)
{
  ((unsigned char *)0x2576)[SEQ_PART_LOOP] = ram_2587;
  ((unsigned int *)0x2556)[SEQ_PART_LOOP] = ram_258e;
}
