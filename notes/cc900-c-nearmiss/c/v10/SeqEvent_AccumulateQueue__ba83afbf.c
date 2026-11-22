/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m235b.c (2026-11-21-7-p6-r62)
   sha256 ba83afbf9321b99e385543c980f31cfd0235d8fb9f43a2672399ae1244cf43ef (tar-sha256); compiled at -O3 -Xr */
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
