/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m235a.c (2026-11-21-3-p6-r59)
   sha256 78c85326bb57cfad132bea5c0a806d9069c95c13361efad57236a04572e1749c (tar-sha256); compiled at -O3 -Xr */
extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_258e;
extern unsigned int __near SEQ_BEAT_COUNT;
unsigned char SeqEvent_AccumulateQueue(void)
{
  PartCtrl_RefreshWordPeriodic();
  ram_258e++;
  return ram_258e > SEQ_BEAT_COUNT;
}
