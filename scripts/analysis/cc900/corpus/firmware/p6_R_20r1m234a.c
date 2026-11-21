/* Helper R, round 1 of 2026-11-20: module 234 (sequencer/sequencer_engine.s), part-record accessors.  Form a. */
/* cc900-module: PartCtrl_ReadByte PartCtrl_WriteByteToBuf Part_ReadByteDirect Part_ReadWord Part_WriteByte SeqError_MapToGlobal SeqModeTransit_GetPresetWord */   /* scripts/analysis/cc900/module_calls.py v10 */

struct song { unsigned char b[0x800]; };

extern unsigned int SeqModeTransit_GetPresetWord(void);
extern unsigned int __near ram_2314;
extern unsigned int __near SEQOP_SECONDARY_OFFSET;
extern unsigned int __near SEQOP_SECONDARY_BLOCK;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned char PartCtrl_ReadByte(unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void SeqError_MapToGlobal(unsigned char *);
extern unsigned char SeqError_MapTableE[];
extern unsigned char SeqError_MapTableB[];
extern unsigned char SeqError_MapTableC[];
extern struct song SEQ_SONG_SLOTS[];
extern struct song SEQ_SONG_RECORD;
extern void VoiceChannels_InitPanFromPreset(void);
extern unsigned int __near SEQ_TRACK_MASK;
extern void Audio_CheckSubsystemReady(void);
extern unsigned char ram_b0000[];
extern unsigned int __near SEQ_START_MEASURE;
extern void NoteEditSy_SendModeScrollReset(void);
extern unsigned char __near PANEL_MIDI[];
extern unsigned int Part_ReadWord(unsigned int, unsigned int);
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);
extern void Part_WriteByte(unsigned int, unsigned int, unsigned int);

void SeqModeTransit_DemoPath(void)
{
  ram_2314 = SeqModeTransit_GetPresetWord();
}

unsigned char SeqPart_ReadByte_Secondary(void)
{
  return PartCtrl_ReadByte(SEQOP_SECONDARY_BLOCK, (unsigned char)SEQOP_SECONDARY_OFFSET);
}

unsigned char SeqData_ReadNextByte(void)
{
  return PartCtrl_ReadByte(SEQ_DATA_BLOCK, (unsigned char)SEQ_DATA_OFFSET);
}

void SeqPart_WriteByte_Primary(unsigned char v)
{
  PartCtrl_WriteByteToBuf(SEQOP_PRIMARY_BLOCK, (unsigned char)SEQOP_PRIMARY_OFFSET, v);
}

void SeqError_MapViaTableE(void)
{
  SeqError_MapToGlobal(SeqError_MapTableE);
}

void SeqError_MapViaTableB(void)
{
  SeqError_MapToGlobal(SeqError_MapTableB);
}

void SeqError_MapViaTableC(void)
{
  SeqError_MapToGlobal(SeqError_MapTableC);
}

void SeqData_CopyBlockToBuffer(unsigned char a)
{
  SEQ_SONG_SLOTS[a] = SEQ_SONG_RECORD;
}

void VoicePreset_LoadAndInitPan(unsigned char a)
{
  SEQ_SONG_RECORD = SEQ_SONG_SLOTS[a];
  VoiceChannels_InitPanFromPreset();
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

void SeqPlay_SetBarAndResetScroll(void)
{
  SEQ_START_MEASURE = 0x8002;
  NoteEditSy_SendModeScrollReset();
}

unsigned char SeqStatus_CheckMaskedBit(unsigned char a)
{
  return PANEL_MIDI[2] & a;
}

unsigned int Part_ReadVoiceWord(unsigned char a, unsigned char c)
{
  return Part_ReadWord(a, (unsigned char)((c - 1) * 3 + 0xd1));
}

unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  return Part_ReadByteDirect(a, (unsigned char)((c - 1) * 3 + 0xd0)) & 0x80;
}

unsigned int Part_ReadWord_Indexed(unsigned char a, unsigned char c)
{
  return Part_ReadWord(a, 0x78 + (unsigned char)((c - 1) * 2));
}

void Part_WriteByte_Indexed(unsigned char a, unsigned char c, unsigned char v)
{
  Part_WriteByte(a, 0x98 + (unsigned char)(c - 1), v);
}
