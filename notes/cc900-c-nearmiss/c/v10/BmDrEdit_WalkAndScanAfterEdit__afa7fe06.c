/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_4m232a.c (2026-11-19-29-p6-r46)
   sha256 afa7fe06b3a6cb414ce507f63dd6a05755c33a23cfe952a6bcb06cbaa8563112 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_295f;
extern unsigned int __near ram_275e;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned char BmDrEdit_CompareVelocity(void);
extern void BmDrEdit_SetupCoordinates(unsigned int *, unsigned int *);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_ReadEventAtPosition(void);
void BmDrEdit_WalkAndScanAfterEdit(void)
{
	unsigned int a, b;
	unsigned char c;

	ram_295f &= ~0x08;
	if (SeqData_ReadNextByte() == 0x81) {
		if (ram_275e == 0)
			goto notfound;
		ram_275e--;
		BmDrEdit_SetupCoordinates(&a, &b);
		if (a < b)
			goto notfound;
	}
	for (;;) {
		BmDrEdit_ClearAndScanToEnd();
		if (SEQ_ERROR_CODE != 0) {
			ram_295f |= 0x08;
			SEQ_ERROR_CODE = 0;
			return;
		}
		c = SeqData_ReadNextByte();
		if (c == 0x81) {
			if (ram_275e == 0)
				goto notfound;
			ram_275e--;
			BmDrEdit_SetupCoordinates(&a, &b);
			if (a < b)
				goto notfound;
			continue;
		}
		if ((c & 0xf0) != 0x90)
			continue;
		if (BmDrEdit_CompareVelocity() != 0)
			continue;
		BmDrEdit_ReadEventAtPosition();
		BmDrEdit_SetupCoordinates(&a, &b);
		if (a >= b)
			return;
		goto notfound;
	}
notfound:
	ram_295f |= 0x08;
}
