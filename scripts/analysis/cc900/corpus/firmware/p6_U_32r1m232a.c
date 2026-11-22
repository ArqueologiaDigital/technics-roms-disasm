/* lane_p6 helper U, round 32r1: roots of sequencer/bmdredit_routines.s, module 232. */

extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near PREVIOUS_TITLE;
extern volatile unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned char __near ram_283c;
extern unsigned char __near ram_283a;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned int __near ram_2963;
extern unsigned int __near ram_2744;
extern unsigned int __near ram_251c;
extern unsigned int __near ram_251e;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near SEQ_RTMCFG;
extern void Audio_CheckSubsystemReady(void);
extern void SeqPlay_AllocBuffersAndInit(void);

extern unsigned int __near ram_2814;
extern unsigned int __near ram_2816;
extern unsigned int __near ram_280c;
extern unsigned int __near ram_280e;
extern unsigned int __near ram_281e;
extern unsigned char __near ram_2826;
extern unsigned char ram_210b0;
extern unsigned int ram_210b2;
extern unsigned char __near NOTEEDIT_BASE_KEY;
extern unsigned char __near ram_2774;
extern long GetTitleNow(void);

void BmDrEdit_EnterPlayMode(void)
{
	unsigned int w;

	if (CURRENT_TITLE == PREVIOUS_TITLE) return;
	ram_283c = SEQ_CYCLE_FLAGS;
	SEQ_CYCLE_FLAGS |= 1;
	if (ram_283a == 0) SEQ_TRACK_MASK = SEQ_TRACK_MASK_COPY;
	else SEQ_TRACK_MASK = ram_2963;
	Audio_CheckSubsystemReady();
	ram_251c = w = ram_2744;
	if (w > ram_251e) ram_251e = w;
	SEQ_START_MEASURE = ram_251c;
	if (SEQ_START_MEASURE != 1) SEQ_RTMCFG |= 8;
	SeqPlay_AllocBuffersAndInit();
}

void BmDrEdit_CalcSecondaryPosition(void)
{
	unsigned int lim;
	unsigned int w;

	ram_281e = (ram_2814 * 0x60 + ram_2816) - (ram_280c * 0x60 + ram_280e);
	ram_210b0 -= ram_2826;
	if (GetTitleNow() == 0x1a00095L) {
		if (NOTEEDIT_BASE_KEY == 0) ram_210b0 += 3;
	} else {
		ram_210b0 = 11 - ram_210b0;
	}
	lim = ram_2774 * 0x60 - 1;
	w = ram_281e;
	if (w + ram_210b2 <= lim) return;
	ram_210b2 = lim - w;
}
