/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_ui_m0.c (2026-11-21-22-p6-r67)
   sha256 550ad2c4d29e45f52882d62ae4cbf787223a07272ffc562f5d9ebba01f4d4490 (tar-sha256); compiled at -Xr
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
