/* Phase 6, lane_p6 helper G, round 4, module 271 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a: the
   parameter-box procs of ui/ui_window_procs.s: PsParaBoxProc and the procs built on it (AcLswBoxProc, AcRamBoxProc,
   AcTempoBoxProc), and AcListBoxProc (built on PsListBoxProc).  This is form b; form a (p6_G_4m271a.c) has the same
   names with other shapes (here: AcRamBoxProc's compare order, AcListBoxProc's dial blocks nested in an if,
   AcLswBoxProc's request compare reversed).  Shapes follow what matched at -O3 -Xr in runs 45 / 68: struct / array locals take frame slots from the
   top down in declaration order; switch compares run in reverse case order, the bodies in case order; a `default:`
   inside the switch puts the first case's body after the compares (the last compare inverted), a return after the
   switch puts the default code there.
   Event codes are their .equ values from v10/maincpu/shared/event_codes.s. */
/* cc900-module: GetBoxCenter GetClientBox MainLswGet MainRamGet PsListBoxProc PsParaBoxProc SetAutoInc SetDialDown SetDialEnable SetDialUp VwBoxProc */

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
#define EVT_RAM_DATA          0x1c0001dL
#define EVT_GET_STRING        0x1e0003aL
#define EVT_CALC_PARAM        0x1e0003dL
#define EVT_GET_LARGE_STEP    0x1e0003eL
#define EVT_GET_SMALL_STEP    0x1e0003fL
#define EVT_GET_LSW_ADDRESS   0x1e00040L
#define EVT_GET_LSW_STRING    0x1e00042L
#define EVT_GET_RAM_ADDRESS   0x1e00045L
#define EVT_GET_RAM_SIZE      0x1e00046L
#define EVT_GET_RAM_STRING    0x1e00047L
#define EVT_SET_SELECTED      0x1e0004dL
#define EVT_CHECK_INDEX       0x1e00050L
#define EVT_RAM_DATA_REQ      0x1e00082L
#define EVT_LSW_DATA_REQ      0x1e00083L
#define EVT_GET_SELECTED      0x1e00090L
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };

/* a parameter box's instance */
struct pbinst {
	unsigned char pad[22]; int i22; int i24; int index; long font; int i32; unsigned char b34; unsigned char pad35;
	long func; void *value;
};
/* a list box's instance: dial step at +26, its text at +42, dials enabled at +46 */
struct lbinst { unsigned char pad[26]; int index; unsigned char pad2[14]; char *str; int dials; };
/* the requests AcLswBoxProc / AcRamBoxProc pass with EVT_GET_*_STRING (and receive with EVT_*_DATA) */
struct lswreq { long addr; int val; int pad; long str; };
struct ramreq { long addr; unsigned char pad[10]; long val; long str; };

/* module 271 (calr) */
extern long VwBoxProc(long, long, long);
extern long PsParaBoxProc(long, long, long);
extern long PsListBoxProc(long, long, long);
extern void GetClientBox(long, struct rect *);
extern void GetBoxCenter(struct rect *, struct pt *);
extern int MainLswGet(long);
extern int MainRamGet(long, int);
extern void SetDialUp(long, long, long);
extern void SetDialDown(long, long, long);
extern void SetAutoInc(long, long, long);
extern void SetDialEnable(unsigned int);
/* elsewhere (call) */
extern void *GetViewInstance(long);
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);
extern void DrawStringAlignment(struct rect *, struct pt *, char *, int, int, int, long);
extern int SndParam_LookupReadOnly(long);
extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);

extern char AcTempoBox_MatchTempoID_Str_aa_Fmt3d[], AcTempoBox_CopyTempoString_Str_aa[];

long PsParaBoxProc(long obj, long evt, long p)
{
	struct rect box;
	struct pt pt;
	char buf[256];
	struct pbinst *h;

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
		DrawStringAlignment(&box, &pt, buf, h->b34, h->i22, h->i32, h->font);
		return 0;
	case EVT_GET_STRING:
		*(char *)p = 0;
		return 0;
	}
	return VwBoxProc(obj, evt, p);
}

long AcLswBoxProc(long obj, long evt, long p)
{
	struct lswreq req;
	struct pbinst *h;

	switch (evt) {
	case EVT_GET_STRING:
		h = GetViewInstance(obj);
		req.addr = ApFuncCall(h->func, EVT_GET_LSW_ADDRESS, 0);
		req.val = *(int *)h->value;
		req.str = p;
		ApFuncCall(h->func, EVT_GET_LSW_STRING, (long)&req);
		break;
	case EVT_SHOW:
		PsParaBoxProc(obj, evt, p);
		break;
	case EVT_HIDE:
		PsParaBoxProc(obj, evt, p);
		break;
	case EVT_PAINT:
	case EVT_REPAINT:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		MainLswGet(ApFuncCall(h->func, EVT_GET_LSW_ADDRESS, 0));
		break;
	case EVT_LSW_DATA:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		if (ApFuncCall(h->func, EVT_GET_LSW_ADDRESS, 0) == ((struct lswreq *)p)->addr) {
			*(int *)h->value = ((struct lswreq *)p)->val;
			ApFuncCall(h->func, EVT_LSW_DATA_REQ, (long)*(int *)h->value);
			SendEvent(obj, EVT_PARA_DRAW, 0);
		}
		break;
	case EVT_INDEXSW_UP_AIC:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, ApFuncCall(h->func, EVT_GET_LARGE_STEP, 0));
		break;
	case EVT_INDEXSW_UP:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, ApFuncCall(h->func, EVT_GET_SMALL_STEP, 0));
		break;
	case EVT_INDEXSW_DOWN_AIC:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, -ApFuncCall(h->func, EVT_GET_LARGE_STEP, 0));
		break;
	case EVT_INDEXSW_DOWN:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, -ApFuncCall(h->func, EVT_GET_SMALL_STEP, 0));
		break;
	default:
		return PsParaBoxProc(obj, evt, p);
	}
	return 0;
}

