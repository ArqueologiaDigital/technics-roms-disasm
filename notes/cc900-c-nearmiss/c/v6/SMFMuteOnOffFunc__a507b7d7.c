/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_ui_m0_b.c (2026-11-21-22-p6-r67)
   sha256 a507b7d7fa551fe6bb96cf0d9432c89738520876603aed1ab15b6efe11df9e77 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_TOGGLE_SW            0x1e70017L
#define EVT_DIRECT_PLAY_MUTE         0x1e7000bL
#define NAKA_MAINFUNC_MiddleFuncCall 0x147001cL
extern unsigned int ram_21086;
extern unsigned char ram_21088;
extern unsigned char ram_2108a;
extern long MainFuncCall(long, long, long);
void SqAftSet_LookupTableEntry(unsigned char a);
extern void SqAftSet_LookupTableEntry(unsigned char a);
long SMFMuteOnOffFunc(long obj, long evt, long p)
{
	if (evt == EVT_GET_TOGGLE_SW)
		return ram_21088;
	if (p == 1) {
		ram_21088 = 1;
		SqAftSet_LookupTableEntry(ram_2108a);
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	} else {
		ram_21088 = 0;
		ram_21086 = 0;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	}
	return 0;
}
