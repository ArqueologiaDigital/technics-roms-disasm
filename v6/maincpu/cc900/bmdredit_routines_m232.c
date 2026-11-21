/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_CalcSongPosition */   /* staged module names, repair_module_lines.py */

extern unsigned char SeqData_ReadNextByte(void);
extern unsigned int PartCtrl_ReadWord_Off1(unsigned int);
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near SEQ_DATA_OFFSET;
extern unsigned int __near SEQ_DATA_BLOCK;
extern void SeqData_SetErrorCode(unsigned int);
extern unsigned int PartCtrl_ReadWord(unsigned int);
extern unsigned int __near ram_2758;
extern void SeqData_SkipToNextEvent(void);

void BmDrEdit_ClearAndScanToEnd(void)
{
	unsigned int o, b;

	SEQ_ERROR_CODE = 0;
	do {
		o = SEQ_DATA_OFFSET;
		if (o > 5) {
			SEQ_DATA_OFFSET = o - 1;
		} else {
			b = PartCtrl_ReadWord_Off1(SEQ_DATA_BLOCK);
			if (b == 0) {
				SEQ_ERROR_CODE = 255;
				return;
			}
			SEQ_DATA_BLOCK = b;
			SEQ_DATA_OFFSET = 255;
		}
	} while (!(SeqData_ReadNextByte() & 0x80));
}

/* cc900-name: BmDrEdit_DecrValidateCounter=BmDrEdit_DecrementAndValidateCounter (36 characters) */
int BmDrEdit_DecrValidateCounter(unsigned int *blk, unsigned int *off)
{
	(*off)--;
	if (*off >= 5) return 0;
	*blk = PartCtrl_ReadWord_Off1(*blk);
	if (*blk > 0x4d8) {
		SeqData_SetErrorCode(0xa0);
		return -1;
	}
	*off = 0xff;
	return 0;
}

/* cc900-name: PartCtrl_ReadWordWithBoundsChk=PartCtrl_ReadWordWithBoundsCheck (32 characters) */
int PartCtrl_ReadWordWithBoundsChk(unsigned int *blk, unsigned int *off)
{
	(*off)++;
	if (*off <= 0xff) return 0;
	*blk = PartCtrl_ReadWord(*blk);
	if (*blk > 0x4d8) {
		SeqData_SetErrorCode(0xa1);
		return -1;
	}
	*off = 5;
	return 0;
}

void BmDrEdit_CountMeasuresAndValidate(void)
{
	unsigned char c;

	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xd1);
	ram_2758 = 0;
	for (;;) {
		c = SeqData_ReadNextByte();
		if (c == 0x82 || c == 0x84) break;
		if (c == 0x81) ram_2758++;
		SeqData_SkipToNextEvent();
	}
	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xce);
}

extern unsigned char __near ram_25be;
extern unsigned char __near ram_276a;
extern unsigned char __near ram_278a[];
extern unsigned int __near ram_2780;
extern unsigned int __near ram_2768;
extern void BmDrEdit_CalcSongPosition(void);
void BmDrEdit_CalcBeatMeasure(void);
extern void BmDrEdit_CalcSongPosition(void);

void BmDrEdit_CalcSongPosition(void);

void BmDrEdit_CalcBeatMeasure(void)
{
	unsigned int n, i;
	unsigned char *t;

	n = ram_2780 / 96;
	ram_25be = 0;
	ram_2758 = n;
	if (n != 0) {
		i = 1;
		ram_25be = 1;
		t = ram_278a;
		for (;;) {
			if (t[i] != 0) ram_25be = 0;
			i++;
			if ((ram_2758 = ram_2758 - 1) == 0) break;
			ram_25be++;
		}
	}
	ram_2768 = ram_25be;
	ram_276a = ram_2780 % 96;
	BmDrEdit_CalcSongPosition();
}

