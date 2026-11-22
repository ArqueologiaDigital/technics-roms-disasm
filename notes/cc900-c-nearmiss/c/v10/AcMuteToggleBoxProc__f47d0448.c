/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Y_22r1m232b.c (2026-11-21-21-p6-r66)
   sha256 f47d0448241dd354b81ee21d4d84197f0c841ba8e087238b4bc8c114fbe947f3 (tar-sha256); compiled at -Xr
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
	if (evt != EVT_SHOW)
		return InheritedProc(obj, evt, p);
	ram_2108c = ApFuncCall(((struct vi *)GetViewInstance(obj))->func, EVT_GET_TOGGLE_SW, 0L);
	SendEvent(obj, EVT_SET_PARAM, ram_2108c);
	InheritedProc(obj, evt, p);
	return 0;
}
