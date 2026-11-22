/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_22r2m232a.c (2026-11-21-21-p6-r66)
   sha256 0b4d0aab6bac0e5ba408e8121778b1c585ea2fcb78207abd2652f0081e3e5e2e (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_SET_SELECTED 0x1e0004dL
extern unsigned char __near ram_d3e;
extern long InheritedProc(long, long, long);
extern unsigned char *GetViewInstance(long);
long AcModeSelBoxProc(long obj, long evt, long param)
{
	switch (evt) {
	default:
		return InheritedProc(obj, evt, param);
	case EVT_SET_SELECTED:
		InheritedProc(obj, evt, param);
		if (param == 1) ram_d3e = GetViewInstance(obj)[0x32];
		break;
	}
	return 0;
}
