/* Phase 6, lane_p6 helper G, round 9, module 271, form d: AcRamBoxProc alone, round 8's form a (run
   2026-11-16-107-p6-r21, +17) with only the second spot changed: the value cell's pointer is read through a
   `long * volatile *` local, so that V4.23 re-reads it from `&h->value` after the store as the ROM does (AcLswBoxProc's
   int version re-reads it without volatile).  Forms a / b (p6_G_9m271a.c, p6_G_9m271b.c) also move the event parameter
   into a request pointer after the call (the ROM's XIX).
   Event codes are their .equ values from v10/maincpu/shared/event_codes.s. */
/* cc900-module: MainRamGet PsParaBoxProc */

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

/* a parameter box's instance (AcRam): its ApFunction at +36, the value cell at +40 */
struct pbinst { unsigned char pad[36]; long func; void *value; };
/* the request AcRamBoxProc passes with EVT_GET_RAM_STRING (and receives with EVT_RAM_DATA) */
struct ramreq { long addr; unsigned char pad[10]; long val; long str; };

/* module 271 (calr) */
extern long PsParaBoxProc(long, long, long);
extern int MainRamGet(long, int);
/* elsewhere (call) */
extern void *GetViewInstance(long);
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);

long AcRamBoxProc(long obj, long evt, long p)
{
	long addr;
	struct ramreq req;
	struct pbinst *h;
	long * volatile *pv;

	switch (evt) {
	case EVT_GET_STRING:
		h = GetViewInstance(obj);
		req.addr = ApFuncCall(h->func, EVT_GET_RAM_ADDRESS, 0);
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
		if (((struct ramreq *)p)->addr == ApFuncCall(h->func, EVT_GET_RAM_ADDRESS, 0)) {
			pv = (long * volatile *)&h->value;
			**pv = ((struct ramreq *)p)->val;
			ApFuncCall(h->func, EVT_RAM_DATA_REQ, **pv);
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
