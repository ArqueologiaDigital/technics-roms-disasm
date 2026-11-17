/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of v5/bmdredit_routines_m232.c (2026-11-16-122-p6-r24-staged)
   sha256 caa842da0a49ca6251067b9b9a0d1b370620ba7c554bbe7135868e7b4488a908 (tar-sha256); compiled at -O3 -Xr */
/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_AdjustScrollToView BmDrEdit_AllocateNoteSlot BmDrEdit_ApplyVelocityChange BmDrEdit_CalcBeatFromGridPos BmDrEdit_CheckAndSelectChannel BmDrEdit_CheckSlotsAvailable BmDrEdit_ClearAllSlotsAlt BmDrEdit_ClearAndScanToEnd BmDrEdit_CopyEventDataBetweenParts BmDrEdit_CountMeasuresInit BmDrEdit_FindNoteInSlots BmDrEdit_InsertNotesFromSlots BmDrEdit_InsertStepEntry BmDrEdit_PrepareAndInsertNote BmDrEdit_ProcessVoiceSection BmDrEdit_RefreshAfterInsert BmDrEdit_RefreshDisplayState BmDrEdit_RestoreEditState BmDrEdit_SaveEditState BmDrEdit_SaveSongPosition BmDrEdit_SeekForwardToEvent BmDrEdit_SetupScrollRegion BmDrEdit_WalkEventsOrSetError BmDrEdit_WalkToGridPosition EditChannel_LoadVoiceParams */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern unsigned char __near SEQ_ERROR_CODE;
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
extern unsigned char __near ram_2728;
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
extern unsigned char __near BMDREDIT_CHANNEL;
extern unsigned int __near ram_2780;
extern unsigned int __near ram_2774;
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_CopyEventDataBetweenParts(unsigned int);
extern void BmDrEdit_SeekForwardToEvent(void);
extern unsigned char __near ram_276a;
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