/* cc900-module: BmDrEdit_ApplyVelocityChange BmDrEdit_CheckAndSelectChannel BmDrEdit_ClearAndScanToEnd BmDrEdit_CopyEventDataBetweenParts BmDrEdit_CountMeasuresInit BmDrEdit_InitCommon BmDrEdit_RefreshDisplayState BmDrEdit_SaveSongPosition BmDrEdit_SeekForwardToEvent BmDrEdit_SyncChannelAndGetPos BmDrEdit_ValidateAndProcessVoice NoteEditSy_ScanAndSortEntries */
extern unsigned char __near ram_2728;
extern void BmDrEdit_InitCommon(void);
extern unsigned int __near ram_2778;
extern unsigned int __near ram_277a;
extern unsigned int __near ram_2774;
extern unsigned int __near ram_2776;
extern unsigned char __near ram_275a;
extern unsigned char __near ram_2788;
extern void BmDrEdit_InitMelodicMode(void);
extern void NoteEditSy_ScanAndSortEntries(void);
extern unsigned char *__cdecl Malloc(unsigned int);
typedef unsigned char *ucp;
extern ucp __near ram_1d4c;
extern ucp __near ram_1d50;
extern unsigned int __near ram_277c;
extern void BmDrEdit_InitDrumMode(void);
extern unsigned int __near ram_2744;
extern unsigned int __near ram_2750;
extern unsigned char __near ram_2746;
extern unsigned char __near ram_2752;
extern unsigned int __near ram_2754;
extern unsigned char __near ram_2756;
extern void BmDrEdit_LoadAlternateState(void);
extern unsigned int __near ram_27ee;
extern unsigned int __near ram_27f0;
extern unsigned int __near ram_27a0;
extern unsigned int __near ram_27a2;
extern unsigned char __near ram_27ec;
extern unsigned int __near ram_27a4;
extern unsigned int __near ram_27a6;
extern unsigned int BmDrEdit_RenderVertical_Table[], BmDrEdit_RenderHorizontal_Table[];
extern void BmDrEdit_RenderHorizontal(void);
extern void BmDrEdit_RenderVertical(void);
extern unsigned int BmDrEdit_SyncChannelAndGetPos(void);
extern void BmDrEdit_SelectChannelAndLoadPos(void);
extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern void BmDrEdit_ValidateAndProcessVoice(unsigned int, unsigned int, unsigned int *);
extern unsigned int __near ram_2863;
extern unsigned int __near ram_272a;
extern unsigned char __near BMDREDIT_CHANNEL;

void BmDrEdit_InitMelodicMode(void)
{
	ram_2778 = ram_277a;
	ram_2774 = ram_2776;
	ram_2728 &= ~1;
	ram_275a = 10;
	ram_2788 = 11;
	BmDrEdit_InitCommon();
}
void BmDrEdit_InitDrumMode(void)
{
	ram_1d50 = ram_1d4c = Malloc(0x6a4);
	NoteEditSy_ScanAndSortEntries();
	ram_2774 = 10;
	ram_2778 = ram_277c;
	ram_2728 |= 1;
	ram_275a = 7;
	ram_2788 = 8;
	BmDrEdit_InitCommon();
}
void BmDrEdit_LoadAlternateState(void)
{
	ram_2744 = ram_2750;
	ram_2746 = ram_2752;
	SEQ_DATA_BLOCK = ram_2754;
	SEQ_DATA_OFFSET = ram_2756;
}
void BmDrEdit_RenderHorizontal(void)
{
	ram_27a0 = (ram_27ee >> 2) + 0x16;
	ram_27a2 = (ram_27f0 >> 2) + ram_27a0;
	ram_27a4 = BmDrEdit_RenderHorizontal_Table[ram_27ec];
	ram_27a6 = ram_27a4 + 3;
}
void BmDrEdit_RenderVertical(void)
{
	ram_27a0 = (ram_27ee >> 2) + 0x5b;
	ram_27a2 = (ram_27f0 >> 2) + ram_27a0;
	ram_27a4 = BmDrEdit_RenderVertical_Table[ram_27ec];
	ram_27a6 = ram_27a4 + 3;
}
void BmDrEdit_SelectChannelAndLoadPos(void)
{
	unsigned int h;

	SEQ_ERROR_CODE = 0;
	h = BmDrEdit_SyncChannelAndGetPos();
	if (SEQ_ERROR_CODE != 0) return;
	ram_2750 = h;
	ram_2752 = 0;
	ram_2754 = SEQ_DATA_BLOCK;
	ram_2756 = SEQ_DATA_OFFSET;
}
unsigned int BmDrEdit_SyncChannelAndGetPos(void)
{
	unsigned int r;
	unsigned char h;

	ram_2863 = ram_272a;
	h = BmDrEdit_CheckAndSelectChannel();
	BmDrEdit_ValidateAndProcessVoice((unsigned char)(BMDREDIT_CHANNEL + 1), h, &r);
	return r;
}

