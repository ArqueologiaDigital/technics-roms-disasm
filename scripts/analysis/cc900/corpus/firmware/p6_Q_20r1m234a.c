/* helper Q, round 20r1, module 234 (sequencer/sequencer_engine.s): small playback / part-buffer wrappers. */
/* cc900-module: Part_CopyVoiceDataToAllChannels Part_ReadByteDirect Part_ReadSubBlock32 Part_WriteWord PartCtrl_ReadByte PartCtrl_WriteByteToBuf Rhythm_ComputeNoteAllocation SeqError_MapToGlobal */

extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near ram_11f4;
extern unsigned char __near ram_1d84;
extern unsigned char __near ram_28a5;
extern unsigned int __near ram_2875;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int SEQ_TRACK_MASK_COPY;
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

extern void AccWrap_PlayModeDispatch(void);
extern void Part_CopyVoiceDataToAllChannels(void);
extern void SeqPlay_ActivateAllChannels(void);
extern void BitMapOut_PrepareAndRender(int);
extern void TempoRingBuf_Init(void);
extern void SoundCtrl_SaveAndSendCmd_EE(unsigned int);
extern void MIDI_SendSysExCmd(int);
extern void Audio_CheckSubsystemReady(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern void Demo_PreSetup(void);
extern void SeqAcc_InitPlaybackState(void);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
extern void SeqBuf_SaveWritePos(void);
extern void AccNoteOn_ChannelDispatch(void);
extern void SeqBuf_Init(void);
extern void Part_WriteWord(unsigned int, unsigned int, unsigned int);
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern unsigned char PartCtrl_ReadByte(unsigned int, unsigned int);
extern unsigned int Voice_GetPresetFieldWord(unsigned int);
extern unsigned int Rhythm_ComputeNoteAllocation(unsigned int);
extern unsigned char Part_ReadSubBlock32(unsigned int, unsigned int);
extern void SeqError_MapToGlobal(unsigned char *);

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

void Accomp_UpdateModeFlag(void)
{
  if (CURRENT_TITLE == 129 || SEQ_TRACK_MASK != 0)
    ram_28a5 |= 0x01;
  else
    ram_28a5 &= ~0x01;
  SEQ_TRACK_MASK = SEQ_TRACK_MASK_COPY;
  Audio_CheckSubsystemReady();
  CtrlPanel_SetIndicatorBit(0x4c);
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

void SeqPlay_SaveStateAndCleanup(void)
{
  SEQ_TRACK_MASK_COPY = SEQ_TRACK_MASK;
  if (!(ram_28a5 & 0x01)) {
    SEQ_TRACK_MASK = 0;
    Audio_CheckSubsystemReady();
  }
  Audio_CheckSubsystemReady();
}

void SeqAcc_SetIndicator_PB(void)
{
  ram_2875 = SEQ_TRACK_MASK;
  Demo_PreSetup();
  ram_28a5 &= ~0x01;
  CtrlPanel_SetIndicatorBit(0x4c);
}

void Part_WriteWord_Indexed(unsigned char a, unsigned char c, unsigned int v)
{
  Part_WriteWord(a, 0x78 + (unsigned char)(c * 2 - 2), v);
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

void SeqStatus_ResetAndSendCmd(void)
{
  PANEL_GM[3] &= ~0x01;
  AddswbWr(0x91, 3, 0, 1);
}

unsigned int Part_ReadByte_Indexed(unsigned char a, unsigned char c)
{
  return Part_ReadByteDirect(a, 0x98 + (unsigned char)(c - 1));
}

void SeqBuf_FlushAndReinit_NoteEvents(void)
{
  SeqBuf_SaveWritePos();
  AccNoteOn_ChannelDispatch();
  SeqBuf_Init();
  ram_1d84 = 0;
}

void PartCtrl_WriteByte_Indexed(unsigned char v)
{
  PartCtrl_WriteByteToBuf(SEQ_DATA_BLOCK, (unsigned char)SEQ_DATA_OFFSET, v);
}

void SeqPart_WriteByte_Secondary(unsigned char v)
{
  PartCtrl_WriteByteToBuf(SEQOP_SECONDARY_BLOCK, (unsigned char)SEQOP_SECONDARY_OFFSET, v);
}

void Part_WriteVoiceWord(unsigned char a, unsigned char c, unsigned int v)
{
  Part_WriteWord(a, (unsigned char)(c * 3 - 3 + 0xd1), v);
}

unsigned char SeqPart_ReadByte_Primary(void)
{
  return PartCtrl_ReadByte(SEQOP_PRIMARY_BLOCK, (unsigned char)SEQOP_PRIMARY_OFFSET);
}

unsigned int SeqModeTransit_GetPresetWord(void)
{
  return Voice_GetPresetFieldWord(DEMO_ACTIVE_ENTRY);
}

unsigned char SeqStatus_CheckBit2(void)
{
  return PANEL_GM[3] & 0x04;
}

unsigned int SeqBuf_AllocNextSlotAdjusted(unsigned int n)
{
  return Rhythm_ComputeNoteAllocation(n + 1) - 1;
}

unsigned char Part_ReadVoiceByte(unsigned char a, unsigned char c)
{
  return Part_ReadSubBlock32(a, c);
}

void SeqError_MapViaTableA(void)
{
  SeqError_MapToGlobal(SeqError_MapTableA);
}

void SeqError_MapViaTableF(void)
{
  SeqError_MapToGlobal(SeqError_MapTableF);
}
