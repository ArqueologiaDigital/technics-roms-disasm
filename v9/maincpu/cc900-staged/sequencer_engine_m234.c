/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: PartCtrl_ReadWord PartCtrl_ReadWord_Off1 PartCtrl_SetClearBit7 PartCtrl_TestBit7 PartCtrl_WriteWord PartCtrl_WriteWord_Off1 Part_DecrementVoicePos Part_WriteByte Part_WriteWord Part_WriteWordBlock_OffsetAF SeqModeTransit_DemoPath SeqModeTransit_UpdateParts SeqPart_InitClear SeqPart_UndoAllocOnError SeqStatus_CheckBit2 */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void Part_WriteByte();
extern void Part_WriteWord();
extern unsigned char Boot_ReadFDCStatus(void);
extern unsigned char SeqStatus_CheckBit2(void);
extern void Part_InitVoiceDefaults(unsigned char a);
extern unsigned char PartCtrl_TestBit7(unsigned int);
extern void PartCtrl_SetClearBit7(unsigned int, unsigned int);
extern int Part_DecrementVoicePos(void);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern void Part_WriteWordBlock_OffsetAF(unsigned int);
extern void PartCtrl_WriteWord_Off1(unsigned int, unsigned int);
extern void PartCtrl_WriteWord(unsigned int, unsigned int);
extern void Part_UnlinkVoiceFromChain(void);
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char __near SEQ_SONG;
extern void SeqVoice_InitEntryForCurrentBank(void);
extern void SeqVoice_InitEntry(void);
extern unsigned char __near ram_28a1;
extern unsigned char __near ram_289e;
extern unsigned int __near ram_28a2;
extern unsigned int __near SEQ_BLOCK_TOTAL;
extern unsigned long __near SEQ_BLOCK_POOL;
extern unsigned long __near ram_ce8;
extern unsigned int __near ram_d30;
extern void SeqVoice_SetDefaultParams(void);
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_CHORD_FROM_SONG;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near ram_28ac;
extern unsigned int __near ram_2838;
extern void SeqModeTransit_DemoPath(void);
extern void SeqModeTransit_UpdateParts(void);
extern void Seq_HandleModeTransition(void);

void Part_InitVoiceDefaults(unsigned char a)
{
  unsigned int i;
  unsigned char r;
  Part_WriteByte(a, 0, 0x5a);
  Part_WriteByte(a, 1, 0x5a);
  Part_WriteByte(a, 2, 0x5a);
  Part_WriteByte(a, 3, 0x5a);
  Part_WriteByte(a, 4, 0);
  Part_WriteByte(a, 5, 1);
  Part_WriteByte(a, 6, 8);
  Part_WriteByte(a, 7, 0);
  r = Boot_ReadFDCStatus();
  Part_WriteByte(a, 8, r);
  Part_WriteWord(a, 0x14, 0);
  Part_WriteWord(a, 0x16, 0x100);
  Part_WriteWord(a, 0x18, 0x2e);
  Part_WriteWord(a, 0x1a, 0x520);
  i = 0;
  do { Part_WriteByte(a, i + 0x42, 0); i++; } while (i < 12);
  if (SeqStatus_CheckBit2() == 0) Part_WriteByte(a, 0xbd, 0);
  else Part_WriteByte(a, 0xbd, 0xff);
}

void Part_UnlinkVoiceFromChain(void)
{
  unsigned int p, n;
  if (PartCtrl_TestBit7(1) == 0) {
    PartCtrl_SetClearBit7(1, 1);
    Part_DecrementVoicePos();
    p = PartCtrl_ReadWord_Off1(1);
    n = PartCtrl_ReadWord(1);
    if (p == 0) {
      if (n != 0xffff) { Part_WriteWordBlock_OffsetAF(n); PartCtrl_WriteWord_Off1(n, 0); }
    } else if (n == 0xffff) PartCtrl_WriteWord(p, 0xffff);
    else { PartCtrl_WriteWord(p, n); PartCtrl_WriteWord_Off1(n, p); }
    PartCtrl_WriteWord_Off1(1, 0);
    PartCtrl_WriteWord(1, 0xffff);
  }
  if (PartCtrl_TestBit7(2) == 0) {
    PartCtrl_SetClearBit7(2, 1);
    Part_DecrementVoicePos();
    p = PartCtrl_ReadWord_Off1(2);
    n = PartCtrl_ReadWord(2);
    if (p == 0) {
      if (n != 0xffff) { Part_WriteWordBlock_OffsetAF(n); PartCtrl_WriteWord_Off1(n, 0); }
    } else if (n == 0xffff) PartCtrl_WriteWord(p, 0xffff);
    else { PartCtrl_WriteWord(p, n); PartCtrl_WriteWord_Off1(n, p); }
    PartCtrl_WriteWord_Off1(2, 0);
    PartCtrl_WriteWord(2, 0xffff);
  }
}

void SeqVoice_InitEntryForCurrentBank(void)
{
  unsigned char s = SEQ_SONG;
  SEQ_SONG = SEQ_CURRENT_SONG;
  SeqVoice_InitEntry();
  SEQ_SONG = s;
}

void SeqVoice_SetDefaultParams(void)
{
  ram_28a1 = 16;
  ram_289e = 15;
  ram_28a2 = SEQ_BLOCK_TOTAL;
  ram_ce8 = SEQ_BLOCK_POOL;
  ram_d30 = 0;
}

void Seq_HandleModeTransition(void)
{
  unsigned char a;
  if (SEQ_TRACK_MASK == 0) { SEQ_CHORD_FROM_SONG = 0; SEQ_RTMCFG &= ~0x08; }
  PLAY_TRANSPORT_STATE &= ~0x10;
  PLAY_TRANSPORT_STATE &= ~0x02;
  a = ACC_TRANSPORT_STATE;
  a &= ~0x10;
  a &= ~0x02;
  ACC_TRANSPORT_STATE = a;
  if (CURRENT_MODE == 19) SeqModeTransit_DemoPath();
  else if ((ram_28ac & 0x20) || (!(SEQ_TRANSPORT_STATE & 0x04) && !(a & 0x04))) SeqModeTransit_UpdateParts();
  ram_2838 = SEQ_TRACK_MASK;
}
