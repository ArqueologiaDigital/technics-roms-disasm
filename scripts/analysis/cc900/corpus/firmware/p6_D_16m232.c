/* Phase 6, lane_p6 helper D, round 16, module 232 (v10 sequencer/bmdredit_routines.s), form a.
   ReadSeqData_StoreParams after run 107: everything matched up to the error path, where the ROM's first error test
   jumps straight to the RefreshDisplayState call that the second test falls into; here a goto into the second if's
   body gives that one call (inside an if, so V4.23 keeps `call; ret`).
   New from poolmm_D: BmDrEdit_PrepareSecondaryNoteDisplay (an int local in IZ: pushw iz), InsertNotesFromSlots,
   CheckTempoData (the ring buffer loop with its test copied to the entry), PrepareAndInsertNote (remainders by 96),
   AdjustScrollToView, InsertMultiSongSteps and SetRowOffsetFromDelta.  Form b (p6_D_16m232b.c) varies the
   expression shapes noted there.  TT_SQDRMEDT 0x98, TT_SQNOTEEDT 0x95. */
/* cc900-module: BmDrEdit_AdjustScrollToView BmDrEdit_AllocateNoteSlot BmDrEdit_ApplyVelocityChange BmDrEdit_CalcBeatFromGridPos BmDrEdit_CheckAndSelectChannel BmDrEdit_CheckSlotsAvailable BmDrEdit_ClearAllSlotsAlt BmDrEdit_ClearAndScanToEnd BmDrEdit_CopyEventDataBetweenParts BmDrEdit_CountMeasuresInit BmDrEdit_FindNoteInSlots BmDrEdit_InsertNotesFromSlots BmDrEdit_InsertStepEntry BmDrEdit_PrepareAndInsertNote BmDrEdit_ProcessVoiceSection BmDrEdit_RefreshAfterInsert BmDrEdit_RefreshDisplayState BmDrEdit_RestoreEditState BmDrEdit_SaveEditState BmDrEdit_SaveSongPosition BmDrEdit_SeekForwardToEvent BmDrEdit_SetupScrollRegion BmDrEdit_WalkEventsOrSetError BmDrEdit_WalkToGridPosition EditChannel_LoadVoiceParams */   /* from scripts/analysis/cc900/module_calls.py v10 */

extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern int TempoRingBuf_CheckEmpty(void);
extern unsigned char TempoRingBuf_ReadByte(void);
extern void NoteEditSy_SendWidgetCmdC(void);
extern void NoteEditSy_UpdateChordDisplay(void);

extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_CopyEventDataBetweenParts(unsigned int);
extern void BmDrEdit_SeekForwardToEvent(void);
extern void BmDrEdit_SaveSongPosition(void);
extern void BmDrEdit_ApplyVelocityChange(unsigned int, unsigned char *, unsigned int);
extern void BmDrEdit_CountMeasuresInit(void);
extern void BmDrEdit_RefreshDisplayState(void);
extern void BmDrEdit_SaveEditState(void);
extern void BmDrEdit_RestoreEditState(void);
extern void BmDrEdit_SetupScrollRegion(unsigned char *, unsigned char *);
extern void BmDrEdit_WalkEventsOrSetError(void);
extern void BmDrEdit_PrepareAndInsertNote(void);
extern void BmDrEdit_CalcBeatFromGridPos(void);
extern void BmDrEdit_AllocateNoteSlot(void);
extern int BmDrEdit_FindNoteInSlots(void);
extern int BmDrEdit_CheckSlotsAvailable(void);
extern void BmDrEdit_AdjustScrollToView(void);
extern void BmDrEdit_InsertNotesFromSlots(void);
extern void BmDrEdit_ClearAllSlotsAlt(void);
extern void BmDrEdit_RefreshAfterInsert(void);
extern void BmDrEdit_WalkToGridPosition(void);
extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern unsigned char BmDrEdit_ProcessVoiceSection(unsigned int, unsigned int *, unsigned int *);
extern void EditChannel_LoadVoiceParams(void);
extern void BmDrEdit_InsertStepEntry(void);

extern unsigned char __near ram_2969;
extern unsigned char __near ram_296a;
extern unsigned char __near ram_296b;
extern unsigned char __near ram_296c;
extern unsigned char __near ram_2967;
extern unsigned char __near ram_2968;
extern unsigned char __near ram_2784;
extern unsigned char __near BMDREDIT_CHANNEL;
extern unsigned char __near SEQ_ERROR_CODE;

