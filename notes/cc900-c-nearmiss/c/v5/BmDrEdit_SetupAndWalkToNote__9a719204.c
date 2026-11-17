/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/bmdredit_routines_m232.c (2026-11-17-6-p6-r30-staged)
   sha256 9a719204517c257f6ced84ac249e00bd344630a4905f1dfc7339931722786779 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
