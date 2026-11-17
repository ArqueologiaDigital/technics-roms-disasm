/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_window_procs_m0.c (2026-11-16-111-p6-r22-staged)
   sha256 7d3aa481ffa9df690d518ad1de0c8064a21f839050676cab225bd106300437ea (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void *GetViewInstance(long);
extern long ApFuncCall(long, long, long);
#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
#define EVT_PAINT             0x1c0000bL
#define EVT_REPAINT           0x1c0000cL
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_INDEXSW_UP        0x1c00017L
#define EVT_INDEXSW_DOWN      0x1c00018L
#define EVT_INDEXSW_UP_AIC    0x1c00019L
#define EVT_INDEXSW_DOWN_AIC  0x1c0001aL
#define EVT_LSW_DATA          0x1c0001cL
#define EVT_GET_STRING        0x1e0003aL
#define EVT_CALC_PARAM        0x1e0003dL
#define EVT_GET_LARGE_STEP    0x1e0003eL
#define EVT_GET_SMALL_STEP    0x1e0003fL
#define EVT_GET_LSW_ADDRESS   0x1e00040L
#define EVT_GET_LSW_STRING    0x1e00042L
#define EVT_LSW_DATA_REQ      0x1e00083L
struct pbinst { unsigned char pad[36]; long func; void *value; };
struct lswreq { long addr; int val; int pad; long str; };
extern long PsParaBoxProc(long, long, long);
extern int MainLswGet(long);
extern long SendEvent(long, long, long);
extern long PsParaBoxProc(long obj, long evt, long p);
long AcLswBoxProc(long obj, long evt, long p)
{
	struct lswreq req;
	struct pbinst *h;
	int **pv;

	switch (evt) {
	case EVT_GET_STRING:
		h = GetViewInstance(obj);
		req.addr = ApFuncCall(h->func, EVT_GET_LSW_ADDRESS, 0);
		req.val = *(int *)h->value;
		req.str = p;
		ApFuncCall(h->func, EVT_GET_LSW_STRING, (long)&req);
		return 0;
	case EVT_SHOW:
		PsParaBoxProc(obj, evt, p);
		return 0;
	case EVT_HIDE:
		PsParaBoxProc(obj, evt, p);
		return 0;
	case EVT_PAINT:
	case EVT_REPAINT:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		MainLswGet(ApFuncCall(h->func, EVT_GET_LSW_ADDRESS, 0));
		return 0;
	case EVT_LSW_DATA:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		if (((struct lswreq *)p)->addr == ApFuncCall(h->func, EVT_GET_LSW_ADDRESS, 0)) {
			pv = (int **)&h->value;
			**pv = ((struct lswreq *)p)->val;
			ApFuncCall(h->func, EVT_LSW_DATA_REQ, (long)**pv);
			SendEvent(obj, EVT_PARA_DRAW, 0);
		}
		return 0;
	case EVT_INDEXSW_UP_AIC:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, ApFuncCall(h->func, EVT_GET_LARGE_STEP, 0));
		return 0;
	case EVT_INDEXSW_UP:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, ApFuncCall(h->func, EVT_GET_SMALL_STEP, 0));
		return 0;
	case EVT_INDEXSW_DOWN_AIC:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, -ApFuncCall(h->func, EVT_GET_LARGE_STEP, 0));
		return 0;
	case EVT_INDEXSW_DOWN:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, -ApFuncCall(h->func, EVT_GET_SMALL_STEP, 0));
		return 0;
	default:
		return PsParaBoxProc(obj, evt, p);
	}
}
