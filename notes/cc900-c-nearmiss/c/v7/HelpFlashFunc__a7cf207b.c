/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m0.c (2026-11-17-6-p6-r30-staged)
   sha256 a7cf207bf1a2b45448c3a441f215711db03bc041a89706547887b8318d13a153 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
#define EVT_KUBO_FLASH_WRITE     0x1e80074L
#define EVT_KUBO_FLASH_LOAD      0x1e80075L
extern void SoundCtrl_SaveAndSendCmd_EE(unsigned int);
extern void CtrlPanel_IndicatorJumpTable(unsigned int);
extern void Audio_DispatchCommand(unsigned int);
long HelpFlashFunc(long obj, long ev)
{
	switch (ev) {
	case EVT_KUBO_FLASH_WRITE:
		SoundCtrl_SaveAndSendCmd_EE(0x25);
		CtrlPanel_IndicatorJumpTable(4);
		SoundCtrl_SaveAndSendCmd_EE(0x23);
		break;
	case EVT_KUBO_FLASH_LOAD:
		Audio_DispatchCommand(4);
		break;
	}
	return 0;
}
