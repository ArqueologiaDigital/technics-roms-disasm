/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_5m234b.c (2026-11-18-33-p6-r37)
   sha256 e02fabf59ed345a734d23a72280e1b756acb2c9d34fa008702666dea119f99ae (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned int __near ram_251c;
extern unsigned char __near ram_2324;
extern unsigned char __near ram_2664;
extern unsigned char __near ram_28ae;
extern void NoteEditSy_SendModeScrollReset(void);
extern void SeqPlay_InitStartState(void);
extern void Chan_SetActiveBit(unsigned int, unsigned int);
extern void Audio_CheckSubsystemReady(void);
void SeqPlay_HandleChannelSolo(unsigned char ch)
{
	unsigned int m;

	if (SEQ_TRACK_MASK == 0) {
		if ((SEQ_CYCLE_FLAGS & 1) && SEQ_START_MEASURE > (m = ram_251c))
			SEQ_START_MEASURE = m;
		else
			SEQ_START_MEASURE = 1;
		NoteEditSy_SendModeScrollReset();
		if (SEQ_START_MEASURE == 1)
			SEQ_RTMCFG &= ~8;
		else
			SEQ_RTMCFG |= 8;
		SeqPlay_InitStartState();
	}
	if (ch == ram_2324 && (DEMO_CONTROL_FLAGS & 0x40)) {
		ram_28ae = ram_2664;
		ram_28ae |= 0x80;
	}
	Chan_SetActiveBit(ch, 1);
	Audio_CheckSubsystemReady();
}
