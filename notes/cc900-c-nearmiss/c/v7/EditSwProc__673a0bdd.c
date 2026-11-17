/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_window_procs_m0.c (2026-11-16-92-p6-r18)
   sha256 673a0bdd99ca13a8eb59016c71b237363a68b5f1e69b1663f321559090ba0eb2 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
#define EVT_SW_IN             0x1c00007L
#define EVT_INDEXSW_UP        0x1c00017L
#define EVT_INDEXSW_DOWN      0x1c00018L
#define EVT_MAKE_EDIT_SW_ID   0x1e00029L
struct esinst { unsigned char pad[32]; unsigned int id; long func; int dial; };
extern void *GetViewInstance(long);
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);
extern long LabelProc(long obj, long evt, long p);
long EditSwProc(long obj, long evt, long p)
{
	struct esinst *h;

	if (evt != EVT_SW_IN) return LabelProc(obj, evt, p);
	h = GetViewInstance(obj);
	if (h->id == SendEvent(0x2600024L, EVT_MAKE_EDIT_SW_ID, p)) {
		ApFuncCall(h->func, evt, p);
		if (h->dial != -1) {
			if (p & 0x80) SendEvent(-1L, EVT_INDEXSW_DOWN, (long)h->dial);
			else SendEvent(-1L, EVT_INDEXSW_UP, (long)h->dial);
		}
		return 0;
	}
	return LabelProc(obj, evt, p);
}
