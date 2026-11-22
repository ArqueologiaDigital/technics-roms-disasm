/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_22r1m235a.c (2026-11-21-21-p6-r66)
   sha256 cb96aa6c69a8a16f257c9994e01bd7257dbcdbdcbbc2221cc1b7574de978f16f (tar-sha256); compiled at -Xr */
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
