/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_D_16m232b.c (2026-11-16-118-p6-r23)
   sha256 17133d587e147c5c85f2ee9c7938b59449a0c595a64f0306a4af8a37a7dd1332 (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, lane_p6 helper D, round 16, module 232 (v10 sequencer/bmdredit_routines.s), form b (see p6_D_16m232.c):
   PrepareSecondaryNoteDisplay with the last byte in a second int local; InsertNotesFromSlots with a flat index
   1 + 3i; CheckTempoData with the title tested directly and the clear path at the end; PrepareAndInsertNote with the
   remainders cast to char first; AdjustScrollToView stepping the key cell itself; InsertMultiSongSteps with the
   channel in a local; SetRowOffsetFromDelta with the +3 applied to the local.  ReadSeqData_StoreParams as form a. */
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
extern unsigned char __near ram_2746[];

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
	unsigned int v, w;

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
	if ((SeqData_ReadNextByte() & 0xf0) != 0x90) goto out;
	SeqData_AdvancePosition();
	ram_2816 = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_281c = SeqData_ReadNextByte();
	BmDrEdit_SetupScrollRegion(&lo, &hi);
	if (ram_281c < lo) goto out;
	if (ram_281c > hi) goto out;
	ram_2826 = lo;
	ram_2828 = hi;
	SeqData_AdvancePosition();
	SeqData_AdvancePosition();
	v = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	w = SeqData_ReadNextByte();
	v &= 0x7f;
	w &= 0x7f;
	ram_2820 = w * 0x60 + v;
	NoteEditSy_SendWidgetCmdC();
out:
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
		if (ram_2746[1 + i * 3] != 0) {
			ram_2960 = ram_2746[1 + i * 3];
			ram_2961 = ram_2746[2 + i * 3];
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
	unsigned char c;

	if (TempoRingBuf_CheckEmpty() == 0) return;
	if (ACTIVE_TITLE != 0x95 && ACTIVE_TITLE != 0x98) return;
	if (ram_295c & 0x80) return;
	if (SEQ_FREE_BLOCKS == 0) goto clear;
	while (TempoRingBuf_CheckEmpty() != 0) {
		c = TempoRingBuf_ReadByte();
		if ((c & 0x80) && (c & 0xf0) == 0x90) {
			TempoRingBuf_ReadByte();
			ram_2960 = TempoRingBuf_ReadByte();
			ram_2961 = TempoRingBuf_ReadByte();
			TempoRingBuf_ReadByte();
			if (ram_2961 != 0)
				BmDrEdit_AllocateNoteSlot();
			else if (BmDrEdit_FindNoteInSlots() != 0xff && BmDrEdit_CheckSlotsAvailable() == 0) {
				ram_295f &= ~1;
				ram_2962 = ram_2960;
				BmDrEdit_AdjustScrollToView();
				BmDrEdit_InsertNotesFromSlots();
				BmDrEdit_CountMeasuresInit();
				if (SEQ_ERROR_CODE != 0) goto clear;
				BmDrEdit_ClearAllSlotsAlt();
				BmDrEdit_RefreshAfterInsert();
			}
		}
	}
	return;
clear:
	ram_295f &= ~1;
	BmDrEdit_RefreshDisplayState();
}

void BmDrEdit_PrepareAndInsertNote(void)
{
	BmDrEdit_WalkToGridPosition();
	ram_2967 = 144;
	ram_2968 = (unsigned char)(ram_279a % 96);
	ram_2969 = ram_2960;
	ram_296a = ram_2961;
	ram_296b = (unsigned char)(ram_278e % 96) & 0x7f;
	ram_296c = (unsigned char)(ram_278e / 96) & 0x7f;
	BmDrEdit_SaveSongPosition();
	BmDrEdit_ApplyVelocityChange((unsigned char)(BMDREDIT_CHANNEL + 1), (unsigned char *)0x2967, 6);
}

void BmDrEdit_AdjustScrollToView(void)
{
	unsigned char lo, hi;
	unsigned char c;

	if (ram_2742 & 1) return;
	ram_27ca = NOTEEDIT_BASE_KEY;
	for (;;) {
		BmDrEdit_SetupScrollRegion(&lo, &hi);
		c = ram_2962;
		if (c < lo) {
			if (NOTEEDIT_BASE_KEY == 0) return;
			NOTEEDIT_BASE_KEY--;
			continue;
		}
		if (c <= hi) break;
		if (NOTEEDIT_BASE_KEY >= 9) return;
		NOTEEDIT_BASE_KEY++;
	}
	if (ram_27ca != NOTEEDIT_BASE_KEY) NoteEditSy_UpdateChordDisplay();
}

void BmDrEdit_InsertMultiSongSteps(void)
{
	unsigned int a, b;
	unsigned int ch;
	unsigned char r;

	ram_ce3 = ram_2772;
	ram_275e = ram_2772;
	for (;;) {
		ch = BmDrEdit_CheckAndSelectChannel();
		r = BmDrEdit_ProcessVoiceSection(ch, &a, &b);
		if (ram_2744 == a) return;
		if (b != 0) r -= (unsigned char)b;
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
	if (NOTEEDIT_BASE_KEY != 0) return;
	d += 3;
	ram_27cc = d;
}
