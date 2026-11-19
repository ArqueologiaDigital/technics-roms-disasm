/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m232.c (2026-11-19-43-p6-r48)
   sha256 6597b93e80a72e4da473886c537bd3ec732139980ef2dd0b579c43b4aea00e13 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_26d2;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_COUNT_IN;
extern unsigned int __near ram_28a7;
extern void SeqAcc_UpdateEndPosition(void);
extern unsigned char __near SEQ_SONG_RECORD[];
extern void Accomp_UpdateModeFlag(void);
extern void SeqAcc_SetupRepeatCount(void);
extern void SeqPlay_InitStartState(void);
extern void SeqBuf_Init(void);
void SeqAcc_StartPlaybackFromPosition(void)
{
	unsigned int s;

	Accomp_UpdateModeFlag();
	ram_26d2 = SEQ_START_MEASURE;
	s = SEQ_START_MEASURE;
	if (((unsigned long)s & 0x8000) == 0) {
		if (s > SEQ_PUNCH_IN_MEASURE) {
			SEQ_START_MEASURE = SEQ_PUNCH_IN_MEASURE - SEQ_COUNT_IN;
			ram_26d2 = SEQ_START_MEASURE;
		} else {
			ram_28a7 = SEQ_PUNCH_IN_MEASURE - 1;
			SeqAcc_UpdateEndPosition();
			SEQ_START_MEASURE = SEQ_PUNCH_IN_MEASURE - SEQ_COUNT_IN;
			ram_26d2 = SEQ_START_MEASURE;
		}
	}
	SEQ_SONG_RECORD[188] |= 0x01;
	SeqAcc_SetupRepeatCount();
	SeqPlay_InitStartState();
	SeqBuf_Init();
}
