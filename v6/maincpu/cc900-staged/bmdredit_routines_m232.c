/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_AdjustScrollToView BmDrEdit_AdvanceStreamPos BmDrEdit_ClearAndScanToEnd BmDrEdit_CompareVelocity BmDrEdit_SetupCoordinates */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned char BmDrEdit_CompareVelocity(void);
extern void BmDrEdit_SetupCoordinates(unsigned int *, unsigned int *);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_AdjustScrollToView(void);
extern unsigned char __near ram_2943;
extern unsigned int __near ram_2780;
extern unsigned char __near ram_276c;
extern unsigned char __near ram_276e;
extern unsigned int __near ram_2772;
extern unsigned char __near ram_2946;
extern void BmDrEdit_SetupAndWalkToNote(void);

void BmDrEdit_SetupAndWalkToNote(void)
{
	unsigned int a, b;
	unsigned char v, w;
	unsigned int x;

	ram_2943 &= ~1;
	BmDrEdit_SetupCoordinates(&a, &b);
	a -= b;
	if (a != ram_2780) return;
	if ((SeqData_ReadNextByte() & 0xf0) != 0x90) return;
	if (BmDrEdit_CompareVelocity() != 0) return;
	ram_2943 |= 1;
	SeqData_AdvancePosition();
	SeqData_AdvancePosition();
	ram_276c = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_276e = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	v = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	w = SeqData_ReadNextByte();
	w &= 0x7f;
	v &= 0x7f;
	x = w;
	x *= 0x60;
	x += v;
	ram_2772 = x;
	BmDrEdit_ClearAndScanToEnd();
	ram_2946 = ram_276c;
	BmDrEdit_AdjustScrollToView();
}
