/* Phase 6, lane_p6 helper G, round 7, module 271 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a: round 6's
   switch procs of ui/ui_window_procs.s (PsRadioBoxProc, AcLswBoxProc, AcRamBoxProc, AcTempoBoxProc, AcListBoxProc),
   with the first-member trick that matched LabelProc / VwUserBitmapProc in run 2026-11-16-92-p6-r18 applied where
   the ROM computes an `&local` argument before the others (PsRadioBoxProc: GetEditSwPoint's point, DrawStringReverse's
   box; PsParaBoxProc: DrawStringAlignment's box, point and text), plus DrawEditSw (new).  Form b (p6_G_7m271b.c) has
   the same names.
   From round 6 (its notes):
   Run 88, read instruction by instruction: where a case ends with `break` and the switch is followed by `return 0`,
   V4.23 copies `ld xhl,0` + jump into every case; the ROM has ONE shared `ld xhl,0` that the cases jump to, placed
   after the last case and before the default.  So here every case ends in its own `return 0;` (V4.23 merges equal
   tails) and `default:` stays last inside the switch.  Also: AcRamBoxProc had one pointer local too many (frame 38
   vs 34); AcTempoBoxProc's two strings have 31-character-clashing labels, given short C names.
   Event codes are their .equ values from v10/maincpu/shared/event_codes.s. */
/* cc900-module: GetBoxCenter GetClientBox GetDialFocus GetEditSwPoint DrawEditSw MainLswGet MainRamGet PsListBoxProc PsParaBoxProc SetAutoInc SetDialDown SetDialEnable SetDialUp VwBoxProc */

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
#define EVT_LSW_DATA          0x1c0001cL
#define EVT_RAM_DATA          0x1c0001dL
#define EVT_I_AM_SELECTED     0x1c00029L
#define EVT_YOU_ARE_SELECTED  0x1c0002aL
#define EVT_CHANGE_DIAL_FOCUS 0x1c0002cL
#define EVT_MAKE_EDIT_SW_ID   0x1e00029L
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
#define EVT_DRAW_SELECTED     0x1e0004eL
#define EVT_CHECK_INDEX       0x1e00050L
#define EVT_CHECK_EDIT_SW     0x1e00053L
#define EVT_RAM_DATA_REQ      0x1e00082L
#define EVT_LSW_DATA_REQ      0x1e00083L
#define EVT_GET_SELECTED      0x1e00090L
#define EVT_REFRESH_PARA_DRAW 0x1e000a7L

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };

/* a radio box's instance */
struct rbinst {
	unsigned char pad[22]; int i22; int i24; int index; long font; int i32; unsigned char b34; unsigned char pad35;
	unsigned int swid; int *value; unsigned int sub;
};
/* a parameter box's instance (AcLsw / AcRam): its ApFunction at +36, the value cell at +40 */
struct pbinst { unsigned char pad[36]; long func; void *value; };
/* a list box's instance: dial step at +26, its text at +42, dials enabled at +46 */
struct lbinst { unsigned char pad[26]; int index; unsigned char pad2[14]; char *str; int dials; };
/* the requests AcLswBoxProc / AcRamBoxProc pass with EVT_GET_*_STRING (and receive with EVT_*_DATA) */
struct lswreq { long addr; int val; int pad; long str; };
struct ramreq { long addr; unsigned char pad[10]; long val; long str; };

/* module 271 (calr) */
extern long VwBoxProc(long, long, long);
extern long PsParaBoxProc(long, long, long);
extern long PsListBoxProc(long, long, long);
extern void GetEditSwPoint(unsigned int, struct pt *);
extern void DrawEditSw(unsigned int);
extern void GetClientBox(long, struct rect *);
extern void GetBoxCenter(struct rect *, struct pt *);
extern long GetDialFocus(void);
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
extern void DrawStringReverse(struct rect *, struct pt *, char *, long, int, int, int, int);
extern void DrawStringAlignment(struct rect *, struct pt *, char *, long, int, int, int);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern int CalcTotalWidth(char *, long);
extern int GetCharHeight(long);

/* cc900-name: sw_n7f=DrawEditSw_Str_N7f */
/* cc900-name: sw_n80=DrawEditSw_SelectVariantA_Str_N80 */
/* cc900-name: sw_n81=DrawEditSw_SelectVariantC_Str_N81 */
extern char sw_n7f[], sw_n80[], sw_n81[];
extern int SndParam_LookupReadOnly(long);
extern char *__cdecl Strcpy(char *, char *);
extern int __cdecl Sprintf_Locked(char *, char *, ...);

