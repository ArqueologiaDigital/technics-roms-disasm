/* lane_p6 helper N, round 4, form a: module 232: BmDrEdit_WalkAndScanAfterEdit (sequencer/bmdredit_routines.s),
   retry of p6_N_2m232a, and the new SeqAcc_StartPlaybackFromPosition (sequencer/sequencer_engine.s, below) (p6-r43 O3Xr: +101).  In the loop's end-mark case the ROM jumps back on `a >= b`
   (`jr nc`) and falls into a jump to the not-found exit; V4.23 had turned `if (a >= b) continue; goto notfound;`
   around.  Written `if (a < b) goto notfound; continue;` here.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_ClearAndScanToEnd BmDrEdit_CompareVelocity BmDrEdit_ReadEventAtPosition BmDrEdit_SetupCoordinates SeqAcc_SetupRepeatCount SeqAcc_UpdateEndPosition */

extern unsigned char __near ram_295f;
extern unsigned int __near ram_279c;
extern unsigned int __near ram_275e;
extern unsigned char __near ram_2760;
extern unsigned char __near SEQ_ERROR_CODE;
extern unsigned char SeqData_ReadNextByte(void);
extern unsigned char BmDrEdit_CompareVelocity(void);
extern void BmDrEdit_SetupCoordinates(unsigned int *, unsigned int *);
extern void BmDrEdit_ClearAndScanToEnd(void);
extern void BmDrEdit_ReadEventAtPosition(void);
extern void BmDrEdit_LoadAlternateState(void);
extern void BmDrEdit_CheckNoteAtPosition(void);
extern void BmDrEdit_SaveEditState(void);
extern void BmDrEdit_WalkTrackForward(void);
extern void BmDrEdit_RestoreEditState(void);
extern void BmDrEdit_WalkAndScanAfterEdit(void);

void BmDrEdit_WalkAndScanAfterEdit(void)
{
	unsigned int a, b;
	unsigned char c;

	ram_295f &= ~0x08;
	if (SeqData_ReadNextByte() == 0x81) {
		if (ram_275e == 0)
			goto notfound;
		ram_275e--;
		BmDrEdit_SetupCoordinates(&a, &b);
		if (a < b)
			goto notfound;
	}
	for (;;) {
		BmDrEdit_ClearAndScanToEnd();
		if (SEQ_ERROR_CODE != 0) {
			ram_295f |= 0x08;
			SEQ_ERROR_CODE = 0;
			return;
		}
		c = SeqData_ReadNextByte();
		if (c == 0x81) {
			if (ram_275e == 0)
				goto notfound;
			ram_275e--;
			BmDrEdit_SetupCoordinates(&a, &b);
			if (a < b)
				goto notfound;
			continue;
		}
		if ((c & 0xf0) != 0x90)
			continue;
		if (BmDrEdit_CompareVelocity() != 0)
			continue;
		BmDrEdit_ReadEventAtPosition();
		BmDrEdit_SetupCoordinates(&a, &b);
		if (a >= b)
			return;
		goto notfound;
	}
notfound:
	ram_295f |= 0x08;
}

/* SeqAcc_StartPlaybackFromPosition (new, sequencer/sequencer_engine.s): starts sequencer playback from the start
   measure (saved at 0x26ec); a positive start past the punch-in measure is pulled back to punch-in minus count-in,
   else the end position is set to punch-in - 1 first.  The ROM tests bit 15 of the start measure after a 32-bit
   zero extension: the sign-magnitude "before measure 1" bit through an unsigned long. */
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_26ec;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_COUNT_IN;
extern unsigned int __near ram_28c3;
extern unsigned char __near SEQ_SONG_RECORD[];
extern void Accomp_UpdateModeFlag(void);
extern void SeqAcc_UpdateEndPosition(void);
extern void SeqAcc_SetupRepeatCount(void);
extern void SeqPlay_InitStartState(void);
extern void SeqBuf_Init(void);

void SeqAcc_StartPlaybackFromPosition(void)
{
	unsigned int s;

	Accomp_UpdateModeFlag();
	ram_26ec = SEQ_START_MEASURE;
	s = SEQ_START_MEASURE;
	if (((unsigned long)s & 0x8000) == 0) {
		if (s > SEQ_PUNCH_IN_MEASURE) {
			SEQ_START_MEASURE = SEQ_PUNCH_IN_MEASURE - SEQ_COUNT_IN;
			ram_26ec = SEQ_START_MEASURE;
		} else {
			ram_28c3 = SEQ_PUNCH_IN_MEASURE - 1;
			SeqAcc_UpdateEndPosition();
			SEQ_START_MEASURE = SEQ_PUNCH_IN_MEASURE - SEQ_COUNT_IN;
			ram_26ec = SEQ_START_MEASURE;
		}
	}
	SEQ_SONG_RECORD[188] |= 0x01;
	SeqAcc_SetupRepeatCount();
	SeqPlay_InitStartState();
	SeqBuf_Init();
}
