/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_19m232.c (2026-11-17-2-p6-r29)
   sha256 a7836de961c73891297f92ada05cb01a0fe1e3d2f2269d88fa8de82468e92006 (tar-sha256); compiled at -O3 -Xr */
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
	ram_278c = (unsigned int)w * 0x60 + (unsigned int)v;
	BmDrEdit_ClearAndScanToEnd();
	ram_2962 = ram_2786;
	BmDrEdit_AdjustScrollToView();
}