long AcRamBoxProc(long obj, long evt, long p)
{
	long addr;
	struct ramreq req;
	struct pbinst *h;
	struct ramreq *r;

	switch (evt) {
	case EVT_GET_STRING:
		h = GetViewInstance(obj);
		req.addr = ApFuncCall(h->func, EVT_GET_RAM_ADDRESS, 0);
		req.val = *(long *)h->value;
		req.str = p;
		ApFuncCall(h->func, EVT_GET_RAM_STRING, (long)&req);
		break;
	case EVT_PAINT:
	case EVT_REPAINT:
		PsParaBoxProc(obj, evt, p);
		/* fall through */
	case EVT_REFRESH_PARA_DRAW:
		h = GetViewInstance(obj);
		addr = ApFuncCall(h->func, EVT_GET_RAM_ADDRESS, 0);
		MainRamGet(addr, (int)ApFuncCall(h->func, EVT_GET_RAM_SIZE, 0));
		break;
	case EVT_RAM_DATA:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		addr = ApFuncCall(h->func, EVT_GET_RAM_ADDRESS, 0);
		r = (struct ramreq *)p;
		if (addr == r->addr) {
			*(long *)h->value = r->val;
			ApFuncCall(h->func, EVT_RAM_DATA_REQ, *(long *)h->value);
			SendEvent(obj, EVT_PARA_DRAW, 0);
		}
		break;
	case EVT_INDEXSW_UP_AIC:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, ApFuncCall(h->func, EVT_GET_LARGE_STEP, 0));
		break;
	case EVT_INDEXSW_UP:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, ApFuncCall(h->func, EVT_GET_SMALL_STEP, 0));
		break;
	case EVT_INDEXSW_DOWN_AIC:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, -ApFuncCall(h->func, EVT_GET_LARGE_STEP, 0));
		break;
	case EVT_INDEXSW_DOWN:
		PsParaBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_CALC_PARAM, -ApFuncCall(h->func, EVT_GET_SMALL_STEP, 0));
		break;
	default:
		return PsParaBoxProc(obj, evt, p);
	}
	return 0;
}

long AcTempoBoxProc(long obj, long evt, long p)
{
	char buf[256];

	switch (evt) {
	case EVT_SHOW:
		PsParaBoxProc(obj, evt, p);
		return 0;
	case EVT_HIDE:
		PsParaBoxProc(obj, evt, p);
		return 0;
	case EVT_PAINT:
	case EVT_REPAINT:
		PsParaBoxProc(obj, evt, p);
		MainLswGet(4);
		return 0;
	case EVT_LSW_DATA:
		PsParaBoxProc(obj, evt, p);
		if (*(long *)p == 4 || *(long *)p == 0x2200) {
			if (SndParam_LookupReadOnly(0x2200) == 0)
				Sprintf_Locked(buf, AcTempoBox_MatchTempoID_Str_aa_Fmt3d, SndParam_LookupReadOnly(4));
			else
				Strcpy(buf, AcTempoBox_CopyTempoString_Str_aa);
			SendEvent(obj, EVT_PARA_DRAW, (long)buf);
		}
		return 0;
	}
	return PsParaBoxProc(obj, evt, p);
}

long AcListBoxProc(long obj, long evt, long p)
{
	struct lbinst *h;

	switch (evt) {
	case EVT_SHOW:
		PsListBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		if (h->dials != 0) {
			SetDialUp(obj, EVT_INDEXSW_DOWN, (long)h->index);
			SetDialDown(obj, EVT_INDEXSW_UP, (long)h->index);
			SetDialEnable(1);
		}
		break;
	case EVT_INDEXSW_UP_AIC:
	case EVT_INDEXSW_UP:
		PsListBoxProc(obj, evt, p);
		if (SendEvent(obj, EVT_CHECK_INDEX, p) == 0) break;
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_SET_SELECTED, (long)((int)SendEvent(obj, EVT_GET_SELECTED, 0) - 1));
		SetAutoInc(obj, EVT_INDEXSW_UP_AIC, p);
		if (h->dials != 0) {
			SetDialUp(obj, EVT_INDEXSW_DOWN, p);
			SetDialDown(obj, EVT_INDEXSW_UP, p);
			SetDialEnable(1);
		}
		break;
	case EVT_INDEXSW_DOWN_AIC:
	case EVT_INDEXSW_DOWN:
		PsListBoxProc(obj, evt, p);
		if (SendEvent(obj, EVT_CHECK_INDEX, p) == 0) break;
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_SET_SELECTED, (long)((int)SendEvent(obj, EVT_GET_SELECTED, 0) + 1));
		SetAutoInc(obj, EVT_INDEXSW_DOWN_AIC, p);
		if (h->dials != 0) {
			SetDialUp(obj, EVT_INDEXSW_DOWN, p);
			SetDialDown(obj, EVT_INDEXSW_UP, p);
			SetDialEnable(1);
		}
		break;
	case EVT_GET_STRING:
		Strcpy((char *)p, ((struct lbinst *)GetViewInstance(obj))->str);
		break;
	default:
		return PsListBoxProc(obj, evt, p);
	}
	return 0;
}