extern unsigned char __near ram_295f;
extern unsigned int __near ram_280c;
extern unsigned int __near ram_276a;
extern unsigned int __near ram_280e;
extern unsigned char __near ram_276c;
extern unsigned int __near ram_2810;
extern unsigned int __near ram_276e;
extern unsigned int __near ram_2812;
extern unsigned char __near ram_2770;
extern unsigned int __near ram_2814;
extern unsigned int __near ram_275e;
extern unsigned int __near ram_2816;
extern unsigned char __near ram_2760;
extern unsigned int __near ram_2818;
extern unsigned int __near SEQ_DATA_BLOCK;
extern unsigned int __near ram_281a;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned char __near ram_281c;
extern unsigned char __near ram_2826;
extern unsigned char __near ram_2828;
extern unsigned int __near ram_2820;

extern unsigned char __near ram_2742;
extern unsigned char __near ram_2960;
extern unsigned char __near ram_2961;
extern unsigned char __near ram_2786;
extern unsigned char __near ram_2748;
extern unsigned char __near ram_2746[][3];

extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near ram_295c;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned char __near ram_2962;

extern unsigned int __near ram_279a;
extern unsigned int __near ram_278e;

extern unsigned char __near ram_27ca;
extern unsigned char __near NOTEEDIT_BASE_KEY;

extern unsigned int __near ram_ce3;
extern unsigned int __near ram_2772;
extern unsigned int __near ram_2744;

extern unsigned char __near ram_27cc;

void ReadSeqData_StoreParams(void)
{
	SeqData_AdvancePosition();
	SeqData_AdvancePosition();
	ram_2969 = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_296a = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_296b = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_296c = SeqData_ReadNextByte();
	BmDrEdit_ClearAndScanToEnd();
	BmDrEdit_CopyEventDataBetweenParts((unsigned char)(BMDREDIT_CHANNEL + 1));
	BmDrEdit_SeekForwardToEvent();
	if (SEQ_ERROR_CODE != 0) goto err;
	ram_2967 = 144;
	ram_2968 = ram_2784;
	BmDrEdit_SaveSongPosition();
	BmDrEdit_ApplyVelocityChange((unsigned char)(BMDREDIT_CHANNEL + 1), (unsigned char *)0x2967, 6);
	BmDrEdit_CountMeasuresInit();
	if (SEQ_ERROR_CODE != 0) {
err:
		BmDrEdit_RefreshDisplayState();
	}
}

void BmDrEdit_PrepareSecondaryNoteDisplay(void)
{
	unsigned char lo, hi;
	unsigned int v;

	if (!(ram_295f & 1)) return;
	BmDrEdit_SaveEditState();
	ram_280c = ram_276a;
	ram_280e = ram_276c;
	ram_2810 = ram_276e;
	ram_2812 = ram_2770;
	ram_2814 = ram_275e;
	ram_2816 = ram_2760;
	ram_2818 = SEQ_DATA_BLOCK;
	ram_281a = SEQ_DATA_OFFSET;
	if ((SeqData_ReadNextByte() & 0xf0) == 0x90) {
		SeqData_AdvancePosition();
		ram_2816 = SeqData_ReadNextByte();
		SeqData_AdvancePosition();
		ram_281c = SeqData_ReadNextByte();
		BmDrEdit_SetupScrollRegion(&lo, &hi);
		if (ram_281c >= lo && ram_281c <= hi) {
			ram_2826 = lo;
			ram_2828 = hi;
			SeqData_AdvancePosition();
			SeqData_AdvancePosition();
			v = SeqData_ReadNextByte();
			SeqData_AdvancePosition();
			ram_2820 = (SeqData_ReadNextByte() & 0x7f) * 0x60 + (v & 0x7f);
			NoteEditSy_SendWidgetCmdC();
		}
	}
	BmDrEdit_RestoreEditState();
}

void BmDrEdit_InsertNotesFromSlots(void)
{
	unsigned int i;

	if (ram_2742 & 1) {
		ram_2960 = ram_2786;
		ram_2961 = ram_2748;
		BmDrEdit_WalkEventsOrSetError();
		return;
	}
	for (i = 0; i < 8; i++) {
		if (ram_2746[i][1] != 0) {
			ram_2960 = ram_2746[i][1];
			ram_2961 = ram_2746[i][2];
			BmDrEdit_PrepareAndInsertNote();
			if (SEQ_ERROR_CODE != 0) {
				BmDrEdit_RefreshDisplayState();
				return;
			}
			BmDrEdit_CalcBeatFromGridPos();
		}
	}
}

