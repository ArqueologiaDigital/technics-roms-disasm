/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m253a.c (2026-11-21-2-p6-r58)
   sha256 71c2f2e3df9491be128296d14d62e688a61daeb07f4390f1a9384bcee40f36de (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near CURRENT_TITLE;
extern void DrumKit_SendProgramChange(void);
void RhythmConfig_InlineCode2_Data(void)
{
  if (CURRENT_TITLE != 180)
    DrumKit_SendProgramChange();
}
