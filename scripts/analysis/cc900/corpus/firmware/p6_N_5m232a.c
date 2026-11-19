/* lane_p6 helper N, round 5, form a: module 232 (sequencer/sequencer_engine.s), new functions: the punch-in
   family of the built SeqAcc_StartPlaybackFromPosition (round 4 match), whose tail they share.
   - SeqPlay_UpdateStartFromPunchInDown: with the metronome bit set, punch-in measures 1 / 2 start two measures /
     one measure before measure 1 (sign-magnitude 0x8002) with count-in 2 / 3, measure 0 does nothing; otherwise
     the end goes to punch-in - 1 and the start to punch-in - count-in.
   - SeqPlay_IncPunchCountIn: increments the count-in (at most 997) unless the metronome bit is set with punch-in
     at most 2, then the same start update, then SeqAcc_SetupRepeatCount (tail jump).
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
