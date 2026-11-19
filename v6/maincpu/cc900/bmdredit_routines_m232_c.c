/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_CheckNoteAtPosition BmDrEdit_ClearAndScanToEnd BmDrEdit_CompareVelocity BmDrEdit_LoadAlternateState BmDrEdit_ReadEventAtPosition BmDrEdit_RestoreEditState BmDrEdit_SaveEditState BmDrEdit_SetupCoordinates BmDrEdit_WalkAndScanAfterEdit BmDrEdit_WalkTrackForward */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_2943;
extern unsigned int __near ram_2782;
extern unsigned char __near ram_2746;
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned char BmDrEdit_CompareVelocity(void);
extern void BmDrEdit_SetupCoordinates(unsigned int *, unsigned int *);
extern void BmDrEdit_LoadAlternateState(void);
extern void BmDrEdit_CheckNoteAtPosition(void);
extern void BmDrEdit_SaveEditState(void);
extern void BmDrEdit_WalkTrackForward(void);
extern void BmDrEdit_RestoreEditState(void);
extern void BmDrEdit_WalkAndScanAfterEdit(void);
extern void BmDrEdit_ScanAfterModify(void);

void BmDrEdit_ScanAfterModify(void)
{
	unsigned int a, b;
	unsigned char c;

	ram_2943 &= ~0x08;
	if (ram_2782 == 0) {
		c = SeqData_ReadNextByte();
		if (c == 0x81)
			goto notfound;
		if ((c & 0xf0) != 0x90) {
			BmDrEdit_WalkAndScanAfterEdit();
			return;
		}
		if (BmDrEdit_CompareVelocity() != 0)
			goto notfound;
		if (ram_2746 != 0)
			goto notfound;
	}
	BmDrEdit_LoadAlternateState();
	BmDrEdit_CheckNoteAtPosition();
	do {
		BmDrEdit_SaveEditState();
		BmDrEdit_WalkTrackForward();
		BmDrEdit_SetupCoordinates(&a, &b);
	} while (a - b < ram_2782);
	BmDrEdit_RestoreEditState();
	return;
notfound:
	ram_2943 |= 0x08;
}
