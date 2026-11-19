/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m234.c (2026-11-19-29-p6-r46)
   sha256 18b7cd99d8b231daba0ba4aeddb6c2117e2469124ca962e1ec140c8521983203 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_2502;
extern unsigned char __near SEQ_RTMCFG;
extern void NoteEditSy_SendModeScrollReset(void);
extern void AccWrap_PlayModeDispatch(void);
extern void SeqVoice_UpdateSubBlockAssign(unsigned int);
extern void Chan_SetActiveBit(unsigned int, unsigned int);
extern void Audio_CheckSubsystemReady(void);
void SeqVoice_ActivateWithBarSync(unsigned char t)
{
	unsigned int w;

	if (SEQ_TRACK_MASK == 0) {
		if (!(SEQ_CYCLE_FLAGS & 0x01) || SEQ_START_MEASURE <= (w = ram_2502))
			SEQ_START_MEASURE = 1;
		else
			SEQ_START_MEASURE = w;
		NoteEditSy_SendModeScrollReset();
		if (SEQ_START_MEASURE == 1)
			SEQ_RTMCFG &= ~0x08;
		else
			SEQ_RTMCFG |= 0x08;
		AccWrap_PlayModeDispatch();
	}
	SeqVoice_UpdateSubBlockAssign(t);
	Chan_SetActiveBit(t, 1);
	Audio_CheckSubsystemReady();
}
