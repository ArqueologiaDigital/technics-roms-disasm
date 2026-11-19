/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m232.c (2026-11-19-43-p6-r48)
   sha256 6597b93e80a72e4da473886c537bd3ec732139980ef2dd0b579c43b4aea00e13 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_METRO_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_26d2;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_COUNT_IN;
extern unsigned int __near ram_28a7;
extern void SeqAcc_UpdateEndPosition(void);
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
