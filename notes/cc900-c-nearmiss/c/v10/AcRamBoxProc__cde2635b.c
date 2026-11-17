/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_G_9m271a.c (2026-11-16-118-p6-r23)
   sha256 cde2635b277f378297f1a5f59ab742c1192174f4999cf9c4f1bafecb2b2a98b7 (tar-sha256); compiled at -Xr */
/* Phase 6, lane_p6 helper G, round 9, module 271 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a.  The close
   misses of run 2026-11-16-107-p6-r21 (AcListBoxProc, AcLswBoxProc and DrawEditSw matched there and are not repeated).
   Form b (p6_G_9m271b.c) has the same functions; c holds AcTempoBoxProc alone, d a third AcRamBoxProc.
   - AcRamBoxProc (+17), two spots in EVT_RAM_DATA:
     1. the ROM loads the event parameter into XIX after ApFuncCall and compares a register copy of the request's
        address with the result (V4.23 kept the parameter in XWA and compared from memory).  Here the result goes to
        `addr` and the parameter to a request pointer `r` AFTER the call, so `r` lives only where no call intervenes.
     2. after storing through the value cell's pointer the ROM re-reads that pointer from `&h->value` (kept in XDE),
        as AcLswBoxProc's matching form does; here V4.23 kept it in XBC.  Form a keeps AcLsw's pointer-to-pointer
        local unchanged (to see spot 1 alone), form b makes it `long * volatile *`.
   - PsRadioBoxProc (+33), four spots:
     1. EVT_PARA_DRAW: the hoisted first argument (&box) is in XWA in the ROM, XBC here.  Unchanged in both forms.
     2. EVT_YOU_ARE_SELECTED: the ROM clears QBC after the 16-bit shift (an `& 0xffff` on the long) and loads the
        sub-index into BC for a register compare: HIWORD / LOWORD macros, with the mask (form a) or LOWORD a plain cast
        written on the left of `==` (form b).
     3. EVT_SET_SELECTED: the ROM computes the event word straight into XDE (`ld xde,xwa; add xde,xbc`); V4.23 added
        in XWA, then moved: the sum here is a signed long (no unsigned->long conversion between it and the argument).
     4. EVT_CHECK_EDIT_SW: the ROM widens the comparison's result with extz: an unsigned int cast.
   - PsParaBoxProc (+150): the ROM computes &box into XWA and &pt into XHL before the pushes (push temporary XBC).
     Round 7's form b (only &box spelled as a member address) gave &box in XWA and XBC for the pushes but &pt late;
     here &pt is a member address too and the text stays a plain array (form a) or a cast array (form b).
   Event codes are their .equ values from v10/maincpu/shared/event_codes.s. */
/* cc900-module: DrawEditSw GetBoxCenter GetClientBox GetDialFocus GetEditSwPoint MainRamGet PsParaBoxProc VwBoxProc */

#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
#define EVT_SW_IN             0x1c00007L
#define EVT_PAINT             0x1c0000bL
#define EVT_REPAINT           0x1c0000cL
#define EVT_DRAW              0x1c0000dL
#define EVT_SELE_DRAW         0x1c0000eL
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_INDEXSW_UP        0x1c00017L
#define EVT_INDEXSW_DOWN      0x1c00018L
#define EVT_INDEXSW_UP_AIC    0x1c00019L
#define EVT_INDEXSW_DOWN_AIC  0x1c0001aL
#define EVT_INDEX_SELECT      0x1c0001bL
#define EVT_RAM_DATA          0x1c0001dL
#define EVT_I_AM_SELECTED     0x1c00029L
#define EVT_YOU_ARE_SELECTED  0x1c0002aL
#define EVT_CHANGE_DIAL_FOCUS 0x1c0002cL
#define EVT_MAKE_EDIT_SW_ID   0x1e00029L
#define EVT_GET_STRING        0x1e0003aL
#define EVT_CALC_PARAM        0x1e0003dL
#define EVT_GET_LARGE_STEP    0x1e0003eL
#define EVT_GET_SMALL_STEP    0x1e0003fL
#define EVT_GET_RAM_ADDRESS   0x1e00045L
#define EVT_GET_RAM_SIZE      0x1e00046L
#define EVT_GET_RAM_STRING    0x1e00047L
#define EVT_SET_SELECTED      0x1e0004dL
#define EVT_DRAW_SELECTED     0x1e0004eL
#define EVT_CHECK_EDIT_SW     0x1e00053L
#define EVT_RAM_DATA_REQ      0x1e00082L
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L

#define HIWORD(l) ((unsigned int)(((unsigned long)(l) >> 16) & 0xffff))
#define LOWORD(l) ((unsigned int)((unsigned long)(l) & 0xffff))

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };

/* a radio / parameter box's instance */
struct rbinst {
	unsigned char pad[22]; int i22; int i24; int index; long font; int i32; unsigned char b34; unsigned char pad35;
	unsigned int swid; int *value; unsigned int sub;
};
/* a parameter box's instance (AcRam): its ApFunction at +36, the value cell at +40 */
struct pbinst { unsigned char pad[36]; long func; void *value; };
/* the request AcRamBoxProc passes with EVT_GET_RAM_STRING (and receives with EVT_RAM_DATA) */
struct ramreq { long addr; unsigned char pad[10]; long val; long str; };

