/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_W_21r2m235a.c (2026-11-21-9-p6-r64)
   sha256 456f3cea92be1b59b471984e7ed8489093ff6252d870c04d4700ac1733b2107d (tar-sha256); compiled at -O3 -Xr */
extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_258e;
extern unsigned int __near SEQ_BEAT_COUNT;
unsigned char SeqEvent_AccumulateQueue(void)
{
  PartCtrl_RefreshWordPeriodic();
  ram_258e++;
  return ram_258e > SEQ_BEAT_COUNT ? (unsigned char)1 : (unsigned char)0;
}
