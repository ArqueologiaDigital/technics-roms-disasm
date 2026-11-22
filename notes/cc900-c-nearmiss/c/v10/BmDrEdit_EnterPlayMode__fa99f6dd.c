/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_32r1m232a.c (2026-11-22-17-p6-r84)
   sha256 fa99f6ddac979e37ac6107de1619feb77fcd03e5134be89f31c593f4ebe8dd99 (tar-sha256); compiled at -O3 -Xr */
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
