/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_5m232a.c (2026-11-19-37-p6-r47)
   sha256 d27cdebb03188229c55cb2928d94a645ed931342448e1919b77803d3f2ac0384 (tar-sha256); compiled at -Xr
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
