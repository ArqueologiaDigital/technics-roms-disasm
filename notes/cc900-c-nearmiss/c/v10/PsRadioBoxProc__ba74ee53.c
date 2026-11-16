/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_9m271b.c (2026-11-16-118-p6-r23)
   sha256 ba74ee53d59e4227eda95ec4d2cc78cf9ce8ac4ea625321d5397dfe4e46e33d9 (tar-sha256); compiled at -O3 -Xr */
#define EVT_SW_IN             0x1c00007L
#define EVT_DRAW              0x1c0000dL
#define EVT_SELE_DRAW         0x1c0000eL
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_INDEX_SELECT      0x1c0001bL
#define EVT_I_AM_SELECTED     0x1c00029L
#define EVT_YOU_ARE_SELECTED  0x1c0002aL
#define EVT_CHANGE_DIAL_FOCUS 0x1c0002cL
#define EVT_MAKE_EDIT_SW_ID   0x1e00029L
#define EVT_GET_STRING        0x1e0003aL
#define EVT_SET_SELECTED      0x1e0004dL
#define EVT_DRAW_SELECTED     0x1e0004eL
#define EVT_CHECK_EDIT_SW     0x1e00053L
#define HIWORD(l) ((unsigned int)(((unsigned long)(l) >> 16) & 0xffff))
#define LOWORD(l) ((unsigned int)(l))
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct rbinst {
	unsigned char pad[22]; int i22; int i24; int index; long font; int i32; unsigned char b34; unsigned char pad35;
	unsigned int swid; int *value; unsigned int sub;
};
extern long VwBoxProc(long, long, long);
extern void GetEditSwPoint(unsigned int, struct pt *);
extern void DrawEditSw(unsigned int);
extern void GetClientBox(long, struct rect *);
extern void GetBoxCenter(struct rect *, struct pt *);
extern long GetDialFocus(void);
extern void *GetViewInstance(long);
extern long SendEvent(long, long, long);
extern void DrawStringReverse(struct rect *, struct pt *, char *, long, int, int, int, int);
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
		if (h->index != -1 && h->index == HIWORD(p) && LOWORD(p) == h->sub)
			SendEvent(obj, EVT_SET_SELECTED, 1);
		return 0;
	case EVT_SET_SELECTED:
		h = GetViewInstance(obj);
		if (*h->value == p) return 0;
		if ((int)p == 1) {
			SendEvent(-1L, EVT_INDEX_SELECT, (long)h->index);
			SendEvent(-1L, EVT_I_AM_SELECTED, (long)h->sub + ((long)(unsigned int)h->index << 16));
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
