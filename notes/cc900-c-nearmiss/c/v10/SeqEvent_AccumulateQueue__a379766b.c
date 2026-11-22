/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Z_22r1m235b.c (2026-11-21-21-p6-r66)
   sha256 a379766b7d3f2e152eb5d4cd7dedfce8f1a88ec2f7644f0e28fa1b3c65f184d5 (tar-sha256); compiled at -Xr */
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
