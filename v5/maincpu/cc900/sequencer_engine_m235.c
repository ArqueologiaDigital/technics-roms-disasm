/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char Part_ReadByteDirect(unsigned char, unsigned int);
extern void Part_WriteByte(unsigned char, unsigned int, unsigned char);
extern unsigned int Part_ReadWord(unsigned char, unsigned int);
extern void Part_WriteWord(unsigned char, unsigned int, unsigned int);
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near ram_8c80;
extern void ApDeliveryEvent(long, long, long);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern int FileIO_SeekAndReadBlock(unsigned long, unsigned int);
extern int FileIO_ReadByte_BufferHit(unsigned int);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern void Part_WriteVoiceWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned int, unsigned int, unsigned int);
extern unsigned char __near ram_8cc8;
extern unsigned char *SeqStep_ReinitPartTable(void);
extern void SeqData_CopyBlockToBuffer(unsigned int);
extern void SetVisible(long, unsigned int);
extern unsigned char Part_ReadVoiceBit7(unsigned int, unsigned int);
extern unsigned int Part_ReadVoiceWord(unsigned int, unsigned int);
extern unsigned int Part_ProcessAndDecrementVoice(void);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern unsigned long __near SEQ_BLOCK_POOL;


void SeqLoad_RestorePartConfig(void)
{
  SEQ_CURRENT_SONG = Part_ReadByteDirect(1, 0xc7);
  Part_WriteByte(1, 0xc7, 0);
  SEQ_TRACK_MASK_COPY = Part_ReadWord(1, 0xc8);
  Part_WriteWord(1, 0xc8, 0);
  SEQ_START_MEASURE = 1;
  SEQ_RTMCFG &= ~0x08;
}

void SeqMode_SendStatusUpdate(void)
{
  switch (ram_8c80) {
  case 0x81: ApDeliveryEvent(0x810005L, 0x1c0000fL, 1L); break;
  case 0x85: ApDeliveryEvent(0x850007L, 0x1c0000fL, 1L); break;
  case 0x87: ApDeliveryEvent(0x870003L, 0x1c0000fL, 1L); break;
  }
}


void SeqNote_QueueReturn(void)
{
  SEQ_DATA_OFFSET += 6;
  if (SEQ_DATA_OFFSET <= 0xff) return;
  SEQ_DATA_OFFSET -= 0x100;
  SEQ_DATA_OFFSET += 5;
  SEQ_DATA_BLOCK = PartCtrl_ReadWord(SEQ_DATA_BLOCK);
}

long FileIO_SeekReadAndCheck(unsigned long a, unsigned char c)
{
  long r = FileIO_SeekAndReadBlock(a, 0);
  if (r == 0) r = FileIO_ReadByte_BufferHit(c);
  return r;
}



void SeqSavePost(int e)
{
  Part_WriteByte(1, 4, 0);
  if (e >= 0) ram_8cc8 &= ~0x01;
}

unsigned char *SeqSavePre(void)
{
  unsigned char *r = SeqStep_ReinitPartTable();
  SeqData_CopyBlockToBuffer(SEQ_CURRENT_SONG);
  Part_WriteByte(1, 4, 1);
  return r;
}


void VoiceParam_SetD6Group(unsigned char a)
{
  unsigned int v = a != 0;
  SetVisible(0xd60003L, v);
  SetVisible(0xd60004L, v);
  SetVisible(0xd60005L, v);
  SetVisible(0xd60006L, v);
}