/* cc900-module: BmDrEdit_AdjustScrollToView BmDrEdit_AllocateNoteSlot BmDrEdit_CalcBeatFromGridPos BmDrEdit_CheckSlotsAvailable BmDrEdit_ClearAllSlotsAlt BmDrEdit_FindNoteInSlots BmDrEdit_InsertNotesFromSlots BmDrEdit_InsertStepEntry BmDrEdit_PrepareAndInsertNote BmDrEdit_ProcessVoiceSection BmDrEdit_RefreshAfterInsert BmDrEdit_RestoreEditState BmDrEdit_SaveEditState BmDrEdit_SetupScrollRegion BmDrEdit_WalkEventsOrSetError BmDrEdit_WalkToGridPosition EditChannel_LoadVoiceParams */
extern int TempoRingBuf_CheckEmpty(void);
extern unsigned char TempoRingBuf_ReadByte(void);
extern void BmDrEdit_CountMeasuresInit(void);
extern void BmDrEdit_RefreshDisplayState(void);
extern void BmDrEdit_AllocateNoteSlot(void);
extern int BmDrEdit_FindNoteInSlots(void);
extern int BmDrEdit_CheckSlotsAvailable(void);
extern void BmDrEdit_AdjustScrollToView(void);
extern void BmDrEdit_InsertNotesFromSlots(void);
extern void BmDrEdit_ClearAllSlotsAlt(void);
extern void BmDrEdit_RefreshAfterInsert(void);
extern unsigned char __near ram_2943;
extern unsigned char __near ram_2944;
extern unsigned char __near ram_2945;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near ram_2940;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned char __near ram_2946;
extern void BmDrEdit_CheckTempoData(void);
extern void BmDrEdit_WalkEventsOrSetError(void);
extern void BmDrEdit_PrepareAndInsertNote(void);
extern void BmDrEdit_CalcBeatFromGridPos(void);
extern unsigned char __near ram_276c;
extern unsigned char __near ram_272e;
extern unsigned char __near ram_272c[][3];
extern void BmDrEdit_SaveSongPosition(void);
extern void BmDrEdit_ApplyVelocityChange(unsigned int, unsigned char *, unsigned int);
extern void BmDrEdit_WalkToGridPosition(void);
extern unsigned char __near ram_294d;
extern unsigned char __near ram_294e;
extern unsigned char __near ram_294f;
extern unsigned char __near ram_2950;
extern unsigned char __near ram_294b;
extern unsigned char __near ram_294c;
extern void SeqData_AdvancePosition(void);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_CopyEventDataBetweenParts(unsigned int);
extern void BmDrEdit_SeekForwardToEvent(void);
extern void ReadSeqData_StoreParams(void);

