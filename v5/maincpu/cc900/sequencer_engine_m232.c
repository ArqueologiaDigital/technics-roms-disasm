/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_ClearAndScanToEnd BmDrEdit_CompareVelocity BmDrEdit_ReadEventAtPosition BmDrEdit_SetupCoordinates SeqAcc_SetupRepeatCount SeqAcc_UpdateEndPosition */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near SEQ_METRO_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_26d2;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_COUNT_IN;
extern unsigned int __near ram_28a7;
extern void SeqAcc_UpdateEndPosition(void);
extern void SeqPlay_UpdateStartFromPunchInDown(void);
extern unsigned char __near SEQ_SONG_RECORD[];
extern void Accomp_UpdateModeFlag(void);
extern void SeqAcc_SetupRepeatCount(void);
extern void SeqPlay_InitStartState(void);
extern void SeqBuf_Init(void);
extern void SeqAcc_StartPlaybackFromPosition(void);

void SeqPlay_UpdateStartFromPunchInDown(void)
{
	unsigned int p;

	if (SEQ_METRO_FLAGS & 0x01) {
		p = SEQ_PUNCH_IN_MEASURE;
		if (p == 1) {
			SEQ_START_MEASURE = 0x8002;
			ram_26d2 = 0x8002;
			SEQ_COUNT_IN = 2;
			return;
		}
		if (p == 2) {
			SEQ_START_MEASURE = 2;
			ram_26d2 = 0x8002;
			SEQ_COUNT_IN = 3;
			return;
		}
		if (p < 3)
			return;
	}
	ram_28a7 = SEQ_PUNCH_IN_MEASURE - 1;
	SeqAcc_UpdateEndPosition();
	SEQ_START_MEASURE = SEQ_PUNCH_IN_MEASURE - SEQ_COUNT_IN;
	ram_26d2 = SEQ_START_MEASURE;
}

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
