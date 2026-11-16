/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_1a.c (2026-11-16-45-p6-r9)
   sha256 cc0bda5345cdcced7e97786f7a184f7ef2235df303e8522b4b48c42bcf9b3e72 (tar-sha256); compiled at -O3 -Xr */
#define EVT_DRAW              0x1c0000dL
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawIcons(struct pt *, long);
long IconProc(long obj, long evt, long p)
{
	struct pt pt;
	struct rect r;
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