/* module 271 (calr) */
extern long VwBoxProc(long, long, long);
extern long PsParaBoxProc(long, long, long);
extern void GetEditSwPoint(unsigned int, struct pt *);
extern void DrawEditSw(unsigned int);
extern void GetClientBox(long, struct rect *);
extern void GetBoxCenter(struct rect *, struct pt *);
extern long GetDialFocus(void);
extern int MainRamGet(long, int);
/* elsewhere (call) */
extern void *GetViewInstance(long);
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);
extern void DrawStringReverse(struct rect *, struct pt *, char *, long, int, int, int, int);
extern void DrawStringAlignment(struct rect *, struct pt *, char *, long, int, int, int);
extern char *__cdecl Strcpy(char *, char *);

long PsRadioBoxProc(long obj, long evt, long p)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	struct rbinst *h;

	switch (evt) {
	case EVT_DRAW:
		VwBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		GetEditSwPoint(h->swid, (struct pt *)&pt.x);
		if (pt.y != 0xef) DrawEditSw(h->swid);
		SendEvent(obj, EVT_PARA_DRAW, 0);
		SendEvent(obj, EVT_SELE_DRAW, 0);
		return 0;
	case EVT_PARA_DRAW:
		VwBoxProc(obj, evt, p);
		GetClientBox(obj, &box);
		GetBoxCenter(&box, &pt);
		h = GetViewInstance(obj);
		if (p == 0) {
			SendEvent(obj, EVT_GET_STRING, (long)buf);
			if (buf[0] == 0) return 0;
		} else
			Strcpy(buf, (char *)p);
		if (GetDialFocus() == obj)
			DrawStringReverse(&box, (struct pt *)&pt.x, &buf[0], h->font, h->i32, h->i22, h->b34, 1);
		else
			DrawStringReverse(&box, (struct pt *)&pt.x, &buf[0], h->font, h->i32, h->i22, h->b34, 0);
		return 0;
	case EVT_SELE_DRAW:
		h = GetViewInstance(obj);
		if (GetDialFocus() == obj) {
			SendEvent(obj, EVT_DRAW_SELECTED, 0);
			SendEvent(obj, EVT_PARA_DRAW, 0);
		} else
			SendEvent(obj, EVT_DRAW_SELECTED, (long)*h->value);
		return 0;
	case EVT_CHANGE_DIAL_FOCUS:
		VwBoxProc(obj, evt, p);
		if (GetDialFocus() == obj)
			SendEvent(obj, EVT_SELE_DRAW, 0);
		else if (*((struct rbinst *)GetViewInstance(obj))->value == 1)
			SendEvent(obj, EVT_SELE_DRAW, 0);
		return 0;
	case EVT_SW_IN:
		h = GetViewInstance(obj);
		if (SendEvent(obj, EVT_CHECK_EDIT_SW, p) != 0 && h->index != -1) {
			SendEvent(obj, EVT_SET_SELECTED, 1);
			return 0;
		}
		return VwBoxProc(obj, evt, p);
	case EVT_INDEX_SELECT:
		VwBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		if (h->index == p && *h->value != 0)
			SendEvent(obj, EVT_SET_SELECTED, 0);
		return 0;
	case EVT_YOU_ARE_SELECTED:
		VwBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		if (h->index != -1 && h->index == HIWORD(p) && h->sub == LOWORD(p))
			SendEvent(obj, EVT_SET_SELECTED, 1);
		return 0;
	case EVT_SET_SELECTED:
		h = GetViewInstance(obj);
		if (*h->value == p) return 0;
		if ((int)p == 1) {
			SendEvent(-1L, EVT_INDEX_SELECT, (long)h->index);
			SendEvent(-1L, EVT_I_AM_SELECTED, ((long)(unsigned int)h->index << 16) + (long)h->sub);
		}
		*h->value = (int)p;
		SendEvent(obj, EVT_SELE_DRAW, 0);
		return 0;
	case EVT_GET_STRING:
		*(char *)p = 0;
		return 0;
	case EVT_CHECK_EDIT_SW:
		h = GetViewInstance(obj);
		return (unsigned int)(h->swid == SendEvent(0x2600024L, EVT_MAKE_EDIT_SW_ID, p));
	default:
		return VwBoxProc(obj, evt, p);
	}
}

long AcRamBoxProc(long obj, long evt, long p)
{
	long addr;
	struct ramreq req;
	struct pbinst *h;
	long **pv;
	struct ramreq *r;

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
		addr = ApFuncCall(h->func, EVT_GET_RAM_ADDRESS, 0);
		r = (struct ramreq *)p;
		if (r->addr == addr) {
			pv = (long **)&h->value;
			**pv = r->val;
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

long PsParaBoxProc(long obj, long evt, long p)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	struct rbinst *h;

	switch (evt) {
	case EVT_PARA_DRAW:
		VwBoxProc(obj, evt, p);
		GetClientBox(obj, &box);
		GetBoxCenter(&box, &pt);
		h = GetViewInstance(obj);
		if (p == 0) {
			SendEvent(obj, EVT_GET_STRING, (long)buf);
			if (buf[0] == 0) return 0;
		} else
			Strcpy(buf, (char *)p);
		DrawStringAlignment((struct rect *)&box.x1, (struct pt *)&pt.x, buf, h->font, h->i32, h->i22, h->b34);
		return 0;
	case EVT_GET_STRING:
		*(char *)p = 0;
		return 0;
	}
	return VwBoxProc(obj, evt, p);
}
