/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m235.c (2026-11-17-6-p6-r30-staged)
   sha256 7f8be350a054c3aa68a370d20e8e543f8229697ef6cc7788cc6a62e83e64ca68 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
#define MD_SEQ_REAL              0xb
extern void SeqPlay_SaveStateAndCleanup(void);
extern void CtrlPanel_SetIndicatorBit(unsigned int);
extern unsigned char SeqStatus_CheckBit2(void);
extern void Part_WriteAllVoiceSubBlocks_A();
extern void Part_WriteAllVoiceSubBlocks_B();
extern void Part_WriteWord();
extern void Part_ReleaseVoicesForRange();
extern void Audio_CheckSubsystemReady(void);
extern void AccWrap_PositionClear(void);
extern void Part_DetectSingleVoiceType(void);
extern void UI_ChangeModeByIndex(unsigned int);
extern unsigned char __near ram_1d8e;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near ram_288a;
extern unsigned int SEQ_TRACK_MASK_COPY;
extern unsigned char __near ram_26e2;
void MainExe_SequencerStop(void)
{
	ram_1d8e = 0;
	SeqPlay_SaveStateAndCleanup();
	CtrlPanel_SetIndicatorBit(0x4c);
	SEQ_CYCLE_FLAGS &= ~2;
	if (SeqStatus_CheckBit2() == 0) Part_WriteAllVoiceSubBlocks_A(0);
	else Part_WriteAllVoiceSubBlocks_B(0);
	Part_WriteWord(0, 0x50, 0xffff);
	Part_ReleaseVoicesForRange(0, 0x32);
	SEQ_TRACK_MASK = 0;
	Audio_CheckSubsystemReady();
	AccWrap_PositionClear();
	ram_288a &= ~1;
	SEQ_TRACK_MASK_COPY = 0;
	ram_26e2 = 1;
	Part_DetectSingleVoiceType();
	UI_ChangeModeByIndex(MD_SEQ_REAL);
}
