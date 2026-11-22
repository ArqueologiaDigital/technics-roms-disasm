/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_ui_m0.c (2026-11-21-22-p6-r67)
   sha256 550ad2c4d29e45f52882d62ae4cbf787223a07272ffc562f5d9ebba01f4d4490 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_DIRECT_PLAY_MUTE         0x1e7000bL
#define EVT_GET_TOGGLE_SW            0x1e70017L
#define NAKA_MAINFUNC_MiddleFuncCall 0x147001cL
extern unsigned int ram_21086;
extern long MainFuncCall(long, long, long);
long SMFMute_GetUpperBits(void);
extern long SMFMute_GetUpperBits(void);
long DocOrchMuteFunc(long obj, long evt, long p)
{
	if (evt == EVT_GET_TOGGLE_SW)
		return SMFMute_GetUpperBits();
	if (p == 1) {
		ram_21086 |= 0xfffc;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	} else {
		ram_21086 &= 3;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	}
	return 0;
}
