/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_W_21r2m235b.c (2026-11-21-9-p6-r64)
   sha256 01d28e634786b0d48f72a3486c4254207bc734d76cd9bf7bff6fbc8ea61c5f81 (tar-sha256); compiled at -O3 -Xr */
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
