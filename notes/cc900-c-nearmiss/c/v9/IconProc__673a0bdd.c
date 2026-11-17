/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_window_procs_m0.c (2026-11-16-92-p6-r18)
   sha256 673a0bdd99ca13a8eb59016c71b237363a68b5f1e69b1663f321559090ba0eb2 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void *GetViewInstance(long);
#define EVT_DRAW              0x1c0000dL
struct rect { int x1, y1, x2, y2; };
extern long ViewableProc(long, long, long);
struct pt { int x, y; };
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawIcons(struct pt *, long);
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
