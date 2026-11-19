/* lane_p6 helper N, round 2, form a: module 232 (sequencer/bmdredit_routines.s).
   BmDrEdit_ScanAfterModify / BmDrEdit_WalkAndScanAfterEdit: after a note edit, walk the track forward to the note
   at the edit position (the {a, b} pair of BmDrEdit_SetupCoordinates, as in the built BmDrEdit_AdjustViewAndInsert),
   setting bit 3 of 0x295f when it is not found.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_CheckNoteAtPosition BmDrEdit_ClearAndScanToEnd BmDrEdit_CompareVelocity BmDrEdit_LoadAlternateState BmDrEdit_ReadEventAtPosition BmDrEdit_RestoreEditState BmDrEdit_SaveEditState BmDrEdit_SetupCoordinates BmDrEdit_WalkAndScanAfterEdit BmDrEdit_WalkTrackForward */

extern unsigned char __near ram_295f;
extern unsigned int __near ram_279c;
extern unsigned int __near ram_275e;
extern unsigned char __near ram_2760;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned char BmDrEdit_CompareVelocity(void);
extern void BmDrEdit_SetupCoordinates(unsigned int *, unsigned int *);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_ReadEventAtPosition(void);
extern void BmDrEdit_LoadAlternateState(void);
extern void BmDrEdit_CheckNoteAtPosition(void);
extern void BmDrEdit_SaveEditState(void);
extern void BmDrEdit_WalkTrackForward(void);
extern void BmDrEdit_RestoreEditState(void);
extern void BmDrEdit_WalkAndScanAfterEdit(void);

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
			if (a >= b)
				continue;
			goto notfound;
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

void BmDrEdit_ScanAfterModify(void)
{
	unsigned int a, b;
	unsigned char c;

	ram_295f &= ~0x08;
	if (ram_279c == 0) {
		c = SeqData_ReadNextByte();
		if (c == 0x81)
			goto notfound;
		if ((c & 0xf0) != 0x90) {
			BmDrEdit_WalkAndScanAfterEdit();
			return;
		}
		if (BmDrEdit_CompareVelocity() != 0)
			goto notfound;
		if (ram_2760 != 0)
			goto notfound;
	}
	BmDrEdit_LoadAlternateState();
	BmDrEdit_CheckNoteAtPosition();
	do {
		BmDrEdit_SaveEditState();
		BmDrEdit_WalkTrackForward();
		BmDrEdit_SetupCoordinates(&a, &b);
	} while (a - b < ram_279c);
	BmDrEdit_RestoreEditState();
	return;
notfound:
	ram_295f |= 0x08;
}
