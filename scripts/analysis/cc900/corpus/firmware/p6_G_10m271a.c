/* Phase 6, lane_p6 helper G, round 10, module 271, form a: AcRamBoxProc alone.  Run 2026-11-16-118-p6-r23:
   round 9's form d (+17) still differs only in EVT_RAM_DATA; a request pointer local (forms a / b) cost XIZ and the
   frame, and a `volatile` pointer cell did not make V4.23 re-read it.  The two spots:
   1. the ROM loads the request's address into a register (`ld xwa,(xix); cp xwa,xhl`, the request in XIX) where
      V4.23 compared from memory (`cp (xwa),xhl`), as it does, and as the ROM does, in AcLswBoxProc;
   2. the ROM re-reads the value cell's pointer after the store, as AcLswBoxProc does; there the stored int is read
      back through a conversion to long.
   Both look like a type conversion in the ROM's expression where Lsw has none (1) or has one (2).  Here the
   request's address is an unsigned long and the value cell holds unsigned longs (stored from the request's long,
   passed on as long).  Form b keeps the cell long and converts only the argument; form c keeps the address long.
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
struct ramreq { unsigned long addr; unsigned char pad[10]; long val; long str; };

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
	unsigned long **pv;

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
