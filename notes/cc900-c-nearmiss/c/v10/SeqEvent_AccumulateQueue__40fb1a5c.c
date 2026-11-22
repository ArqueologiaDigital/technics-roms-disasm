/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m235a.c (2026-11-21-7-p6-r62)
   sha256 40fb1a5c28803783960a8696c3d69b0dfd937b2d4b2734cfa739723f5f3540bd (tar-sha256); compiled at -O3 -Xr */
extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_258e;
extern unsigned int __near SEQ_BEAT_COUNT;
unsigned char SeqEvent_AccumulateQueue(void)
{
  PartCtrl_RefreshWordPeriodic();
  ram_258e++;
  return (unsigned char)(ram_258e > SEQ_BEAT_COUNT);
}
