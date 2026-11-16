/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawDesignFrame DrawEditSw GetBoxCenter GetClientBox GetDialFocus GetEditSwPoint LabelProc VwBoxProc */   /* staged module names, repair_module_lines.py */

#define EVT_DRAW              0x1c0000dL
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawBitmap(struct pt *, unsigned char *);

long BitmapProc(long obj, long evt, long p)
{
	struct pt pt;
	struct vinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1;
	pt.y = h->r.y1;
	DrawBitmap(&pt, (unsigned char *)h->l22);
	return 0;
}

#define EVT_SW_IN             0x1c00007L
#define EVT_INDEXSW_UP        0x1c00017L
#define EVT_INDEXSW_DOWN      0x1c00018L
#define EVT_MAKE_EDIT_SW_ID   0x1e00029L
struct esinst { unsigned char pad[32]; unsigned int id; long func; int dial; };
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);
extern long LabelProc(long obj, long evt, long p);
extern long EditSwProc(long obj, long evt, long p);
struct frinst { unsigned char pad[14]; struct rect r; int i22, i24, i26; };
extern void DrawDesignFrame(struct rect *, int, int, int);
extern int GetVisible(long);
extern long FrameProc(long obj, long evt, long p);
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawIcons(struct pt *, long);
extern long IconProc(long obj, long evt, long p);
struct lineinst { unsigned char pad[14]; int x1, y1, x2, y2; int color; unsigned char dir; unsigned char pad2; };
extern void DrawLine(struct pt *, struct pt *, int);
extern long LineProc(long obj, long evt, long p);

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
long IconProc(long obj, long evt, long p)
{
	struct rect r;
	struct pt pt;
	struct vinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	pt.x = h->r.x1 + 2;
	pt.y = h->r.y1 + 2;
	r.x1 = pt.x - 2;
	r.x2 = pt.x + 25;
	r.y1 = pt.y - 2;
	r.y2 = pt.y + 25;
	DrawDesignBox(&r, 0xc4, 0xf0);
	DrawIcons(&pt, h->l22);
	return 0;
}
long LineProc(long obj, long evt, long p)
{
	struct pt a, b;
	struct lineinst *h;

	if (evt != EVT_DRAW) return ViewableProc(obj, evt, p);
	ViewableProc(obj, evt, p);
	h = GetViewInstance(obj);
	if (h->dir == 1) {
		a.x = h->x1;
		a.y = h->y1;
		b.x = h->x2;
		b.y = h->y2;
	} else {
		a.x = h->x1;
		a.y = h->y2;
		b.x = h->x2;
		b.y = h->y1;
	}
	DrawLine(&a, &b, h->color);
	return 0;
}
