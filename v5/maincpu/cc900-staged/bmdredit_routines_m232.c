/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_2744;
extern unsigned char __near ram_2746;
extern unsigned int __near ram_2748;
extern unsigned char __near ram_274a;
extern unsigned int __near ram_274c;
extern unsigned int __near ram_274e;
extern void BmDrEdit_RestoreEditState(void);
extern void BmDrEdit_SaveEditState(void);

void BmDrEdit_RestoreEditState(void)
{
	ram_2744 = ram_2748;
	ram_2746 = ram_274a;
	SEQ_DATA_BLOCK = ram_274c;
	SEQ_DATA_OFFSET = ram_274e;
}

void BmDrEdit_SaveEditState(void)
{
	ram_2748 = ram_2744;
	ram_274a = ram_2746;
	ram_274c = SEQ_DATA_BLOCK;
	ram_274e = SEQ_DATA_OFFSET;
}
