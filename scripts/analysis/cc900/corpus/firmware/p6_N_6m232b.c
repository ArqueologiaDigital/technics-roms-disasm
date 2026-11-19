/* lane_p6 helper N, round 6, form b: module 232 (sequencer/sequencer_engine.s), retry of p6_N_5m232a.
   SeqPlay_IncPunchCountIn, form b against a: the new start measure in an unsigned int local stored to both cells.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SeqAcc_SetupRepeatCount SeqAcc_UpdateEndPosition */

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
	c = SEQ_PUNCH_IN_MEASURE - SEQ_COUNT_IN;
	SEQ_START_MEASURE = c;
	ram_26ec = c;
	SeqAcc_SetupRepeatCount();
}
