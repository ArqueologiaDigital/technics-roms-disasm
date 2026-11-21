/* helper W, round 21r2, module 235, form b: SeqEvent_AccumulateQueue with the counter read into a word local before
   the compare and the byte result through a byte local assigned from the comparison (form a: a conditional
   expression). */

extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_258e;
extern unsigned int __near SEQ_BEAT_COUNT;

unsigned char SeqEvent_AccumulateQueue(void)
{
  unsigned int n;
  unsigned char r;
  PartCtrl_RefreshWordPeriodic();
  ram_258e++;
  n = ram_258e;
  r = n > SEQ_BEAT_COUNT;
  return r;
}
