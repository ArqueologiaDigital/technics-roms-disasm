/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_230a;
extern unsigned char __near CURRENT_TITLE;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near SEQ_SONG_RECORD[];
extern void Accomp_UpdateModeFlag(void);
extern void SeqAcc_InitAndDispatch(void);
extern void AccWrap_PlayModeDispatch(void);
extern void SeqBuffer_ClearAndInitIteration(void);
extern void SeqAcc_SetupRepeatCount(void);
extern void SeqAcc_HandlePlaybackTick(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern void SeqPlay_SaveStateAndCleanup(void);

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

void SeqAcc_UpdateAndDispatch(void)
{
  Accomp_UpdateModeFlag();
  SeqAcc_InitAndDispatch();
}

extern unsigned char __near ram_11f4;
extern unsigned char __near ram_1d84;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_RECORDING_TRACKS;
extern unsigned char __near PANEL_GM[];
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned char __near DEMO_ACTIVE_ENTRY;
extern unsigned char SeqError_MapTableA[];
extern unsigned char SeqError_MapTableF[];
extern void Part_CopyVoiceDataToAllChannels(void);
extern void SeqPlay_ActivateAllChannels(void);
extern void BitMapOut_PrepareAndRender(int);
extern void TempoRingBuf_Init(void);
extern void SoundCtrl_SaveAndSendCmd_EE(unsigned int);
extern void MIDI_SendSysExCmd(int);
extern void Audio_CheckSubsystemReady(void);
extern void SeqAcc_InitPlaybackState(void);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
extern void SeqBuf_SaveWritePos(void);
extern void AccNoteOn_ChannelDispatch(void);
extern void SeqBuf_Init(void);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern unsigned char PartCtrl_ReadByte(unsigned int, unsigned int);
extern unsigned int Voice_GetPresetFieldWord(unsigned int);
extern unsigned int Rhythm_ComputeNoteAllocation(unsigned int);
extern unsigned char Part_ReadSubBlock32(unsigned int, unsigned int);
extern void SeqError_MapToGlobal(unsigned char *);

void PartCtrl_WriteByte_Indexed(unsigned char v)
{
  PartCtrl_WriteByteToBuf(SEQ_DATA_BLOCK, (unsigned char)SEQ_DATA_OFFSET, v);
}

unsigned char Part_ReadVoiceByte(unsigned char a, unsigned char c)
{
  return Part_ReadSubBlock32(a, c);
}

unsigned int SeqBuf_AllocNextSlotAdjusted(unsigned int n)
{
  return Rhythm_ComputeNoteAllocation(n + 1) - 1;
}

void SeqBuf_FlushAndReinit_NoteEvents(void)
{
  SeqBuf_SaveWritePos();
  AccNoteOn_ChannelDispatch();
  SeqBuf_Init();
  ram_1d84 = 0;
}

void SeqError_MapViaTableA(void)
{
  SeqError_MapToGlobal(SeqError_MapTableA);
}

void SeqError_MapViaTableF(void)
{
  SeqError_MapToGlobal(SeqError_MapTableF);
}

void SeqInit_ClearPlaybackFlags(void)
{
  unsigned char f;
  f = SEQ_RTMCFG;
  f &= ~0x08;
  f &= ~0x02;
  f &= ~0x01;
  SEQ_RTMCFG = f;
  SeqAcc_InitPlaybackState();
}

unsigned int SeqModeTransit_GetPresetWord(void)
{
  return Voice_GetPresetFieldWord(DEMO_ACTIVE_ENTRY);
}

unsigned char SeqPart_ReadByte_Primary(void)
{
  return PartCtrl_ReadByte(SEQOP_PRIMARY_BLOCK, (unsigned char)SEQOP_PRIMARY_OFFSET);
}

void SeqPart_WriteByte_Secondary(unsigned char v)
{
  PartCtrl_WriteByteToBuf(SEQOP_SECONDARY_BLOCK, (unsigned char)SEQOP_SECONDARY_OFFSET, v);
}

void SeqPlay_DispatchAndResetAll(void)
{
  AccWrap_PlayModeDispatch();
  Part_CopyVoiceDataToAllChannels();
  SeqPlay_ActivateAllChannels();
  ram_11f4 = 0;
  BitMapOut_PrepareAndRender(0);
  SEQ_RTMCFG &= ~0x08;
  TempoRingBuf_Init();
  SEQ_CONTROL_FLAGS |= 0x10;
  SoundCtrl_SaveAndSendCmd_EE(0xf);
  MIDI_SendSysExCmd(8);
}

void SeqPlay_StopAndClearChannels(void)
{
  SEQ_REC_TRACKS = 0;
  Audio_CheckSubsystemReady();
  SEQ_RECORDING_TRACKS = 0;
  TempoRingBuf_Init();
  SoundCtrl_SaveAndSendCmd_EE(0xf);
  MIDI_SendSysExCmd(8);
}

unsigned char SeqStatus_CheckBit2(void)
{
  return PANEL_GM[3] & 0x04;
}

void SeqStatus_ResetAndSendCmd(void)
{
  PANEL_GM[3] &= ~0x01;
  AddswbWr(0x91, 3, 0, 1);
}

void SeqVoice_SetOrClearBitMask(unsigned char part, unsigned char on)
{
  int m;
  part--;
  m = 1 << part;
  if (on != 0)
    SEQ_REC_TRACKS |= m;
  else
    SEQ_REC_TRACKS &= ~m;
  Audio_CheckSubsystemReady();
}

extern unsigned long __near SEQ_SCREEN_OBJECT;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void ApDeliveryEvent(long, long, long);
extern void UI_InterruptTitleByIndex(unsigned int);
#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_GRAPH_DRAW 0x1c80004L
#define EVT_SET_PARAM 0x1e0003bL
#define TT_MESAGE 0xee

void AppEvent_SendAccompStatus(long v)
{
  ApDeliveryEvent(0x860007L, EVT_SET_PARAM, v);
}

void AppEvent_SendModeToggle(unsigned char on)
{
  ApDeliveryEvent(0x87000eL, EVT_SET_PARAM, (unsigned int)(on != 0));
}

void AppEvent_SendPlayStatus(long v)
{
  ApDeliveryEvent(0x850004L, EVT_SET_PARAM, v);
}

void NoteEditSy_ScrollCase2(long v)
{
  ApDeliveryEvent(0x880004L, EVT_SET_PARAM, v);
}

void NoteEditSy_SendScrollCmd0(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
}

void NoteEditSy_SendScrollCmd2(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
}

void NoteEditSy_SendScrollCmd3(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 3L);
}

