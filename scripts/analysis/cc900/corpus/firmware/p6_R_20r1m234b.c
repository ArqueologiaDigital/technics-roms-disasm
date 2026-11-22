/* Helper R, round 1 of 2026-11-20: module 234 (sequencer/sequencer_engine.s), form b: the uncertain spots of form a
   (converted table pointers, distributed (c - 1) * k, operand order of the mask, locals for the offset). */
/* cc900-module: PartCtrl_ReadByte PartCtrl_WriteByteToBuf Part_ReadByteDirect Part_ReadWord SeqError_MapToGlobal */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern unsigned char ram_b0000[];
extern unsigned char __near PANEL_MIDI[];
extern unsigned int Part_ReadWord(unsigned int, unsigned int);
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);

unsigned char SeqPart_ReadByte_Secondary(void)
{
  unsigned int o;
  unsigned char c;
  o = SEQOP_SECONDARY_OFFSET;
  c = o;
  return PartCtrl_ReadByte(SEQOP_SECONDARY_BLOCK, c);
}

unsigned char SeqData_ReadNextByte(void)
{
  unsigned int o;
  unsigned char c;
  o = SEQ_DATA_OFFSET;
  c = o;
  return PartCtrl_ReadByte(SEQ_DATA_BLOCK, c);
}

void SeqPart_WriteByte_Primary(unsigned char v)
{
  unsigned int o;
  unsigned char c;
  o = SEQOP_PRIMARY_OFFSET;
  c = o;
  PartCtrl_WriteByteToBuf(SEQOP_PRIMARY_BLOCK, c, v);
}

void SeqError_MapViaTableE(void)
{
  SeqError_MapToGlobal((unsigned char *)(long)SeqError_MapTableE);
}

void SeqError_MapViaTableB(void)
{
  SeqError_MapToGlobal((unsigned char *)(long)SeqError_MapTableB);
}

void SeqError_MapViaTableC(void)
{
  SeqError_MapToGlobal((unsigned char *)(long)SeqError_MapTableC);
}

void PartCtrl_SetClearBit7(unsigned int n, unsigned char c)
{
  unsigned char *p = &ram_b0000[(unsigned long)(n - 1) << 8];
  if (c == 0) {
    *p &= ~0x80;
    return;
  }
  *p |= 0x80;
}

unsigned char SeqStatus_CheckMaskedBit(unsigned char a)
{
  return a & PANEL_MIDI[2];
}

unsigned int Part_ReadVoiceWord(unsigned char a, unsigned char c)
{
  return Part_ReadWord(a, (unsigned char)(c * 3 - 3 + 0xd1));
}

unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  return Part_ReadByteDirect(a, (unsigned char)(c * 3 - 3 + 0xd0)) & 0x80;
}

unsigned int Part_ReadWord_Indexed(unsigned char a, unsigned char c)
{
  return Part_ReadWord(a, 0x78 + (unsigned char)(c + c - 2));
}
