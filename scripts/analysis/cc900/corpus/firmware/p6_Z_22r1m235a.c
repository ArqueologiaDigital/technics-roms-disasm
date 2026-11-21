/* helper Z, round 22r1, module 235 (sequencer/sequencer_engine.s), form a: SeqEvent_AccumulateQueue.  Run r64's
   best (p6_W_21r2m235b@Xr) differed at +16: V4.23 wrote `scc ugt, wa; ld l, a`, the ROM the byte `scc ugt, l`
   straight into the result.  The built SeCtr2_OnPartColumn gets a byte scc from an if / else on a byte local;
   here the result byte local is set by an if / else and returned.  Form b: two returns. */

extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_258e;
extern unsigned int __near SEQ_BEAT_COUNT;

unsigned char SeqEvent_AccumulateQueue(void)
{
  unsigned char r;
  PartCtrl_RefreshWordPeriodic();
  ram_258e++;
  if (ram_258e > SEQ_BEAT_COUNT)
    r = 1;
  else
    r = 0;
  return r;
}
