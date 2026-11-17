/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/bmdredit_routines_m232.c (2026-11-17-1-p6-r28-staged)
   sha256 0b93ede3495b41ccdb73e984e0ba35d46ef5478b4898537d7cb80c4e3b6b8a41 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
extern unsigned char __near ram_275a;
extern unsigned char __near ram_2940;
extern unsigned char __near ram_2943;
extern unsigned int __near ram_2780;
extern unsigned int __near ram_2782;
void BmDrEdit_AdjustViewAndInsert(void)
{
	unsigned int a, b;
	unsigned char f;

	if (ram_2940 & 0x80) return;
	BmDrEdit_SaveEditState();
	ram_2782 = ram_2780;
	BmDrEdit_AlignDisplayGrid();
	if (ram_2780 < ram_275a * 0x60) BmDrEdit_CalcBeatMeasure();
	if (!(ram_2943 & 1)) {
		BmDrEdit_LoadAndCheckNote();
		if ((SeqData_ReadNextByte() & 0xf0) == 0x90 && BmDrEdit_CompareVelocity() == 0) {
			BmDrEdit_SetupCoordinates(&a, &b);
			if (a - b <= ram_2780) goto init;
			if (ram_2943 & 2) {
				BmDrEdit_InsertNoteSequence();
				if (ram_2943 & 4) goto refresh;
				goto adjust;
			}
		}
	}
	BmDrEdit_WalkTrackForward();
	f = ram_2943;
	if (f & 0x10) goto adjust;
	if (f & 2) {
		BmDrEdit_InsertNoteSequence();
		if (!(ram_2943 & 4)) goto adjust;
refresh:
		BmDrEdit_RefreshDisplayState();
		return;
	}
	BmDrEdit_SetupCoordinates(&a, &b);
	b += ram_2780;
	if (a <= b) goto init;
adjust:
	BmDrEdit_AdjustViewToPosition();
	return;
init:
	BmDrEdit_InitViewAndNavigate();
}