/* cc900-name: tempo_fmt=AcTempoBox_MatchTempoID_Str_aa_Fmt3d */
/* cc900-name: tempo_none=AcTempoBox_CopyTempoString_Str_aa */
extern char tempo_fmt[], tempo_none[];

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
			DrawStringReverse((struct rect *)&box.x1, &pt, buf, h->font, h->i32, h->i22, h->b34, 1);
		else
			DrawStringReverse((struct rect *)&box.x1, &pt, buf, h->font, h->i32, h->i22, h->b34, 0);
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
		if (h->index != -1 && h->index == (unsigned int)((unsigned long)p >> 16) && h->sub == (unsigned int)p)
			SendEvent(obj, EVT_SET_SELECTED, 1);
		return 0;
	case EVT_SET_SELECTED:
		h = GetViewInstance(obj);
		if (*h->value == p) return 0;
		if ((int)p == 1) {
			SendEvent(-1L, EVT_INDEX_SELECT, (long)h->index);
			SendEvent(-1L, EVT_I_AM_SELECTED, ((unsigned long)(unsigned int)h->index << 16) + h->sub);
		}
		*h->value = (int)p;
		SendEvent(obj, EVT_SELE_DRAW, 0);
		return 0;
	case EVT_GET_STRING:
		*(char *)p = 0;
		return 0;
	case EVT_CHECK_EDIT_SW:
		h = GetViewInstance(obj);
		return h->swid == SendEvent(0x2600024L, EVT_MAKE_EDIT_SW_ID, p);
	default:
		return VwBoxProc(obj, evt, p);
	}
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
			*(int *)h->value = ((struct lswreq *)p)->val;
			ApFuncCall(h->func, EVT_LSW_DATA_REQ, (long)*(int *)h->value);
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

long AcRamBoxProc(long obj, long evt, long p)
{
	long addr;
	struct ramreq req;
	struct pbinst *h;

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
			*(long *)h->value = ((struct ramreq *)p)->val;
			ApFuncCall(h->func, EVT_RAM_DATA_REQ, *(long *)h->value);
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
				Sprintf_Locked(buf, tempo_fmt, SndParam_LookupReadOnly(4));
			else
				Strcpy(buf, tempo_none);
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
		if (h->dials == 0) return 0;
		SetDialUp(obj, EVT_INDEXSW_DOWN, (long)h->index);
		SetDialDown(obj, EVT_INDEXSW_UP, (long)h->index);
		SetDialEnable(1);
		return 0;
	case EVT_INDEXSW_UP_AIC:
	case EVT_INDEXSW_UP:
		PsListBoxProc(obj, evt, p);
		if (SendEvent(obj, EVT_CHECK_INDEX, p) == 0) return 0;
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_SET_SELECTED, (long)((int)SendEvent(obj, EVT_GET_SELECTED, 0) - 1));
		SetAutoInc(obj, EVT_INDEXSW_UP_AIC, p);
		if (h->dials == 0) return 0;
		SetDialUp(obj, EVT_INDEXSW_DOWN, p);
		SetDialDown(obj, EVT_INDEXSW_UP, p);
		SetDialEnable(1);
		return 0;
	case EVT_INDEXSW_DOWN_AIC:
	case EVT_INDEXSW_DOWN:
		PsListBoxProc(obj, evt, p);
		if (SendEvent(obj, EVT_CHECK_INDEX, p) == 0) return 0;
		h = GetViewInstance(obj);
		SendEvent(obj, EVT_SET_SELECTED, (long)((int)SendEvent(obj, EVT_GET_SELECTED, 0) + 1));
		SetAutoInc(obj, EVT_INDEXSW_DOWN_AIC, p);
		if (h->dials == 0) return 0;
		SetDialUp(obj, EVT_INDEXSW_DOWN, p);
		SetDialDown(obj, EVT_INDEXSW_UP, p);
		SetDialEnable(1);
		return 0;
	case EVT_GET_STRING:
		Strcpy((char *)p, ((struct lbinst *)GetViewInstance(obj))->str);
		return 0;
	default:
		return PsListBoxProc(obj, evt, p);
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
		DrawStringAlignment((struct rect *)&box.x1, (struct pt *)&pt.x, &buf[0], h->font, h->i32, h->i22, h->b34);
		return 0;
	case EVT_GET_STRING:
		*(char *)p = 0;
		return 0;
	}
	return VwBoxProc(obj, evt, p);
}

/* draws an edit switch's caption beside its panel position: at the left (x = 0) or right (x = 0x13f) edge, or
   centred above the bottom row (y = 0xef); codes 0xff and 0x0f have none */
void DrawEditSw(unsigned int sw)
{
	struct rect r;
	struct pt pt;
	char s[6];
	char *t;
	int w, hg;

	if (sw == 0xff || sw == 0xf) return;
	GetEditSwPoint(sw, &pt);
	if (pt.y != 0xef) {
		if (pt.x == 0) t = sw_n7f;
		else t = sw_n80;
	} else
		t = sw_n81;
	Strcpy(s, t);
	w = CalcTotalWidth(s, 0);
	hg = GetCharHeight(0);
	if (pt.x == 0) {
		r.x1 = -2;
		r.y1 = pt.y - hg / 2;
	}
	if (pt.x == 0x13f) {
		r.x1 = 0x13e - w;
		r.y1 = pt.y - hg / 2;
	}
	if (pt.y == 0xef) {
		r.x1 = pt.x - w / 2 - 1;
		r.y1 = 0xf5 - hg;
	}
	pt.x = r.x1 + 2;
	pt.y = r.y1 + 1;
	r.x2 = w + r.x1 + 1;
	r.y2 = hg + r.y1;
	DrawString(&r, &pt, s, 0, 0xf4, 0xf7);
}
