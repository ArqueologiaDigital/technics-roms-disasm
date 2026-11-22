/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   v5 only, by hand: SeqEvent_AccumulateQueue, from notes/cc900-c-nearmiss/c/v5/SeqEvent_AccumulateQueue__716f05f4.c
   (run 2026-11-21-22-p6-r67; v10 / v9 / v7 build it already).
   cc900-options: -O3 -Xr
*/
extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_2574;
extern unsigned int __near SEQ_BEAT_COUNT;
unsigned char SeqEvent_AccumulateQueue(void)
{
  unsigned char r;
  PartCtrl_RefreshWordPeriodic();
  ram_2574++;
  if (ram_2574 > SEQ_BEAT_COUNT)
    r = 1;
  else
    r = 0;
  return r;
}
