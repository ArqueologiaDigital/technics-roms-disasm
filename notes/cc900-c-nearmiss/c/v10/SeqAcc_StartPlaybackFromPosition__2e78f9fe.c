/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m232.c (2026-11-19-43-p6-r48)
   sha256 2e78f9fed04fe25afa62f49c17d7d16852e5ad3db0ebe372349716c9d6d1e823 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_26ec;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_COUNT_IN;
extern unsigned int __near ram_28c3;
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
