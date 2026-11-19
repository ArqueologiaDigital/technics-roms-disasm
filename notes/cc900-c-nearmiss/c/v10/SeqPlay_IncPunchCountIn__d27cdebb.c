/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_5m232a.c (2026-11-19-37-p6-r47)
   sha256 d27cdebb03188229c55cb2928d94a645ed931342448e1919b77803d3f2ac0384 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_METRO_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_26ec;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_COUNT_IN;
extern unsigned int __near ram_28c3;
extern void SeqAcc_UpdateEndPosition(void);
extern void SeqAcc_SetupRepeatCount(void);
void SeqPlay_IncPunchCountIn(void)
{
	unsigned int c;

	if ((SEQ_METRO_FLAGS & 0x01) && SEQ_PUNCH_IN_MEASURE <= 2)
		return;
	c = SEQ_COUNT_IN;
	if (c >= 997)
		SEQ_COUNT_IN = 997;
	else
		SEQ_COUNT_IN = c + 1;
	ram_28c3 = SEQ_PUNCH_IN_MEASURE - 1;
	SeqAcc_UpdateEndPosition();
	SEQ_START_MEASURE = SEQ_PUNCH_IN_MEASURE - SEQ_COUNT_IN;
	ram_26ec = SEQ_START_MEASURE;
	SeqAcc_SetupRepeatCount();
}