void BmDrEdit_CheckTempoData(void)
{
	unsigned char t, c;

	if (TempoRingBuf_CheckEmpty() == 0) return;
	t = ACTIVE_TITLE;
	if (t != 0x95 && t != 0x98) return;
	if (ram_2940 & 0x80) return;
	if (SEQ_FREE_BLOCKS == 0) goto clear;
	while (TempoRingBuf_CheckEmpty() != 0) {
		c = TempoRingBuf_ReadByte();
		if (!(c & 0x80)) continue;
		if ((c & 0xf0) != 0x90) continue;
		TempoRingBuf_ReadByte();
		ram_2944 = TempoRingBuf_ReadByte();
		ram_2945 = TempoRingBuf_ReadByte();
		TempoRingBuf_ReadByte();
		if (ram_2945 != 0) {
			BmDrEdit_AllocateNoteSlot();
			continue;
		}
		if (BmDrEdit_FindNoteInSlots() == 0xff) continue;
		if (BmDrEdit_CheckSlotsAvailable() != 0) continue;
		ram_2943 &= ~1;
		ram_2946 = ram_2944;
		BmDrEdit_AdjustScrollToView();
		BmDrEdit_InsertNotesFromSlots();
		BmDrEdit_CountMeasuresInit();
		if (SEQ_ERROR_CODE != 0) {
clear:
			ram_2943 &= ~1;
			BmDrEdit_RefreshDisplayState();
			return;
		}
		BmDrEdit_ClearAllSlotsAlt();
		BmDrEdit_RefreshAfterInsert();
	}
}
void BmDrEdit_InsertNotesFromSlots(void)
{
	unsigned int i;

	if (ram_2728 & 1) {
		ram_2944 = ram_276c;
		ram_2945 = ram_272e;
		BmDrEdit_WalkEventsOrSetError();
		return;
	}
	for (i = 0; i < 8; i++) {
		if (ram_272c[i][1] != 0) {
			ram_2944 = ram_272c[i][1];
			ram_2945 = ram_272c[i][2];
			BmDrEdit_PrepareAndInsertNote();
			if (SEQ_ERROR_CODE != 0) {
				BmDrEdit_RefreshDisplayState();
				return;
			}
			BmDrEdit_CalcBeatFromGridPos();
		}
	}
}
void BmDrEdit_PrepareAndInsertNote(void)
{
	BmDrEdit_WalkToGridPosition();
	ram_294b = 144;
	ram_294c = ram_2780 % 96;
	ram_294d = ram_2944;
	ram_294e = ram_2945;
	ram_294f = (ram_2774 % 96) & 0x7f;
	ram_2950 = (ram_2774 / 96) & 0x7f;
	BmDrEdit_SaveSongPosition();
	BmDrEdit_ApplyVelocityChange((unsigned char)(BMDREDIT_CHANNEL + 1), (unsigned char *)0x294b, 6);
}
void ReadSeqData_StoreParams(void)
{
	SeqData_AdvancePosition();
	SeqData_AdvancePosition();
	ram_294d = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_294e = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_294f = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_2950 = SeqData_ReadNextByte();
	BmDrEdit_ClearAndScanToEnd();
	BmDrEdit_CopyEventDataBetweenParts((unsigned char)(BMDREDIT_CHANNEL + 1));
	BmDrEdit_SeekForwardToEvent();
	if (SEQ_ERROR_CODE != 0) goto err;
	ram_294b = 144;
	ram_294c = ram_276a;
	BmDrEdit_SaveSongPosition();
	BmDrEdit_ApplyVelocityChange((unsigned char)(BMDREDIT_CHANNEL + 1), (unsigned char *)0x294b, 6);
	BmDrEdit_CountMeasuresInit();
	if (SEQ_ERROR_CODE != 0) {
err:
		BmDrEdit_RefreshDisplayState();
	}
}

extern unsigned char BmDrEdit_ProcessVoiceSection(unsigned int, unsigned int *, unsigned int *);
extern void EditChannel_LoadVoiceParams(void);
extern void BmDrEdit_InsertStepEntry(void);
extern unsigned int __near ram_ce3;
extern void BmDrEdit_InsertMultiSongSteps(void);
extern void NoteEditSy_SendWidgetCmdC(void);
extern void BmDrEdit_SaveEditState(void);
extern void BmDrEdit_RestoreEditState(void);
extern void BmDrEdit_SetupScrollRegion(unsigned char *, unsigned char *);
extern unsigned int __near ram_27f2;
extern unsigned int __near ram_27f4;
extern unsigned int __near ram_27f6;
extern unsigned int __near ram_27f8;
extern unsigned int __near ram_27fa;
extern unsigned int __near ram_27fc;
extern unsigned int __near ram_27fe;
extern unsigned int __near ram_2800;
extern unsigned char __near ram_2802;
extern unsigned char __near ram_280c;
extern unsigned char __near ram_280e;
extern unsigned int __near ram_2806;
extern void BmDrEdit_PrepareSecondaryNoteDisplay(void);

