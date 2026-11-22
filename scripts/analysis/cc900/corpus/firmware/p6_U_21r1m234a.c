/* helper U, round 21r1, module 234 (sequencer/sequencer_engine.s), form a: one-spot retries of runs r58 / r59.
   Indexed accessors: the ROM loads the base constant into its own register and adds the byte offset as a word,
   so the constant lives in an unsigned int local (V4.23 folds `K + (unsigned char)x` into a byte add).
   Voice accessors: c * 3 - 3 stored back before the + 0xd1 / 0xd0 (V4.23 folds -3 + 0xd1 otherwise).
   Song-slot copies: the slot address through a pointer local (the ROM's lda).
   Memory-to-memory moves the ROM does through WA: both cells volatile. */
/* cc900-module: Part_ReadByteDirect Part_ReadWord Part_WriteByte Part_WriteWord */

struct song { unsigned char b[0x800]; };

extern unsigned char __near CURRENT_TITLE;
extern volatile unsigned int __near SEQ_TRACK_MASK;
extern volatile unsigned int SEQ_TRACK_MASK_COPY;
extern volatile unsigned int __near ram_2875;
extern unsigned char __near ram_28a5;
extern struct song SEQ_SONG_RECORD;
extern struct song SEQ_SONG_SLOTS[];
extern void Audio_CheckSubsystemReady(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern void Demo_PreSetup(void);
extern void VoiceChannels_InitPanFromPreset(void);
extern unsigned int Part_ReadWord(unsigned int, unsigned int);
extern void Part_WriteWord(unsigned int, unsigned int, unsigned int);
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);
extern void Part_WriteByte(unsigned int, unsigned int, unsigned int);

unsigned int Part_ReadByte_Indexed(unsigned char a, unsigned char c)
{
  unsigned int k;
  k = 0x98;
  k += (unsigned char)(c - 1);
  return Part_ReadByteDirect(a, k);
}

void Part_WriteByte_Indexed(unsigned char a, unsigned char c, unsigned char v)
{
  unsigned int k;
  k = 0x98;
  k += (unsigned char)(c - 1);
  Part_WriteByte(a, k, v);
}

unsigned int Part_ReadWord_Indexed(unsigned char a, unsigned char c)
{
  unsigned int k;
  k = 0x78;
  k += (unsigned char)(c + c - 2);
  return Part_ReadWord(a, k);
}

void Part_WriteWord_Indexed(unsigned char a, unsigned char c, unsigned int v)
{
  unsigned int k;
  k = 0x78;
  k += (unsigned char)(c + c - 2);
  Part_WriteWord(a, k, v);
}

void Part_WriteVoiceWord(unsigned char a, unsigned char c, unsigned int v)
{
  c = c * 3 - 3;
  Part_WriteWord(a, (unsigned char)(c + 0xd1), v);
}

unsigned int Part_ReadVoiceWord(unsigned char a, unsigned char c)
{
  c = c * 3 - 3;
  return Part_ReadWord(a, (unsigned char)(c + 0xd1));
}

unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  c = c * 3 - 3;
  return Part_ReadByteDirect(a, (unsigned char)(c + 0xd0)) & 0x80;
}

void SeqData_CopyBlockToBuffer(unsigned char a)
{
  struct song *p;
  p = &SEQ_SONG_SLOTS[a];
  *p = SEQ_SONG_RECORD;
}

void VoicePreset_LoadAndInitPan(unsigned char a)
{
  struct song *p;
  p = &SEQ_SONG_SLOTS[a];
  SEQ_SONG_RECORD = *p;
  VoiceChannels_InitPanFromPreset();
}

void SeqAcc_SetIndicator_PB(void)
{
  ram_2875 = SEQ_TRACK_MASK;
  Demo_PreSetup();
  ram_28a5 &= ~0x01;
  CtrlPanel_SetIndicatorBit(0x4c);
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
