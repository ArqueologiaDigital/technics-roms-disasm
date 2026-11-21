/* Functions of sequencer/seq_step_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqStep_InsertEventInner SeqStep_ParseRhythm SeqStep_PlaybackStateMachine SeqStep_PrepareReadBack SeqStep_RebuildPartChain SeqStep_SearchForward SeqStep_SkipToMeasure SeqStep_TimerDispatchA SeqStep_TimerDispatchB */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int SeqStep_SearchForward(unsigned int);
extern void SeqStep_RebuildPartChain(unsigned int);
extern void SeqStep_FindAndCompactEntry(void);
extern unsigned char SeqStep_PrepareReadBack(void);
extern void SeqStep_InsertEventInner(void);
extern void SeqStep_InsertEvent(void);
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
extern void SeqStep_MainTimerTick(void);
extern int SeqStep_SkipToMeasure(unsigned int);
extern int SeqStep_SkipInvertedA(unsigned char m);
extern unsigned char __near ram_22fc;
extern void (*SeqStep_TimerDispatchC_PtrTable[])(void);
extern void SeqStep_TimerDispatchC(void);
extern int SeqStep_SkipInvertedB(unsigned char a);
extern unsigned int __near SQSTEP_SCAN_OFFSET;
extern unsigned int __near SQSTEP_SCAN_BLOCK;
extern unsigned char PartCtrl_ReadByte(unsigned int, unsigned int);
extern unsigned char SeqStep_WalkReadByte(void);

void SeqStep_FindAndCompactEntry(void)
{
  SeqStep_RebuildPartChain(SeqStep_SearchForward(1));
}

void SeqStep_InsertEvent(void)
{
  if (SeqStep_PrepareReadBack() != 0x81)
    SeqStep_InsertEventInner();
}

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

int SeqStep_SkipInvertedA(unsigned char m)
{
  if (SeqStep_SkipToMeasure(m) != 0) return -1;
  return 0;
}

void SeqStep_TimerDispatchC(void)
{
  (*SeqStep_TimerDispatchC_PtrTable[ram_22fc])();
}

int SeqStep_SkipInvertedB(unsigned char a)
{
  if (SeqStep_SkipToMeasure(a) != 0) return -1;
  return 0;
}

unsigned char SeqStep_WalkReadByte(void)
{
  return PartCtrl_ReadByte(SQSTEP_SCAN_BLOCK, (unsigned char)SQSTEP_SCAN_OFFSET);
}
