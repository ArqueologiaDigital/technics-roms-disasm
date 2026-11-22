/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m235.c (2026-11-21-22-p6-r67)
   sha256 2ba66cb89bb685f16b1f40346b51ec97a51b68700efaac0e956c705ecf6b6c88 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
