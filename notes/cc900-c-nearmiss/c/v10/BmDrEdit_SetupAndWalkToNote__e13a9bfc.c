/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_18m232b.c (2026-11-16-128-p6-r27)
   sha256 e13a9bfc20e710c5df7360c10e306da34ce0c598c029e5e76b00a83eeb896b85 (tar-sha256); compiled at -O3 -Xr */
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
	ram_278c = (w & 0x7f) * 0x60 + (v & 0x7f);
	BmDrEdit_ClearAndScanToEnd();
	ram_2962 = ram_2786;
	BmDrEdit_AdjustScrollToView();
}
