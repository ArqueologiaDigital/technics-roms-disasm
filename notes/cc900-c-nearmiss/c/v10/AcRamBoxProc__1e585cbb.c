/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_12m271b.c (2026-11-17-2-p6-r29)
   sha256 1e585cbb13957572b3960a1f722d7447f56482eadfcb3226ba6c78ed47e9ef62 (tar-sha256); compiled at -O3 -Xr */
#define EVT_PAINT             0x1c0000bL
#define EVT_REPAINT           0x1c0000cL
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_INDEXSW_UP        0x1c00017L
#define EVT_INDEXSW_DOWN      0x1c00018L
#define EVT_INDEXSW_UP_AIC    0x1c00019L
#define EVT_INDEXSW_DOWN_AIC  0x1c0001aL
#define EVT_RAM_DATA          0x1c0001dL
#define EVT_GET_STRING        0x1e0003aL
#define EVT_CALC_PARAM        0x1e0003dL
#define EVT_GET_LARGE_STEP    0x1e0003eL
#define EVT_GET_SMALL_STEP    0x1e0003fL
#define EVT_GET_RAM_ADDRESS   0x1e00045L
#define EVT_GET_RAM_SIZE      0x1e00046L
#define EVT_GET_RAM_STRING    0x1e00047L
#define EVT_RAM_DATA_REQ      0x1e00082L
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L
struct pbinst { unsigned char pad[36]; long func; void *value; };
struct ramreq { unsigned char *addr; unsigned char pad[10]; long val; long str; };
extern long PsParaBoxProc(long, long, long);
extern int MainRamGet(long, int);
extern void *GetViewInstance(long);
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);
long AcRamBoxProc(long obj, long evt, long p)
{
	long addr;
	struct ramreq req;
	struct pbinst *h;
	unsigned long **pv;

	switch (evt) {
	case EVT_GET_STRING:
		h = GetViewInstance(obj);
		req.addr = (unsigned char *)ApFuncCall(h->func, EVT_GET_RAM_ADDRESS, 0);
		req.val = *(long *)h->value;
		req.str = p;
		ApFuncCall(h->func, EVT_GET_RAM_STRING, (long)&req);
		return 0;
	case EVT_PAINT:
	case EVT_REPAINT:
		PsParaBoxProc(obj, evt, p);
		/* fall through */
	case EVT_REFRESH_PARA_DRAW:
		h = GetViewInstance(obj);
		addr = ApFuncCall(h->func, EVT_GET_RAM_ADDRESS, 0);
		MainRamGet(addr, (int)ApFuncCall(h->func, EVT_GET_RAM_SIZE, 0));
		return 0;
	case EVT_RAM_DATA:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		if ((unsigned long)((struct ramreq *)p)->addr == ApFuncCall(h->func, EVT_GET_RAM_ADDRESS, 0)) {
			pv = (unsigned long **)&h->value;
			**pv = ((struct ramreq *)p)->val;
			ApFuncCall(h->func, EVT_RAM_DATA_REQ, (long)**pv);
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
