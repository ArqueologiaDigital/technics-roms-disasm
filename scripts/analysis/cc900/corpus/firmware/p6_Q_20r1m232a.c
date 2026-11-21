/* helper Q, round 20r1, module 232 (sequencer/bmdredit_routines.s, sequencer/sequencer_engine.s): drum-edit and
   accompaniment-start helpers. */
/* cc900-module: BmDrEdit_CheckChannelActive BmDrEdit_CountMeasuresAndValidate BmDrEdit_DelayAction_PlayClick BmDrEdit_IncrementDuration BmDrEdit_LoadAlternateState BmDrEdit_SelectActiveChannel BmDrEdit_SendMetronomeNoteOn BmDrEdit_BuildNoteOnEvent_WithVelocity Metronome_PlayClick NoteEditSy_UpdateAllWidgets SeqAcc_HandlePlaybackTick SeqAcc_InitAndDispatch SeqAcc_SetupRepeatCount */

extern unsigned char __near ram_295c;
extern unsigned char __near ram_295d;
extern unsigned char __near ram_295e;
extern unsigned int __near ram_2792;
extern unsigned char __near ram_2742;
extern unsigned char __near ram_2746[][3];
extern unsigned int __near ram_279e;
extern unsigned int __near ram_27a0;
extern unsigned char __near ram_2786;
extern unsigned char __near ram_2774;
extern unsigned int __near ram_279a;
extern unsigned char __near ram_230a;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near SEQ_SONG_RECORD[];

extern void NoteEditSy_SendModeScrollCmd(void);
extern void UI_ChangeTitleByIndex(unsigned int);
extern void BmDrEdit_LoadAlternateState(void);
extern void SeqData_SetErrorCode(unsigned int);
extern void BmDrEdit_CountMeasuresAndValidate(void);
extern void NoteEditSy_UpdateAllWidgets(void);
extern void BmDrEdit_DelayAction_PlayClick(void);
extern void BmDrEdit_IncrementDuration(void);
extern void Metronome_PlayClick(void);
extern void BmDrEdit_BuildNoteOnEvent_WithVelocity(void);
extern void BmDrEdit_SendMetronomeNoteOn(void);
extern void BmDrEdit_CheckChannelActive(void);
extern void BmDrEdit_SelectActiveChannel(void);
extern void Accomp_UpdateModeFlag(void);
extern void SeqAcc_InitAndDispatch(void);
extern void AccWrap_PlayModeDispatch(void);
extern void SeqBuffer_ClearAndInitIteration(void);
extern void SeqAcc_SetupRepeatCount(void);
extern void SeqAcc_HandlePlaybackTick(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern void SeqPlay_SaveStateAndCleanup(void);

#define TT_SQDRMCYCP 0x99

void BmDrEdit_ModeScrollDown(void)
{
  unsigned int v;
  if (ram_295c & 0x80) return;
  v = ram_2792;
  if (v == 0)
    ram_2792 = 48;
  else {
    if (v <= 1) return;
    ram_2792 = v - 1;
  }
  NoteEditSy_SendModeScrollCmd();
}

void SeqAcc_UpdateAndDispatch(void)
{
  Accomp_UpdateModeFlag();
  SeqAcc_InitAndDispatch();
}

void SeqAcc_InitAndDispatch(void)
{
  SEQ_START_MEASURE = 1;
  ram_230a |= 0x02;
  SEQ_RTMCFG &= ~0x08;
  SEQ_CONTROL_FLAGS |= 0x10;
  AccWrap_PlayModeDispatch();
  SeqBuffer_ClearAndInitIteration();
}

void SeqAcc_StopPlayback(void)
{
  if (CURRENT_TITLE != 136) {
    SEQ_SONG_RECORD[188] &= ~0x01;
    SeqAcc_SetupRepeatCount();
  }
  SeqAcc_HandlePlaybackTick();
  CtrlPanel_SetIndicatorBit(0x4c);
  SeqPlay_SaveStateAndCleanup();
}

void BmDrEdit_PostModeChange99(void)
{
  if (ram_2746[0][0] & 0x80) return;
  if (ram_295c & 0x80) return;
  UI_ChangeTitleByIndex(TT_SQDRMCYCP);
}

void BmDrEdit_CalcTrackPosition(void)
{
  if (!(ram_2742 & 0x01)) return;
  ram_2786 = ram_279e + ram_27a0;
}

void BmDrEdit_LoadAlternateAndValidate(void)
{
  BmDrEdit_LoadAlternateState();
  if (SEQ_ERROR_CODE != 0)
    SeqData_SetErrorCode(0xb8);
  BmDrEdit_CountMeasuresAndValidate();
}

void BmDrEdit_ClearAllSlots(void)
{
  unsigned char (*p)[3];
  for (p = ram_2746; p < ram_2746 + 8; p++)
    (*p)[0] = 0;
}

void NoteEdit_UpdateScrollAndDisplay(void)
{
  if (ram_279a < (unsigned int)(ram_2774 * 0x60))
    NoteEditSy_UpdateAllWidgets();
}

void BmDrEdit_DelayBExpired(void)
{
  if (ram_295e != 128) return;
  ram_295e = 0;
  BmDrEdit_DelayAction_PlayClick();
}

void BmDrEdit_DurationUp_Check(void)
{
  if (!(ram_295c & 0x80) || ram_295d == 3)
    BmDrEdit_IncrementDuration();
}

void BmDrEdit_SendMetronomeNoteOn_Alt(void)
{
  Metronome_PlayClick();
  BmDrEdit_BuildNoteOnEvent_WithVelocity();
  ram_295e = 134;
}

void BmDrEdit_PlayNoteAndSetDelay(void)
{
  BmDrEdit_SendMetronomeNoteOn();
  ram_295e = 134;
}

void BmDrEdit_CheckAndSelectChannel(void)
{
  BmDrEdit_CheckChannelActive();
  BmDrEdit_SelectActiveChannel();
}
