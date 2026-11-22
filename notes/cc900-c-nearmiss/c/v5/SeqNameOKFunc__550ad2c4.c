/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_ui_m0.c (2026-11-22-1-p6-r69)
   sha256 550ad2c4d29e45f52882d62ae4cbf787223a07272ffc562f5d9ebba01f4d4490 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
#define NAKA_MAINFUNC_MiddleFuncCall 0x147001cL
extern long MainFuncCall(long, long, long);
#define EVT_GET_STRING               0x1e0003aL
#define EVT_SONG_NAME_SET            0x1e70001L
extern long SendEvent(long, long, long);
extern long GetNamingWindowID(void);
long SeqNameOKFunc(long obj, long evt, long p)
{
	SendEvent(GetNamingWindowID(), EVT_GET_STRING, 0x20c92L);
	MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_SONG_NAME_SET, 0x20c92L);
	return 0;
}
