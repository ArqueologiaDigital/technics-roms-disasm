/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqModeTransit_DemoPath SeqModeTransit_UpdateParts SeqPart_InitClear SeqPart_UndoAllocOnError */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near SEQ_FREE_LIST_HEAD;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned int __near ram_29ca;
extern unsigned int __near ram_29cc;
extern void SeqLoad_RestoreFreeBlockList(void);
extern unsigned char __near ram_2587;
extern unsigned int __near ram_258e;
extern unsigned int __near ram_2590;
extern unsigned char __near ram_2592;
extern unsigned char __near ram_28a6;
extern void SeqScan_UpdateBestPositionA(void);
extern void SeqScan_UpdateBestPositionB(void);

void SeqLoad_RestoreFreeBlockList(void)
{
  SEQ_FREE_LIST_HEAD = ram_29ca;
  SEQ_FREE_BLOCKS = ram_29cc;
}

void SeqScan_UpdateBestPositionA(void)
{
  unsigned int b = ram_258e, w = ram_2590;
  if (w > b) return;
  if (w == b && ram_2592 > ram_2587) return;
  ram_2590 = b;
  ram_2592 = ram_2587;
  ram_28a6 |= 0x01;
}

void SeqScan_UpdateBestPositionB(void)
{
  unsigned int b = ram_258e, w = ram_2590;
  if (w > b) return;
  if (w == b && ram_2592 > ram_2587) return;
  ram_2590 = b;
  ram_2592 = ram_2587;
  ram_28a6 &= ~0x01;
}
