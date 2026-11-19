/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m234a.c (2026-11-19-15-p6-r42)
   sha256 d7efe7eef9f2d9d9a7938278db54022cb6ec94fce706eeaafc7243941223c5ad (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near ram_251c;
extern unsigned char __near SEQ_RTMCFG;
extern void NoteEditSy_SendModeScrollReset(void);
extern void AccWrap_PlayModeDispatch(void);
extern void SeqVoice_UpdateSubBlockAssign(unsigned int);
extern void Chan_SetActiveBit(unsigned int, unsigned int);
extern void Audio_CheckSubsystemReady(void);
void SeqVoice_ActivateWithBarSync(unsigned char t)
{
	if (SEQ_TRACK_MASK == 0) {
		if ((SEQ_CYCLE_FLAGS & 0x01) && SEQ_START_MEASURE > ram_251c)
			SEQ_START_MEASURE = ram_251c;
		else
			SEQ_START_MEASURE = 1;
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
