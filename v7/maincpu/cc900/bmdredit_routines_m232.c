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
extern unsigned int __near ram_2772;
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
	ram_2772 = 0;
	for (;;) {
		c = SeqData_ReadNextByte();
		if (c == 0x82 || c == 0x84) break;
		if (c == 0x81) ram_2772++;
		SeqData_SkipToNextEvent();
	}
	if (SEQ_ERROR_CODE != 0) SeqData_SetErrorCode(0xce);
}

extern unsigned char __near ram_25d8;
extern unsigned char __near ram_2784;
extern unsigned char __near ram_27a4[];
extern unsigned int __near ram_279a;
extern unsigned int __near ram_2782;
extern void BmDrEdit_CalcSongPosition(void);
void BmDrEdit_CalcBeatMeasure(void);
extern void BmDrEdit_CalcSongPosition(void);

void BmDrEdit_CalcSongPosition(void);

void BmDrEdit_CalcBeatMeasure(void)
{
	unsigned int n, i;
	unsigned char *t;

	n = ram_279a / 96;
	ram_25d8 = 0;
	ram_2772 = n;
	if (n != 0) {
		i = 1;
		ram_25d8 = 1;
		t = ram_27a4;
		for (;;) {
			if (t[i] != 0) ram_25d8 = 0;
			i++;
			if ((ram_2772 = ram_2772 - 1) == 0) break;
			ram_25d8++;
		}
	}
	ram_2782 = ram_25d8;
	ram_2784 = ram_279a % 96;
	BmDrEdit_CalcSongPosition();
}

/* cc900-module: BmDrEdit_ApplyVelocityChange BmDrEdit_CheckAndSelectChannel BmDrEdit_ClearAndScanToEnd BmDrEdit_CopyEventDataBetweenParts BmDrEdit_CountMeasuresInit BmDrEdit_InitCommon BmDrEdit_RefreshDisplayState BmDrEdit_SaveSongPosition BmDrEdit_SeekForwardToEvent BmDrEdit_SyncChannelAndGetPos BmDrEdit_ValidateAndProcessVoice NoteEditSy_ScanAndSortEntries */
extern unsigned char __near ram_2742;
extern void BmDrEdit_InitCommon(void);
extern unsigned int __near ram_2792;
extern unsigned int __near ram_2794;
extern unsigned int __near ram_278e;
extern unsigned int __near ram_2790;
extern unsigned char __near ram_2774;
extern unsigned char __near ram_27a2;
extern void BmDrEdit_InitMelodicMode(void);
extern void NoteEditSy_ScanAndSortEntries(void);
extern unsigned char *__cdecl Malloc(unsigned int);
typedef unsigned char *ucp;
extern ucp __near ram_1d50;
extern ucp __near ram_1d54;
extern unsigned int __near ram_2796;
extern void BmDrEdit_InitDrumMode(void);
extern unsigned int __near ram_275e;
extern unsigned int __near ram_276a;
extern unsigned char __near ram_2760;
extern unsigned char __near ram_276c;
extern unsigned int __near ram_276e;
extern unsigned char __near ram_2770;
extern void BmDrEdit_LoadAlternateState(void);
extern unsigned int __near ram_2808;
extern unsigned int __near ram_280a;
extern unsigned int __near ram_27ba;
extern unsigned int __near ram_27bc;
extern unsigned char __near ram_2806;
extern unsigned int __near ram_27be;
extern unsigned int __near ram_27c0;
extern unsigned int BmDrEdit_RenderVertical_Table[], BmDrEdit_RenderHorizontal_Table[];
extern void BmDrEdit_RenderHorizontal(void);
extern void BmDrEdit_RenderVertical(void);
extern unsigned int BmDrEdit_SyncChannelAndGetPos(void);
extern void BmDrEdit_SelectChannelAndLoadPos(void);
extern unsigned char BmDrEdit_CheckAndSelectChannel(void);
extern void BmDrEdit_ValidateAndProcessVoice(unsigned int, unsigned int, unsigned int *);
extern unsigned int __near ram_287f;
extern unsigned int __near ram_2744;
extern unsigned char __near BMDREDIT_CHANNEL;

void BmDrEdit_InitMelodicMode(void)
{
	ram_2792 = ram_2794;
	ram_278e = ram_2790;
	ram_2742 &= ~1;
	ram_2774 = 10;
	ram_27a2 = 11;
	BmDrEdit_InitCommon();
}
void BmDrEdit_InitDrumMode(void)
{
	ram_1d54 = ram_1d50 = Malloc(0x6a4);
	NoteEditSy_ScanAndSortEntries();
	ram_278e = 10;
	ram_2792 = ram_2796;
	ram_2742 |= 1;
	ram_2774 = 7;
	ram_27a2 = 8;
	BmDrEdit_InitCommon();
}
void BmDrEdit_LoadAlternateState(void)
{
	ram_275e = ram_276a;
	ram_2760 = ram_276c;
	SEQ_DATA_BLOCK = ram_276e;
	SEQ_DATA_OFFSET = ram_2770;
}
void BmDrEdit_RenderHorizontal(void)
{
	ram_27ba = (ram_2808 >> 2) + 0x16;
	ram_27bc = (ram_280a >> 2) + ram_27ba;
	ram_27be = BmDrEdit_RenderHorizontal_Table[ram_2806];
	ram_27c0 = ram_27be + 3;
}
void BmDrEdit_RenderVertical(void)
{
	ram_27ba = (ram_2808 >> 2) + 0x5b;
	ram_27bc = (ram_280a >> 2) + ram_27ba;
	ram_27be = BmDrEdit_RenderVertical_Table[ram_2806];
	ram_27c0 = ram_27be + 3;
}
void BmDrEdit_SelectChannelAndLoadPos(void)
{
	unsigned int h;

	SEQ_ERROR_CODE = 0;
	h = BmDrEdit_SyncChannelAndGetPos();
	if (SEQ_ERROR_CODE != 0) return;
	ram_276a = h;
	ram_276c = 0;
	ram_276e = SEQ_DATA_BLOCK;
	ram_2770 = SEQ_DATA_OFFSET;
}
unsigned int BmDrEdit_SyncChannelAndGetPos(void)
{
	unsigned int r;
	unsigned char h;

	ram_287f = ram_2744;
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
extern unsigned char __near ram_295f;
extern unsigned char __near ram_2960;
extern unsigned char __near ram_2961;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near ram_295c;
extern unsigned int __near SEQ_FREE_BLOCKS;
extern unsigned char __near ram_2962;
extern void BmDrEdit_CheckTempoData(void);
extern void BmDrEdit_WalkEventsOrSetError(void);
extern void BmDrEdit_PrepareAndInsertNote(void);
extern void BmDrEdit_CalcBeatFromGridPos(void);
extern unsigned char __near ram_2786;
extern unsigned char __near ram_2748;
extern unsigned char __near ram_2746[][3];
extern void BmDrEdit_SaveSongPosition(void);
extern void BmDrEdit_ApplyVelocityChange(unsigned int, unsigned char *, unsigned int);
extern void BmDrEdit_WalkToGridPosition(void);
extern unsigned char __near ram_2969;
extern unsigned char __near ram_296a;
extern unsigned char __near ram_296b;
extern unsigned char __near ram_296c;
extern unsigned char __near ram_2967;
extern unsigned char __near ram_2968;
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