void BmDrEdit_InsertMultiSongSteps(void)
{
	unsigned int a, b;
	unsigned char r;

	ram_ce3 = ram_2758;
	ram_2744 = ram_2758;
	for (;;) {
		r = BmDrEdit_ProcessVoiceSection(BmDrEdit_CheckAndSelectChannel(), &a, &b);
		if (ram_272a == a) goto out;
		if (b != 0) r -= b;
		ram_2758 = r;
		do {
			EditChannel_LoadVoiceParams();
			BmDrEdit_InsertStepEntry();
			if (SEQ_ERROR_CODE != 0) goto out;
			ram_2744++;
		} while (--ram_2758 != 0);
		ram_ce3 = ram_2744;
	}
out:
	;
}
void BmDrEdit_PrepareSecondaryNoteDisplay(void)
{
	unsigned char lo, hi;
	unsigned int v, w;

	if (!(ram_2943 & 1)) return;
	BmDrEdit_SaveEditState();
	ram_27f2 = ram_2750;
	ram_27f4 = ram_2752;
	ram_27f6 = ram_2754;
	ram_27f8 = ram_2756;
	ram_27fa = ram_2744;
	ram_27fc = ram_2746;
	ram_27fe = SEQ_DATA_BLOCK;
	ram_2800 = SEQ_DATA_OFFSET;
	if ((SeqData_ReadNextByte() & 0xf0) == 0x90) {
		SeqData_AdvancePosition();
		ram_27fc = SeqData_ReadNextByte();
		SeqData_AdvancePosition();
		ram_2802 = SeqData_ReadNextByte();
		BmDrEdit_SetupScrollRegion(&lo, &hi);
		if (ram_2802 >= lo && ram_2802 <= hi) {
			ram_280c = lo;
			ram_280e = hi;
			SeqData_AdvancePosition();
			SeqData_AdvancePosition();
			v = SeqData_ReadNextByte();
			SeqData_AdvancePosition();
			w = SeqData_ReadNextByte();
			v &= 0x7f;
			w &= 0x7f;
			w *= 0x60;
			w += v;
			ram_2806 = w;
			NoteEditSy_SendWidgetCmdC();
		}
	}
	BmDrEdit_RestoreEditState();
}

/* cc900-module: BmDrEdit_AdvanceStreamPos BmDrEdit_CompareVelocity BmDrEdit_SetupCoordinates */
extern unsigned char BmDrEdit_CompareVelocity(void);
extern void BmDrEdit_SetupCoordinates(unsigned int *, unsigned int *);
extern unsigned char __near ram_276e;
extern unsigned int __near ram_2772;
extern void BmDrEdit_SetupAndWalkToNote(void);

void BmDrEdit_SetupAndWalkToNote(void)
{
	unsigned int a, b;
	unsigned char v, w;
	unsigned int x;

	ram_2943 &= ~1;
	BmDrEdit_SetupCoordinates(&a, &b);
	a -= b;
	if (a != ram_2780) return;
	if ((SeqData_ReadNextByte() & 0xf0) != 0x90) return;
	if (BmDrEdit_CompareVelocity() != 0) return;
	ram_2943 |= 1;
	SeqData_AdvancePosition();
	SeqData_AdvancePosition();
	ram_276c = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	ram_276e = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	v = SeqData_ReadNextByte();
	SeqData_AdvancePosition();
	w = SeqData_ReadNextByte();
	w &= 0x7f;
	v &= 0x7f;
	x = w;
	x *= 0x60;
	x += v;
	ram_2772 = x;
	BmDrEdit_ClearAndScanToEnd();
	ram_2946 = ram_276c;
	BmDrEdit_AdjustScrollToView();
}

/* cc900-module: BmDrEdit_CheckAndAdvancePage */
extern void BmDrEdit_CheckAndAdvancePage(void);
extern void BmDrEdit_CalcTickPosition(void);

void BmDrEdit_CalcTickPosition(void)
{
	unsigned int t;

	BmDrEdit_CheckAndAdvancePage();
	t = ram_2768 * 0x60;
	t += ram_276a;
	ram_2780 = t;
}

/* cc900-module: BmDrEdit_IncrementDuration NoteEditSy_UpdateAllWidgets */
extern unsigned char __near ram_2941;
extern void BmDrEdit_IncrementDuration(void);
extern void BmDrEdit_DurationUp_Check(void);
extern void NoteEditSy_UpdateAllWidgets(void);
extern void NoteEdit_UpdateScrollAndDisplay(void);

void BmDrEdit_DurationUp_Check(void)
{
  if ((ram_2940 & 0x80) && ram_2941 != 3)
    return;
  BmDrEdit_IncrementDuration();
}
void NoteEdit_UpdateScrollAndDisplay(void)
{
  if (ram_2780 >= (unsigned int)(ram_275a * 0x60))
    return;
  NoteEditSy_UpdateAllWidgets();
}
