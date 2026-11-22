/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Y_22r1m232c.c (2026-11-21-21-p6-r66)
   sha256 1e6567c08c715fc9d94212fe454b41a0e7eaab4abc9ab89cfa1ba7c7391bfba7 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_SHOW                     0x1c00001L
#define EVT_SET_PARAM                0x1e0003bL
#define EVT_GET_TOGGLE_SW            0x1e70017L
struct vi { unsigned char pad[40]; long func; };
extern long ram_2108c;
extern long InheritedProc(long, long, long);
extern void *GetViewInstance(long);
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);
long AcMuteToggleBoxProc(long obj, long evt, long p)
{
	long v;

	if (evt != EVT_SHOW)
		return InheritedProc(obj, evt, p);
	v = ApFuncCall(((struct vi *)GetViewInstance(obj))->func, EVT_GET_TOGGLE_SW, 0L);
	ram_2108c = v;
	SendEvent(obj, EVT_SET_PARAM, v);
	InheritedProc(obj, evt, p);
	return 0;
}
