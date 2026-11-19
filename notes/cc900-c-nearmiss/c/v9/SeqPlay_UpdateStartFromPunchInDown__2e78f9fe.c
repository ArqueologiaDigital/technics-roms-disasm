/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m232.c (2026-11-19-43-p6-r48)
   sha256 2e78f9fed04fe25afa62f49c17d7d16852e5ad3db0ebe372349716c9d6d1e823 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_METRO_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_26ec;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_COUNT_IN;
extern unsigned int __near ram_28c3;
extern void SeqAcc_UpdateEndPosition(void);
void SeqPlay_UpdateStartFromPunchInDown(void)
{
	unsigned int p;

	if (SEQ_METRO_FLAGS & 0x01) {
		p = SEQ_PUNCH_IN_MEASURE;
		if (p == 1) {
			SEQ_START_MEASURE = 0x8002;
			ram_26ec = 0x8002;
			SEQ_COUNT_IN = 2;
			return;
		}
		if (p == 2) {
			SEQ_START_MEASURE = 2;
			ram_26ec = 0x8002;
			SEQ_COUNT_IN = 3;
			return;
		}
		if (p < 3)
			return;
	}
	ram_28c3 = SEQ_PUNCH_IN_MEASURE - 1;
	SeqAcc_UpdateEndPosition();
	SEQ_START_MEASURE = SEQ_PUNCH_IN_MEASURE - SEQ_COUNT_IN;
	ram_26ec = SEQ_START_MEASURE;
}
