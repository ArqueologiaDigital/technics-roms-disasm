/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Part_ReadByteDirect Part_ReadWord Part_WriteByte Part_WriteWord */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near CURRENT_TITLE;
extern volatile unsigned int __near SEQ_TRACK_MASK;
extern volatile unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned char __near ram_2889;
extern void Audio_CheckSubsystemReady(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern void Accomp_UpdateModeFlag(void);
extern void Part_WriteByte(unsigned int, unsigned int, unsigned int);
extern void Part_WriteByte_Indexed(unsigned char a, unsigned char c, unsigned char v);
extern void Part_WriteWord(unsigned int, unsigned int, unsigned int);
extern void Part_WriteWord_Indexed(unsigned char a, unsigned char c, unsigned int v);
extern volatile unsigned int __near ram_2859;
extern void Demo_PreSetup(void);
extern void SeqAcc_SetIndicator_PB(void);
struct song { unsigned char b[0x800]; };
extern struct song SEQ_SONG_RECORD;
extern struct song SEQ_SONG_SLOTS[];
extern void SeqData_CopyBlockToBuffer(unsigned char a);
extern void SeqPlay_SaveStateAndCleanup(void);
extern unsigned char Part_ReadByteDirect(unsigned int, unsigned int);
extern unsigned int Part_ReadByte_Indexed(unsigned char a, unsigned char c);

void Accomp_UpdateModeFlag(void)
{
  if (CURRENT_TITLE == 129 || SEQ_TRACK_MASK != 0)
    ram_2889 |= 0x01;
  else
    ram_2889 &= ~0x01;
  SEQ_TRACK_MASK = SEQ_TRACK_MASK_COPY;
  Audio_CheckSubsystemReady();
  CtrlPanel_SetIndicatorBit(0x4c);
}

void Part_WriteByte_Indexed(unsigned char a, unsigned char c, unsigned char v)
{
  unsigned int k;
  k = 0x98;
  k += (unsigned char)(c - 1);
  Part_WriteByte(a, k, v);
}

void Part_WriteWord_Indexed(unsigned char a, unsigned char c, unsigned int v)
{
  unsigned int k;
  k = 0x78;
  k += (unsigned char)(c + c - 2);
  Part_WriteWord(a, k, v);
}

void SeqAcc_SetIndicator_PB(void)
{
  ram_2859 = SEQ_TRACK_MASK;
  Demo_PreSetup();
  ram_2889 &= ~0x01;
  CtrlPanel_SetIndicatorBit(0x4c);
}

void SeqData_CopyBlockToBuffer(unsigned char a)
{
  struct song *p;
  p = &SEQ_SONG_SLOTS[a];
  *p = SEQ_SONG_RECORD;
}

void SeqPlay_SaveStateAndCleanup(void)
{
  SEQ_TRACK_MASK_COPY = SEQ_TRACK_MASK;
  if (!(ram_2889 & 0x01)) {
    SEQ_TRACK_MASK = 0;
    Audio_CheckSubsystemReady();
  }
  Audio_CheckSubsystemReady();
}


unsigned int Part_ReadByte_Indexed(unsigned char a, unsigned char c)
{
  unsigned int k;
  unsigned char o;
  k = 0x98;
  o = c - 1;
  k += o;
  return Part_ReadByteDirect(a, k);
}
