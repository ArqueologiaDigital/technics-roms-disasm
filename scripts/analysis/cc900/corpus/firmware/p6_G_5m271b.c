/* Phase 6, lane_p6 helper G, round 5, module 271 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a: view
   procs of ui/ui_window_procs.s, refined after run 2026-11-16-87-p6-r15 (EditSwProc and FrameProc matched there and
   are kept unchanged; LabelProc is EditSwProc's calr callee).  This is form b; form a (p6_G_5m271a.c) has the same
   names.  Here PsRadioBoxProc's EVT_PARA_DRAW case keeps its instance in a variable of its own, declared first: the
   ROM's frame has three pointer slots (+4 that case's instance, +8 / +12 temporaries and the other cases' instance)
   where V4.23 gave form a two.
   Run 87: (1) `(struct rect *)&r.x1` as the first argument makes V4.23 compute it before the stack pushes, as the
   ROM does (LabelProc); (2) V4.23 pushes adecl stack arguments from the 4th on, so the 4th is the FIRST pushed: the
   ROM's push order, read top to bottom, is the prototype's order from the 4th argument (DrawStringReverse /
   DrawStringAlignment had it reversed in rounds 3 / 4); (3) a pointer-typed member is loaded after the pushes, a
   cast one before (LabelProc's text).
   Event codes are their .equ values from v10/maincpu/shared/event_codes.s. */
/* cc900-module: LabelProc DrawDesignFrame VwBoxProc GetEditSwPoint DrawEditSw GetClientBox GetBoxCenter GetDialFocus */

#define EVT_SW_IN             0x1c00007L
#define EVT_DRAW              0x1c0000dL
#define EVT_SELE_DRAW         0x1c0000eL
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_INDEXSW_UP        0x1c00017L
#define EVT_INDEXSW_DOWN      0x1c00018L
#define EVT_INDEX_SELECT      0x1c0001bL
#define EVT_I_AM_SELECTED     0x1c00029L
#define EVT_YOU_ARE_SELECTED  0x1c0002aL
#define EVT_CHANGE_DIAL_FOCUS 0x1c0002cL
#define EVT_MAKE_EDIT_SW_ID   0x1e00029L
#define EVT_GET_STRING        0x1e0003aL
#define EVT_SET_SELECTED      0x1e0004dL
#define EVT_DRAW_SELECTED     0x1e0004eL
#define EVT_CHECK_EDIT_SW     0x1e00053L

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };

struct vinst { unsigned char pad[14]; struct rect r; char *str; long l26; int i30; };
/* an edit switch's instance: id at +32, its ApFunction at +34, the dial step at +38 (-1: none) */
struct esinst { unsigned char pad[32]; unsigned int id; long func; int dial; };
/* a frame's instance: box at +14, three drawing parameters at +22 / +24 / +26 */
struct frinst { unsigned char pad[14]; struct rect r; int i22, i24, i26; };
/* a radio box's instance */
struct rbinst {
	unsigned char pad[22]; int i22; int i24; int index; long font; int i32; unsigned char b34; unsigned char pad35;
	unsigned int swid; int *value; unsigned int sub;
};

/* module 271 (calr) */
extern long VwBoxProc(long, long, long);
extern void GetEditSwPoint(unsigned int, struct pt *);
extern void DrawEditSw(unsigned int);
extern void GetClientBox(long, struct rect *);
extern void GetBoxCenter(struct rect *, struct pt *);
extern long GetDialFocus(void);
extern void DrawDesignFrame(struct rect *, int, int, int);
/* elsewhere (call) */
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern int GetVisible(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern void DrawStringReverse(struct rect *, struct pt *, char *, long, int, int, int, int);
extern void DrawStringAlignment(struct rect *, struct pt *, char *, long, int, int, int);
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);
extern char *__cdecl Strcpy(char *, char *);

long LabelProc(long obj, long evt, long p)
{
	struct pt pt;
	struct rect r;
	struct vinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	r = h->r;
	pt.x = h->r.x1 + 2;
	pt.y = h->r.y1 + 1;
	DrawString((struct rect *)&r.x1, &pt, h->str, h->l26, h->i30, 0xf7);
	return 0;
}

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