void NoteEditSy_SendScrollCmd8(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 8L);
}

void NoteEditSy_SendWidgetCmd1(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 1L);
}

void SoundCtrl_SaveAndSendCmd_EE(unsigned int code)
{
  GLOBAL_ERROR_CODE = code;
  UI_InterruptTitleByIndex(TT_MESAGE);
}

extern unsigned char __near ram_2742;

void NoteEditSy_SendModeScrollCmd(void)
{
  if (ram_2742 & 1)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 9L);
  else
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 6L);
}

void NoteEditSy_SendModeWidgetCmd(void)
{
  if (ram_2742 & 1)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 13L);
  else
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 8L);
}

extern unsigned int SeqModeTransit_GetPresetWord(void);
extern unsigned int __near ram_2314;
extern unsigned char SeqError_MapTableE[];
extern unsigned char SeqError_MapTableB[];
extern unsigned char SeqError_MapTableC[];
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char ram_b0000[];
extern void NoteEditSy_SendModeScrollReset(void);
extern unsigned char __near PANEL_MIDI[];

void Chan_SetActiveBit(unsigned char a, unsigned char c)
{
  unsigned int m = 1 << (a - 1);
  if (c != 0)
    SEQ_TRACK_MASK |= m;
  else
    SEQ_TRACK_MASK &= ~m;
  Audio_CheckSubsystemReady();
}

void PartCtrl_SetClearBit7(unsigned int n, unsigned char c)
{
  unsigned char *p = ram_b0000 + ((unsigned long)(n - 1) << 8);
  if (c != 0)
    *p |= 0x80;
  else
    *p &= ~0x80;
}

unsigned char SeqData_ReadNextByte(void)
{
  return PartCtrl_ReadByte(SEQ_DATA_BLOCK, (unsigned char)SEQ_DATA_OFFSET);
}

void SeqError_MapViaTableB(void)
{
  SeqError_MapToGlobal(SeqError_MapTableB);
}

void SeqError_MapViaTableC(void)
{
  SeqError_MapToGlobal(SeqError_MapTableC);
}

void SeqError_MapViaTableE(void)
{
  SeqError_MapToGlobal(SeqError_MapTableE);
}

void SeqModeTransit_DemoPath(void)
{
  ram_2314 = SeqModeTransit_GetPresetWord();
}

unsigned char SeqPart_ReadByte_Secondary(void)
{
  return PartCtrl_ReadByte(SEQOP_SECONDARY_BLOCK, (unsigned char)SEQOP_SECONDARY_OFFSET);
}

void SeqPart_WriteByte_Primary(unsigned char v)
{
  PartCtrl_WriteByteToBuf(SEQOP_PRIMARY_BLOCK, (unsigned char)SEQOP_PRIMARY_OFFSET, v);
}

void SeqPlay_SetBarAndResetScroll(void)
{
  SEQ_START_MEASURE = 0x8002;
  NoteEditSy_SendModeScrollReset();
}

unsigned char SeqStatus_CheckMaskedBit(unsigned char a)
{
  return PANEL_MIDI[2] & a;
}

extern unsigned char __near ram_d32;
extern unsigned char __near TRACK_ASSIGN_EDIT_VALUE;
extern void SeqStep_ParseRhythm(void);

void SeqPart_EventLoopContinue(void)
{
  ram_d32 = TRACK_ASSIGN_EDIT_VALUE;
  SeqStep_ParseRhythm();
}
