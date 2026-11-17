/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_18m232b.c (2026-11-16-128-p6-r27)
   sha256 e13a9bfc20e710c5df7360c10e306da34ce0c598c029e5e76b00a83eeb896b85 (tar-sha256); compiled at -Xr */
extern unsigned char SeqData_ReadNextByte(void);
extern void BmDrEdit_SaveEditState(void);
extern void BmDrEdit_AlignDisplayGrid(void);
extern void BmDrEdit_CalcBeatMeasure(void);
extern void BmDrEdit_LoadAndCheckNote(void);
extern unsigned char BmDrEdit_CompareVelocity(void);
extern void BmDrEdit_SetupCoordinates(unsigned int *, unsigned int *);
extern void BmDrEdit_InsertNoteSequence(void);
extern void BmDrEdit_WalkTrackForward(void);
extern void BmDrEdit_RefreshDisplayState(void);
extern void BmDrEdit_AdjustViewToPosition(void);
extern void BmDrEdit_InitViewAndNavigate(void);
extern unsigned char __near ram_2774;
extern unsigned char __near ram_295c;
extern unsigned char __near ram_295f;
extern unsigned int __near ram_279a;
extern unsigned int __near ram_279c;
void BmDrEdit_AdjustViewAndInsert(void)
{
	unsigned int a, b;

	if (ram_295c & 0x80) return;
	BmDrEdit_SaveEditState();
	ram_279c = ram_279a;
	BmDrEdit_AlignDisplayGrid();
	if (ram_279a < ram_2774 * 0x60) BmDrEdit_CalcBeatMeasure();
	if (!(ram_295f & 1)) {
		BmDrEdit_LoadAndCheckNote();
		if ((SeqData_ReadNextByte() & 0xf0) == 0x90 && BmDrEdit_CompareVelocity() == 0) {
			BmDrEdit_SetupCoordinates(&a, &b);
			if (a - b <= ram_279a) goto init;
			if (ram_295f & 2) {
				BmDrEdit_InsertNoteSequence();
				if (ram_295f & 4) goto refresh;
				goto adjust;
			}
		}
	}
	BmDrEdit_WalkTrackForward();
	if (ram_295f & 0x10) goto adjust;
	if (ram_295f & 2) {
		BmDrEdit_InsertNoteSequence();
		if (!(ram_295f & 4)) goto adjust;
refresh:
		BmDrEdit_RefreshDisplayState();
		return;
	}
	BmDrEdit_SetupCoordinates(&a, &b);
	b += ram_279a;
	if (a <= b) goto init;
adjust:
	BmDrEdit_AdjustViewToPosition();
	return;
init:
	BmDrEdit_InitViewAndNavigate();
}
