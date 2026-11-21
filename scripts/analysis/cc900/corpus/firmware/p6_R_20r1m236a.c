/* Helper R, round 1 of 2026-11-20: module 236 (sequencer/sequencer_engine.s, sequencer/seq_step_routines.s).  Form a. */
/* cc900-module: SeqStep_ParseRhythm SeqStep_SkipToMeasure */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_d32;
extern unsigned char __near TRACK_ASSIGN_EDIT_VALUE;
extern void SeqStep_ParseRhythm(void);
extern int SeqStep_SkipToMeasure(unsigned int);
extern unsigned char __near ram_22fc;
extern void (*SeqStep_TimerDispatchB_PtrTable[])(void);
extern unsigned int __near SQSTEP_SCAN_OFFSET;
extern unsigned int __near SQSTEP_SCAN_BLOCK;
extern unsigned char PartCtrl_ReadByte(unsigned int, unsigned int);

void SeqPart_EventLoopContinue(void)
{
  ram_d32 = TRACK_ASSIGN_EDIT_VALUE;
  SeqStep_ParseRhythm();
}

int SeqStep_SkipInvertedB(unsigned char a)
{
  if (SeqStep_SkipToMeasure(a) != 0) return -1;
  return 0;
}

void SeqStep_TimerDispatchB(void)
{
  int i = ram_22fc;
  SeqStep_TimerDispatchB_PtrTable[i]();
}

unsigned char SeqStep_WalkReadByte(void)
{
  return PartCtrl_ReadByte(SQSTEP_SCAN_BLOCK, (unsigned char)SQSTEP_SCAN_OFFSET);
}
