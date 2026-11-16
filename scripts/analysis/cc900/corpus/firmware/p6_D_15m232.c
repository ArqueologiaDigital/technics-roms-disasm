/* Phase 6, lane_p6 helper D, round 15, module 232 (v10 sequencer/bmdredit_routines.s): BmDrEdit_SaveSequencerState
   after run 100 (the conditional title id was loaded as a byte before the test; the ROM loads the 16-bit id in each
   branch): the id goes through a local (lane_sub's spelling (b)).  TT_SQDRMEDT 0x98, TT_SQNOTEEDT 0x95.
   New: ReadSeqData_StoreParams and BmDrEdit_InitMelodicMode (moves between __near cells).  BmDrEdit_InitCommon is
   added to the module line by hand: InitMelodicMode's jr reaches it as the next instruction, so module_calls.py
   counts it as part of the function (round 14's InitDrumMode, which listed it, matched). */
/* cc900-module: BmDrEdit_ApplyVelocityChange BmDrEdit_ClearAndScanToEnd BmDrEdit_CopyEventDataBetweenParts BmDrEdit_CountMeasuresInit BmDrEdit_InitCommon BmDrEdit_RefreshDisplayState BmDrEdit_SaveSongPosition BmDrEdit_SeekForwardToEvent */   /* from scripts/analysis/cc900/module_calls.py v10, plus BmDrEdit_InitCommon */

extern void UI_ChangeTitleByIndex(unsigned int);
extern void SeqVoice_FindSingleActive(void);

extern unsigned char __near ram_2742;
extern unsigned int __near ram_2963;
extern unsigned int __near ram_d4f;
extern unsigned char __near ram_1d58;
extern unsigned char __near PART_SELECT;

extern void SeqData_AdvancePosition(void);
extern unsigned char SeqData_ReadNextByte(void);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_CopyEventDataBetweenParts(unsigned int);
extern void BmDrEdit_SeekForwardToEvent(void);
extern void BmDrEdit_SaveSongPosition(void);
extern void BmDrEdit_ApplyVelocityChange(unsigned int, unsigned char *, unsigned int);
extern void BmDrEdit_CountMeasuresInit(void);
extern void BmDrEdit_RefreshDisplayState(void);
extern void BmDrEdit_InitCommon(void);

extern unsigned char __near ram_2969;
extern unsigned char __near ram_296a;
extern unsigned char __near ram_296b;
extern unsigned char __near ram_296c;
extern unsigned char __near ram_2967;
extern unsigned char __near ram_2968;
extern unsigned char __near ram_2784;
extern unsigned char __near BMDREDIT_CHANNEL;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned int __near ram_2792;
extern unsigned int __near ram_2794;
extern unsigned int __near ram_278e;
extern unsigned int __near ram_2790;
extern unsigned char __near ram_2774;
extern unsigned char __near ram_27a2;

/* The last call (RefreshDisplayState) is calr + ret in the ROM, so it is kept inside an if. */
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
	if (SEQ_ERROR_CODE == 0) {
		ram_2967 = 144;
		ram_2968 = ram_2784;
		BmDrEdit_SaveSongPosition();
		BmDrEdit_ApplyVelocityChange((unsigned char)(BMDREDIT_CHANNEL + 1), (unsigned char *)0x2967, 6);
		BmDrEdit_CountMeasuresInit();
		if (SEQ_ERROR_CODE == 0) return;
	}
	if (SEQ_ERROR_CODE != 0) BmDrEdit_RefreshDisplayState();
}

void BmDrEdit_InitMelodicMode(void)
{
	ram_2792 = ram_2794;
	ram_278e = ram_2790;
	ram_2742 &= ~1;
	ram_2774 = 10;
	ram_27a2 = 11;
	BmDrEdit_InitCommon();
}

void BmDrEdit_SaveSequencerState(void)
{
	unsigned int k;

	if (ram_2742 & 1) k = 0x98;
	else k = 0x95;
	UI_ChangeTitleByIndex(k);
	ram_2963 = ram_d4f;
	SeqVoice_FindSingleActive();
	ram_1d58 = PART_SELECT;
}
