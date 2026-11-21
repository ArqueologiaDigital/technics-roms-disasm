/* helper W, round 21r2, module 235 (sequencer/sequencer_engine.s), form a: SeqEvent_AccumulateQueue.  Run r62's
   best (p6_U_21r1m235b@Xr) differed only at the end: V4.23 wrote `scc ugt, wa; ld l, a`, the ROM the 8-bit
   `scc ugt, l` straight into the result register.  Here the flag is a conditional expression of byte constants. */

extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_258e;
extern unsigned int __near SEQ_BEAT_COUNT;

unsigned char SeqEvent_AccumulateQueue(void)
{
  PartCtrl_RefreshWordPeriodic();
  ram_258e++;
  return ram_258e > SEQ_BEAT_COUNT ? (unsigned char)1 : (unsigned char)0;
}