void SeqLoad_ProcessAllVoiceData(void)
{
  unsigned char s, p;
  unsigned int w, b, t;
  unsigned char *ps;
  unsigned long os;
  unsigned char *pd;
  unsigned long od;
  unsigned int i;
  s = 1;
  do {
    p = 1;
    do {
      if (Part_ReadVoiceBit7(s, p) == 0) continue;
      w = Part_ReadVoiceWord(s, p);
      if (w == 0xffff) continue;
      if (w == 0xffff) continue;
      do {
        if (w == 1 || w == 2) {
          do {
            b = Part_ProcessAndDecrementVoice();
            if (b > 0x4d8) return;
          } while (b == 1 || b == 2);
          ps = (unsigned char *)SEQ_BLOCK_POOL;
          os = ((unsigned long)w - 1) << 8;
          pd = (unsigned char *)SEQ_BLOCK_POOL;
          od = ((unsigned long)b - 1) << 8;
          i = 0;
          do { pd[i + od] = ps[i + os]; i++; } while (i < 0x100);
          t = PartCtrl_ReadWord_Off1(w);
          if (t != 0) PartCtrl_WriteWord(t, b);
          else {
            Part_WriteVoiceWord(s, p, b);
            if ((unsigned char)(s - 1) == SEQ_CURRENT_SONG) Part_WriteVoiceWord(0, p, b);
          }
          t = PartCtrl_ReadWord(w);
          if (t != 0xffff) PartCtrl_WriteWord_Off1(t, b);
          else {
            Part_WriteWord_Indexed(s, p, b);
            if ((unsigned char)(s - 1) == SEQ_CURRENT_SONG) Part_WriteWord_Indexed(0, p, b);
          }
        }
        w = PartCtrl_ReadWord(w);
      } while (w != 0xffff);
    } while (++p <= 16);
  } while (++s <= 10);
  PartCtrl_SetClearBit7(1, 1);
  PartCtrl_WriteWord_Off1(1, 0);
  PartCtrl_WriteWord(1, 0xffff);
  PartCtrl_WriteByteToBuf(1, 5, 0x82);
  PartCtrl_SetClearBit7(2, 1);
  PartCtrl_WriteWord_Off1(2, 0);
  PartCtrl_WriteWord(2, 0xffff);
  PartCtrl_WriteByteToBuf(2, 5, 0x82);
}

/* cc900-module: SeqModeTransit_DemoPath SeqModeTransit_UpdateParts SeqPart_InitClear SeqPart_UndoAllocOnError */
extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near ram_29ae;
extern unsigned int __near ram_29b0;
extern void SeqLoad_RestoreFreeBlockList(void);
extern unsigned char __near ram_256d;
extern unsigned int __near ram_2574;
extern unsigned int __near ram_2576;
extern unsigned char __near ram_2578;
extern unsigned char __near ram_288a;
extern void SeqScan_UpdateBestPositionA(void);
extern void SeqScan_UpdateBestPositionB(void);

void SeqLoad_RestoreFreeBlockList(void)
{
  SEQ_FREE_LIST_HEAD = ram_29ae;
  SEQ_FREE_BLOCKS = ram_29b0;
}
void SeqScan_UpdateBestPositionA(void)
{
  unsigned int b = ram_2574, w = ram_2576;
  if (w > b) return;
  if (w == b && ram_2578 > ram_256d) return;
  ram_2576 = b;
  ram_2578 = ram_256d;
  ram_288a |= 0x01;
}
void SeqScan_UpdateBestPositionB(void)
{
  unsigned int b = ram_2574, w = ram_2576;
  if (w > b) return;
  if (w == b && ram_2578 > ram_256d) return;
  ram_2576 = b;
  ram_2578 = ram_256d;
  ram_288a &= ~0x01;
}

/* cc900-module: FileIO_SeekAndRead16BitValue NotePool_InsertEntry SeqAcc_InitPlayback_FreshStart SeqPlay_CheckDrumPartAndClearCounters SeqPlay_ProcessChannelsAndDrum SeqPlay_ReactivatePartsAndResume SeqPlay_RestartWithVoiceConfig */
extern unsigned char __near ACTIVE_TITLE;
extern unsigned long __near SEQ_SCREEN_OBJECT;
extern void SeqAccomp_SendStopNotify(void);

void SeqAccomp_SendStopNotify(void)
{
  if (ACTIVE_TITLE == 0x85 || ACTIVE_TITLE == 0x87)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, 0x1c0000fL, 2L);
}