void BmDrEdit_CheckTempoData(void)
{
	unsigned char t, c;

	if (TempoRingBuf_CheckEmpty() == 0) return;
	t = ACTIVE_TITLE;
	if (t != 0x95 && t != 0x98) return;
	if (ram_295c & 0x80) return;
	if (SEQ_FREE_BLOCKS == 0) goto clear;
	while (TempoRingBuf_CheckEmpty() != 0) {
		c = TempoRingBuf_ReadByte();
		if (!(c & 0x80)) continue;
		if ((c & 0xf0) != 0x90) continue;
		TempoRingBuf_ReadByte();
		ram_2960 = TempoRingBuf_ReadByte();
		ram_2961 = TempoRingBuf_ReadByte();
		TempoRingBuf_ReadByte();
		if (ram_2961 != 0) {
			BmDrEdit_AllocateNoteSlot();
			continue;
		}
		if (BmDrEdit_FindNoteInSlots() == 0xff) continue;
		if (BmDrEdit_CheckSlotsAvailable() != 0) continue;
		ram_295f &= ~1;
		ram_2962 = ram_2960;
		BmDrEdit_AdjustScrollToView();
		BmDrEdit_InsertNotesFromSlots();
		BmDrEdit_CountMeasuresInit();
		if (SEQ_ERROR_CODE != 0) {
clear:
			ram_295f &= ~1;
			BmDrEdit_RefreshDisplayState();
			return;
		}
		BmDrEdit_ClearAllSlotsAlt();
		BmDrEdit_RefreshAfterInsert();
	}
}

void BmDrEdit_PrepareAndInsertNote(void)
{
	BmDrEdit_WalkToGridPosition();
	ram_2967 = 144;
	ram_2968 = ram_279a % 96;
	ram_2969 = ram_2960;
	ram_296a = ram_2961;
	ram_296b = (ram_278e % 96) & 0x7f;
	ram_296c = (ram_278e / 96) & 0x7f;
	BmDrEdit_SaveSongPosition();
	BmDrEdit_ApplyVelocityChange((unsigned char)(BMDREDIT_CHANNEL + 1), (unsigned char *)0x2967, 6);
}

void BmDrEdit_AdjustScrollToView(void)
{
	unsigned char lo, hi;
	unsigned char c, k;

	if (ram_2742 & 1) return;
	ram_27ca = NOTEEDIT_BASE_KEY;
	for (;;) {
		BmDrEdit_SetupScrollRegion(&lo, &hi);
		c = ram_2962;
		k = NOTEEDIT_BASE_KEY;
		if (c < lo) {
			if (k == 0) return;
			NOTEEDIT_BASE_KEY = k - 1;
		} else if (c > hi) {
			if (k >= 9) return;
			NOTEEDIT_BASE_KEY = k + 1;
		} else
			break;
	}
	if (ram_27ca != NOTEEDIT_BASE_KEY) NoteEditSy_UpdateChordDisplay();
}

void BmDrEdit_InsertMultiSongSteps(void)
{
	unsigned int a, b;
	unsigned char r;

	ram_ce3 = ram_2772;
	ram_275e = ram_2772;
	for (;;) {
		r = BmDrEdit_ProcessVoiceSection(BmDrEdit_CheckAndSelectChannel(), &a, &b);
		if (ram_2744 == a) return;
		if (b != 0) r -= b;
		ram_2772 = r;
		do {
			EditChannel_LoadVoiceParams();
			BmDrEdit_InsertStepEntry();
			if (SEQ_ERROR_CODE != 0) return;
			ram_275e++;
		} while (--ram_2772 != 0);
		ram_ce3 = ram_275e;
	}
}

void BmDrEdit_SetRowOffsetFromDelta(unsigned int a, unsigned int c)
{
	unsigned char d;

	d = a - c;
	if (ram_2742 & 1) {
		ram_27cc = 11 - d;
		return;
	}
	ram_27cc = d;
	if (NOTEEDIT_BASE_KEY == 0) ram_27cc = d + 3;
}
