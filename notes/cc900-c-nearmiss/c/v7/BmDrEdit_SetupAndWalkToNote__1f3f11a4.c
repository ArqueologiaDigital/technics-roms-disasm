/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/bmdredit_routines_m232.c (2026-11-17-6-p6-r30-staged)
   sha256 1f3f11a4bda3bf2e812c108f44e01c6f7b76b9db95d4aaacbd0d9da6c20035c0 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned char BmDrEdit_CompareVelocity(void);
extern void BmDrEdit_SetupCoordinates(unsigned int *, unsigned int *);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_AdjustScrollToView(void);
extern unsigned char __near ram_295f;
extern unsigned int __near ram_279a;
extern unsigned char __near ram_2786;
extern unsigned char __near ram_2788;
extern unsigned int __near ram_278c;
extern unsigned char __near ram_2962;
void BmDrEdit_SetupAndWalkToNote(void)
{
	unsigned int a, b;
	unsigned char v, w;
	unsigned int x;

	ram_295f &= ~1;
	BmDrEdit_SetupCoordinates(&a, &b);
	a -= b;
	if (a != ram_279a) return;
	if ((SeqData_ReadNextByte() & 0xf0) != 0x90) return;
	if (BmDrEdit_CompareVelocity() != 0) return;
	ram_295f |= 1;
	SeqData_AdvancePosition();
	SeqData_AdvancePosition();
	ram_2786 = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_2788 = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	v = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	w = SeqData_ReadNextByte();
	w &= 0x7f;
	v &= 0x7f;
	x = w;
	x *= 0x60;
	x += v;
	ram_278c = x;
	BmDrEdit_ClearAndScanToEnd();
	ram_2962 = ram_2786;
	BmDrEdit_AdjustScrollToView();
}
