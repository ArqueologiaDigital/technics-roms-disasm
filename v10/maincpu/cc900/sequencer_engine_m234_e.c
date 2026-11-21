/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadByte PartCtrl_WriteByteToBuf Part_CopyVoiceDataToAllChannels Part_ReadByteDirect Part_ReadSubBlock32 Part_ReadWord Part_WriteByte Part_WriteWord Rhythm_ComputeNoteAllocation SeqError_MapToGlobal SeqModeTransit_GetPresetWord */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_WriteByte_Indexed(unsigned char v);
extern unsigned char Part_ReadSubBlock32(unsigned int, unsigned int);
extern unsigned char Part_ReadVoiceByte(unsigned char a, unsigned char c);
extern unsigned int Rhythm_ComputeNoteAllocation(unsigned int);
extern unsigned int SeqBuf_AllocNextSlotAdjusted(unsigned int n);
extern unsigned char __near ram_1d84;
extern void SeqBuf_SaveWritePos(void);
extern void AccNoteOn_ChannelDispatch(void);
extern void SeqBuf_Init(void);
extern void SeqBuf_FlushAndReinit_NoteEvents(void);
extern unsigned char SeqError_MapTableA[];
extern void SeqError_MapToGlobal(unsigned char *);
extern void SeqError_MapViaTableA(void);
extern unsigned char SeqError_MapTableF[];
extern void SeqError_MapViaTableF(void);
extern unsigned char __near SEQ_RTMCFG;
extern void SeqAcc_InitPlaybackState(void);
extern void SeqInit_ClearPlaybackFlags(void);
extern unsigned char __near DEMO_ACTIVE_ENTRY;
extern unsigned int Voice_GetPresetFieldWord(unsigned int);
extern unsigned int SeqModeTransit_GetPresetWord(void);
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned char PartCtrl_ReadByte(unsigned int, unsigned int);
extern unsigned char SeqPart_ReadByte_Primary(void);
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern void SeqPart_WriteByte_Secondary(unsigned char v);
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned char __near ram_11f4;
extern void AccWrap_PlayModeDispatch(void);
extern void Part_CopyVoiceDataToAllChannels(void);
extern void SeqPlay_ActivateAllChannels(void);
extern void BitMapOut_PrepareAndRender(int);
extern void TempoRingBuf_Init(void);
extern void SoundCtrl_SaveAndSendCmd_EE(unsigned int);
extern void MIDI_SendSysExCmd(int);
extern void SeqPlay_DispatchAndResetAll(void);
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_RECORDING_TRACKS;
extern void Audio_CheckSubsystemReady(void);
extern void SeqPlay_StopAndClearChannels(void);
extern unsigned char __near PANEL_GM[];
extern unsigned char SeqStatus_CheckBit2(void);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
extern void SeqStatus_ResetAndSendCmd(void);
extern void SeqVoice_SetOrClearBitMask(unsigned char part, unsigned char on);
extern unsigned int __near SEQ_TRACK_MASK;
extern void Chan_SetActiveBit(unsigned char a, unsigned char c);
extern unsigned char ram_b0000[];
extern void PartCtrl_SetClearBit7(unsigned int n, unsigned char c);
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned char SeqError_MapTableB[];
extern void SeqError_MapViaTableB(void);
extern unsigned char SeqError_MapTableC[];
extern void SeqError_MapViaTableC(void);
extern unsigned char SeqError_MapTableE[];
extern void SeqError_MapViaTableE(void);
extern unsigned int __near ram_2314;
extern void SeqModeTransit_DemoPath(void);
extern unsigned char SeqPart_ReadByte_Secondary(void);
extern void SeqPart_WriteByte_Primary(unsigned char v);
extern unsigned int __near SEQ_START_MEASURE;
extern void NoteEditSy_SendModeScrollReset(void);
extern void SeqPlay_SetBarAndResetScroll(void);
extern unsigned char __near PANEL_MIDI[];
extern unsigned char SeqStatus_CheckMaskedBit(unsigned char a);

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
