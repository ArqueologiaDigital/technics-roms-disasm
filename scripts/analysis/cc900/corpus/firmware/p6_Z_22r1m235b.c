/* helper Z, round 22r1, module 235 (sequencer/sequencer_engine.s), form b: SeqEvent_AccumulateQueue, as form a
   but `return 1` / `return 0` in the two arms of the test instead of a byte local. */

extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_258e;
extern unsigned int __near SEQ_BEAT_COUNT;

unsigned char SeqEvent_AccumulateQueue(void)
{
  PartCtrl_RefreshWordPeriodic();
  ram_258e++;
  if (ram_258e > SEQ_BEAT_COUNT)
    return 1;
  return 0;
}
