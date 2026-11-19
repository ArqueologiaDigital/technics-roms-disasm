/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_4m232a.c (2026-11-19-29-p6-r46)
   sha256 afa7fe06b3a6cb414ce507f63dd6a05755c33a23cfe952a6bcb06cbaa8563112 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
