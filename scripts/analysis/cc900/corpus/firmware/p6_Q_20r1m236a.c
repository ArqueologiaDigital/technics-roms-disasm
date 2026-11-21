/* helper Q, round 20r1, module 236 (sequencer/seq_step_routines.s): step-mode timer dispatch and small wrappers. */
/* cc900-module: SeqStep_InsertEventInner SeqStep_PlaybackStateMachine SeqStep_PrepareReadBack SeqStep_RebuildPartChain SeqStep_SearchForward SeqStep_SkipToMeasure SeqStep_TimerDispatchA SeqStep_TimerDispatchB */

extern unsigned char __near ram_22fc;
extern void (*SeqStep_TimerDispatch_ProcTables[])(void);
extern void (*SeqStep_TimerDispatchC_PtrTable[])(void);

extern void SeqStep_TimerDispatchA(void);
extern void SeqStep_TimerDispatchB(void);
extern void SeqStep_PlaybackStateMachine(void);
extern void SeqPlay_SyncPlaybackPosition(void);
extern void Seq_HandleModeTransition(void);
extern void SeqNotify_CheckAndClearStart(void);
extern void SeqPlay_SetupRhythmMode(void);
extern void PlaybackMode_DispatchByType(void);
extern void SeqTimer_CheckPlaybackCountdown(void);
extern void BmDrEdit_TempoAnimTimer(void);
extern int SeqStep_SkipToMeasure(unsigned int);
extern unsigned char SeqStep_PrepareReadBack(void);
extern void SeqStep_InsertEventInner(void);
extern unsigned int SeqStep_SearchForward(unsigned int);
extern void SeqStep_RebuildPartChain(unsigned int);

void SeqStep_MainTimerTick(void)
{
  SeqStep_TimerDispatchA();
  SeqPlay_SyncPlaybackPosition();
  SeqStep_TimerDispatchB();
  Seq_HandleModeTransition();
  SeqNotify_CheckAndClearStart();
  SeqStep_PlaybackStateMachine();
  SeqPlay_SetupRhythmMode();
  PlaybackMode_DispatchByType();
  SeqTimer_CheckPlaybackCountdown();
  BmDrEdit_TempoAnimTimer();
}

void SeqStep_TimerDispatchA(void)
{
  (*SeqStep_TimerDispatch_ProcTables[ram_22fc])();
}

void SeqStep_TimerDispatchC(void)
{
  (*SeqStep_TimerDispatchC_PtrTable[ram_22fc])();
}

int SeqStep_SkipInvertedA(unsigned char m)
{
  if (SeqStep_SkipToMeasure(m) != 0) return -1;
  return 0;
}

void SeqStep_InsertEvent(void)
{
  if (SeqStep_PrepareReadBack() != 0x81)
    SeqStep_InsertEventInner();
}

void SeqStep_FindAndCompactEntry(void)
{
  SeqStep_RebuildPartChain(SeqStep_SearchForward(1));
}