long FrameProc(long obj, long evt, long p)
{
	struct frinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	if (GetVisible(obj) == 0) return 1;
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	DrawDesignFrame(&h->r, h->i22, h->i24, h->i26);
	return 0;
}

long PsRadioBoxProc(long obj, long evt, long p)
{
	struct rbinst *v;
	struct rect box;
	struct pt pt;
	char buf[256];
	struct rbinst *h;

	switch (evt) {
	case EVT_DRAW:
		VwBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		GetEditSwPoint(h->swid, &pt);
		if (pt.y != 0xef) DrawEditSw(h->swid);
		SendEvent(obj, EVT_PARA_DRAW, 0);
		SendEvent(obj, EVT_SELE_DRAW, 0);
		break;
	case EVT_PARA_DRAW:
		VwBoxProc(obj, evt, p);
		GetClientBox(obj, &box);
		GetBoxCenter(&box, &pt);
		v = GetViewInstance(obj);
		if (p == 0) {
			SendEvent(obj, EVT_GET_STRING, (long)buf);
			if (buf[0] == 0) break;
		} else
			Strcpy(buf, (char *)p);
		if (GetDialFocus() == obj)
			DrawStringReverse(&box, &pt, buf, v->font, v->i32, v->i22, v->b34, 1);
		else
			DrawStringReverse(&box, &pt, buf, v->font, v->i32, v->i22, v->b34, 0);
		break;
	case EVT_SELE_DRAW:
		h = GetViewInstance(obj);
		if (GetDialFocus() == obj) {
			SendEvent(obj, EVT_DRAW_SELECTED, 0);
			SendEvent(obj, EVT_PARA_DRAW, 0);
		} else
			SendEvent(obj, EVT_DRAW_SELECTED, (long)*h->value);
		break;
	case EVT_CHANGE_DIAL_FOCUS:
		VwBoxProc(obj, evt, p);
		if (GetDialFocus() == obj)
			SendEvent(obj, EVT_SELE_DRAW, 0);
		else if (*((struct rbinst *)GetViewInstance(obj))->value == 1)
			SendEvent(obj, EVT_SELE_DRAW, 0);
		break;
	case EVT_SW_IN:
		h = GetViewInstance(obj);
		if (SendEvent(obj, EVT_CHECK_EDIT_SW, p) != 0 && h->index != -1) {
			SendEvent(obj, EVT_SET_SELECTED, 1);
			break;
		}
		return VwBoxProc(obj, evt, p);
	case EVT_INDEX_SELECT:
		VwBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		if (h->index == p && *h->value != 0)
			SendEvent(obj, EVT_SET_SELECTED, 0);
		break;
	case EVT_YOU_ARE_SELECTED:
		VwBoxProc(obj, evt, p);
		h = GetViewInstance(obj);
		if (h->index != -1 && h->index == (unsigned int)((unsigned long)p >> 16) && h->sub == (unsigned int)p)
			SendEvent(obj, EVT_SET_SELECTED, 1);
		break;
	case EVT_SET_SELECTED:
		h = GetViewInstance(obj);
		if (*h->value == p) break;
		if ((int)p == 1) {
			SendEvent(-1L, EVT_INDEX_SELECT, (long)h->index);
			SendEvent(-1L, EVT_I_AM_SELECTED, ((unsigned long)(unsigned int)h->index << 16) + h->sub);
		}
		*h->value = (int)p;
		SendEvent(obj, EVT_SELE_DRAW, 0);
		break;
	case EVT_GET_STRING:
		*(char *)p = 0;
		break;
	case EVT_CHECK_EDIT_SW:
		h = GetViewInstance(obj);
		return h->swid == SendEvent(0x2600024L, EVT_MAKE_EDIT_SW_ID, p);
	default:
		return VwBoxProc(obj, evt, p);
	}
	return 0;
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
		DrawStringAlignment(&box, &pt, buf, h->font, h->i32, h->i22, h->b34);
		return 0;
	case EVT_GET_STRING:
		*(char *)p = 0;
		return 0;
	}
	return VwBoxProc(obj, evt, p);
}
