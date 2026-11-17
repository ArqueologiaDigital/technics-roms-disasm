/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of v7/bmdredit_routines_m232.c (2026-11-16-122-p6-r24-staged)
   sha256 26591d55dcf949f2a41848b38de0a4bf6e05f8859ecff33f75bd772696e452d1 (tar-sha256); compiled at -O3 -Xr */
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
extern unsigned char __near ram_2742;
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
extern unsigned char __near BMDREDIT_CHANNEL;
extern unsigned int __near ram_279a;
extern unsigned int __near ram_278e;
extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_CopyEventDataBetweenParts(unsigned int);
extern void BmDrEdit_SeekForwardToEvent(void);
extern unsigned char __near ram_2784;
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
