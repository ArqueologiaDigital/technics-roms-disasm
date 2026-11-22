/* helper U, round 21r1, module 235, form b: SeqEvent_AccumulateQueue's compare result through an unsigned char
   local (form a: a cast). */

extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_258e;
extern unsigned int __near SEQ_BEAT_COUNT;

unsigned char SeqEvent_AccumulateQueue(void)
{
  unsigned char r;
  PartCtrl_RefreshWordPeriodic();
  ram_258e++;
  r = ram_258e > SEQ_BEAT_COUNT;
  return r;
}
