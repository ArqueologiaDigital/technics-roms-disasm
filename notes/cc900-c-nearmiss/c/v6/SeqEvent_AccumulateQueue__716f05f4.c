/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m235.c (2026-11-21-22-p6-r67)
   sha256 716f05f49693b4b5762cd8565940382e316674942e4312ab26be9084a1ef2904 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void PartCtrl_RefreshWordPeriodic(void);
extern unsigned int __near ram_2574;
extern unsigned int __near SEQ_BEAT_COUNT;
unsigned char SeqEvent_AccumulateQueue(void)
{
  unsigned char r;
  PartCtrl_RefreshWordPeriodic();
  ram_2574++;
  if (ram_2574 > SEQ_BEAT_COUNT)
    r = 1;
  else
    r = 0;
  return r;
}
