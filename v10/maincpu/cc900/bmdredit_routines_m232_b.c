/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_AdjustScrollToView BmDrEdit_AdjustViewToPosition BmDrEdit_AdvanceStreamPos BmDrEdit_AlignDisplayGrid BmDrEdit_ClearAndScanToEnd BmDrEdit_CompareVelocity BmDrEdit_InitViewAndNavigate BmDrEdit_InsertNoteSequence BmDrEdit_LoadAndCheckNote BmDrEdit_RefreshDisplayState BmDrEdit_SaveEditState BmDrEdit_SetupCoordinates BmDrEdit_WalkTrackForward */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void BmDrEdit_AdjustViewAndInsert(void);
extern unsigned char __near ram_2742;
extern unsigned char __near ram_27cc;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern void BmDrEdit_SetRowOffsetFromDelta(unsigned char a, unsigned char c);

void BmDrEdit_AdjustViewAndInsert(void)
{
	unsigned int a, b;
	unsigned char f;

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
	f = ram_295f;
	if (f & 0x10) goto adjust;
	if (f & 2) {
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

void BmDrEdit_SetRowOffsetFromDelta(unsigned char a, unsigned char c)
{
	a -= c;
	if (ram_2742 & 1) {
		ram_27cc = 11 - a;
		return;
	}
	c = a;
	ram_27cc = a;
	if (NOTEEDIT_BASE_KEY != 0) return;
	c += 3;
	ram_27cc = c;
}

#define TT_SQNOTECYCP 0x96
extern unsigned char __near ram_2746;
extern void UI_ChangeTitleByIndex(unsigned int);
extern void BmDrEdit_PostModeChange96(void);

void BmDrEdit_PostModeChange96(void)
{
  if (ram_2746 & 0x80) return;
  if (ram_295c & 0x80) return;
  UI_ChangeTitleByIndex(TT_SQNOTECYCP);
}
