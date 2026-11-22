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
extern unsigned int __near ram_275e;
extern unsigned char __near ram_2760;
extern unsigned int __near ram_2762;
extern unsigned char __near ram_2764;
extern unsigned int __near ram_2766;
extern unsigned int __near ram_2768;
extern void BmDrEdit_RestoreEditState(void);
extern void BmDrEdit_SaveEditState(void);

void BmDrEdit_RestoreEditState(void)
{
	ram_275e = ram_2762;
	ram_2760 = ram_2764;
	SEQ_DATA_BLOCK = ram_2766;
	SEQ_DATA_OFFSET = ram_2768;
}

void BmDrEdit_SaveEditState(void)
{
	ram_2762 = ram_275e;
	ram_2764 = ram_2760;
	ram_2766 = SEQ_DATA_BLOCK;
	ram_2768 = SEQ_DATA_OFFSET;
}
