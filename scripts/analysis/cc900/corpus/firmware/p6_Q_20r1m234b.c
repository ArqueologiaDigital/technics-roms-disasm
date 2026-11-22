/* helper Q, round 20r1, module 234, form b: one-spot alternatives of form a (index arithmetic, converted table
   pointer, the RTMCFG byte cleared through the cell). */
/* cc900-module: Part_WriteWord SeqError_MapToGlobal PartCtrl_ReadByte */

extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near SEQOP_PRIMARY_OFFSET;
extern unsigned int __near SEQOP_PRIMARY_BLOCK;
extern unsigned char SeqError_MapTableA[];
extern unsigned char SeqError_MapTableF[];
extern void SeqAcc_InitPlaybackState(void);
extern void Part_WriteWord(unsigned int, unsigned int, unsigned int);
extern unsigned char PartCtrl_ReadByte(unsigned int, unsigned int);
extern void SeqError_MapToGlobal(unsigned char *);

void Part_WriteWord_Indexed(unsigned char a, unsigned char c, unsigned int v)
{
  unsigned char o;
  o = c + c;
  o -= 2;
  Part_WriteWord(a, 0x78 + o, v);
}

void Part_WriteVoiceWord(unsigned char a, unsigned char c, unsigned int v)
{
  unsigned char o;
  o = c * 3;
  o -= 3;
  o += 0xd1;
  Part_WriteWord(a, o, v);
}

void SeqInit_ClearPlaybackFlags(void)
{
  unsigned char f = SEQ_RTMCFG;
  f &= ~0x0b;
  SEQ_RTMCFG = f;
  SeqAcc_InitPlaybackState();
}

unsigned char SeqPart_ReadByte_Primary(void)
{
  unsigned int o;
  unsigned char c;
  o = SEQOP_PRIMARY_OFFSET;
  c = o;
  return PartCtrl_ReadByte(SEQOP_PRIMARY_BLOCK, c);
}

void SeqError_MapViaTableA(void)
{
  SeqError_MapToGlobal((unsigned char *)(long)SeqError_MapTableA);
}

void SeqError_MapViaTableF(void)
{
  SeqError_MapToGlobal((unsigned char *)(long)SeqError_MapTableF);
}
