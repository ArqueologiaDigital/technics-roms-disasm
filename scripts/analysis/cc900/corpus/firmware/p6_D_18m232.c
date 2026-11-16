/* Phase 6, lane_p6 helper D, round 18, module 232 (v10 sequencer/bmdredit_routines.s), form a.
   - BmDrEdit_SetRowOffsetFromDelta after run 123: matched up to the melodic branch, where the ROM copies the
     difference into C before storing it and adds 3 there: the copy is written out.
   - New from poolmm_D, now that run 118 showed V4.23 writes conditional calls (`cal cc`) itself:
     BmDrEdit_ScanBackwardInit (snapshots the cursor cells, then walks the song bytes at 0xb0000 + 256 * (block - 1)
     + offset backward over up to (0x2774) bar marks, drawing each note block in range through a conditional
     call), BmDrEdit_AdjustViewAndInsert (a conditional call of CalcBeatMeasure, then the insert / navigate
     decision) and BmDrEdit_SetupAndWalkToNote (a char kept in QIZH: the ROM saves QIZ, pushw_erp 0xfa).
   Form b (p6_D_18m232b.c) varies the expressions noted there. */
/* cc900-module: BmDrEdit_AdjustScrollToView BmDrEdit_AdjustViewToPosition BmDrEdit_AdvanceStreamPos BmDrEdit_AlignDisplayGrid BmDrEdit_ClearAndScanToEnd BmDrEdit_CompareVelocity BmDrEdit_InitViewAndNavigate BmDrEdit_InsertNoteSequence BmDrEdit_LoadAndCheckNote BmDrEdit_RefreshDisplayState BmDrEdit_SaveEditState BmDrEdit_SetupCoordinates BmDrEdit_WalkTrackForward */   /* from scripts/analysis/cc900/module_calls.py v10 */

#define SEQ_BYTE (((unsigned char *)0xb0000)[((unsigned long)(ram_210a4 - 1) << 8) + ram_210a6])

extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void BmDrEdit_AdvanceStreamPos(void);
extern void BmDrEdit_RenderNoteBlock(void);
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
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_AdjustScrollToView(void);

extern unsigned char __near ram_2742;
extern unsigned char __near ram_27cc;
extern unsigned char __near NOTEEDIT_BASE_KEY;

extern unsigned int __near ram_27f6;
extern unsigned int __near ram_27f8;
extern unsigned int __near ram_27fa;
extern unsigned int __near ram_27fc;
extern unsigned int __near ram_27fe;
extern unsigned int __near ram_2800;
extern unsigned int __near ram_2802;
extern unsigned int __near ram_2804;
extern unsigned char __near ram_2806;
extern unsigned char __near ram_2822;
extern unsigned char __near ram_2824;
extern unsigned int __near ram_2766;
extern unsigned int __near ram_2768;
extern unsigned char __near ram_2774;
extern unsigned int ram_210a0;
extern unsigned int ram_210a2;
extern unsigned int ram_210a4;
extern unsigned int ram_210a6;
extern unsigned char ram_210a8;
extern unsigned char ram_210aa;

extern unsigned char __near ram_295c;
extern unsigned char __near ram_295f;
extern unsigned int __near ram_279a;
extern unsigned int __near ram_279c;
extern unsigned char __near ram_2786;
extern unsigned char __near ram_2788;
extern unsigned int __near ram_278c;
extern unsigned char __near ram_2962;

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

void BmDrEdit_ScanBackwardInit(void)
{
	unsigned int i;
	unsigned char c;

	ram_27f6 = ram_27fe;
	ram_27f8 = ram_2800;
	ram_27fa = ram_2802;
	ram_27fc = ram_2804;
	ram_210a0 = ram_27fe;
	ram_210a2 = ram_2800;
	ram_210a4 = ram_2802;
	ram_210a6 = ram_2804;
	ram_210a8 = ram_2822;
	ram_210aa = ram_2824;
	i = 0;
	while (i < ram_2774) {
		c = SEQ_BYTE;
		if (c == 0x82 || c == 0x84) break;
		if (c == 0x81) {
			i++;
			ram_27fe++;
		} else if ((c & 0xf0) == 0x90) {
			if (ram_2802 != ram_2766 || ram_2804 != ram_2768) {
				BmDrEdit_AdvanceStreamPos();
				ram_2800 = SEQ_BYTE;
				BmDrEdit_AdvanceStreamPos();
				c = SEQ_BYTE;
				ram_2806 = c;
				if (c >= ram_210a8 && c <= ram_210aa) BmDrEdit_RenderNoteBlock();
			}
		}
		do
			BmDrEdit_AdvanceStreamPos();
		while (!(SEQ_BYTE & 0x80));
	}
}

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
	ram_278c = w * 0x60 + v;
	BmDrEdit_ClearAndScanToEnd();
	ram_2962 = ram_2786;
	BmDrEdit_AdjustScrollToView();
}
