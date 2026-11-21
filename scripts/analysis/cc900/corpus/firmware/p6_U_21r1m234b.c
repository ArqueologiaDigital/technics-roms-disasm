/* helper U, round 21r1, module 234, form b: as form a but the byte offset in its own unsigned char local before
   the word add; the voice offset in a local; the slot pointer from the array base then advanced; the
   memory-to-memory moves through a plain local (cells not volatile). */
/* cc900-module: Part_ReadByteDirect Part_ReadWord Part_WriteByte Part_WriteWord */

struct song { unsigned char b[0x800]; };

extern unsigned char __near CURRENT_TITLE;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned int __near ram_2875;
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
  unsigned char o;
  k = 0x98;
  o = c - 1;
  k += o;
  return Part_ReadByteDirect(a, k);
}

void Part_WriteByte_Indexed(unsigned char a, unsigned char c, unsigned char v)
{
  unsigned int k;
  k = 0x98;
  c--;
  k += c;
  Part_WriteByte(a, k, v);
}

unsigned int Part_ReadWord_Indexed(unsigned char a, unsigned char c)
{
  unsigned int k;
  unsigned char o;
  k = 0x78;
  o = c + c - 2;
  k += o;
  return Part_ReadWord(a, k);
}

void Part_WriteWord_Indexed(unsigned char a, unsigned char c, unsigned int v)
{
  unsigned int k;
  unsigned char o;
  k = 0x78;
  o = c + c - 2;
  k += o;
  Part_WriteWord(a, k, v);
}

void Part_WriteVoiceWord(unsigned char a, unsigned char c, unsigned int v)
{
  unsigned char o;
  o = c * 3 - 3;
  o += 0xd1;
  Part_WriteWord(a, o, v);
}

unsigned int Part_ReadVoiceWord(unsigned char a, unsigned char c)
{
  unsigned char o;
  o = c * 3 - 3;
  o += 0xd1;
  return Part_ReadWord(a, o);
}

unsigned char Part_ReadVoiceBit7(unsigned char a, unsigned char c)
{
  unsigned char o;
  o = c * 3 - 3;
  o += 0xd0;
  return Part_ReadByteDirect(a, o) & 0x80;
}

void SeqData_CopyBlockToBuffer(unsigned char a)
{
  struct song *p;
  p = SEQ_SONG_SLOTS;
  p += a;
  *p = SEQ_SONG_RECORD;
}

void VoicePreset_LoadAndInitPan(unsigned char a)
{
  struct song *p;
  p = SEQ_SONG_SLOTS;
  p += a;
  SEQ_SONG_RECORD = *p;
  VoiceChannels_InitPanFromPreset();
}

void SeqAcc_SetIndicator_PB(void)
{
  unsigned int t;
  t = SEQ_TRACK_MASK;
  ram_2875 = t;
  Demo_PreSetup();
  ram_28a5 &= ~0x01;
  CtrlPanel_SetIndicatorBit(0x4c);
}

void SeqPlay_SaveStateAndCleanup(void)
{
  unsigned int t;
  t = SEQ_TRACK_MASK;
  SEQ_TRACK_MASK_COPY = t;
  if (!(ram_28a5 & 0x01)) {
    SEQ_TRACK_MASK = 0;
    Audio_CheckSubsystemReady();
  }
  Audio_CheckSubsystemReady();
}

void Accomp_UpdateModeFlag(void)
{
  unsigned int t;
  if (CURRENT_TITLE == 129 || SEQ_TRACK_MASK != 0)
    ram_28a5 |= 0x01;
  else
    ram_28a5 &= ~0x01;
  t = SEQ_TRACK_MASK_COPY;
  SEQ_TRACK_MASK = t;
  Audio_CheckSubsystemReady();
  CtrlPanel_SetIndicatorBit(0x4c);
}
