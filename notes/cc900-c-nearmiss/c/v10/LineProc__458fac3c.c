/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_1b.c (2026-11-16-45-p6-r9)
   sha256 458fac3c50a56452c643aff2a328f80b03d0e17483a3bfc68b066764994c47b5 (tar-sha256); compiled at -O3 -Xr */
#define EVT_DRAW              0x1c0000dL
struct pt { int x, y; };
struct lineinst { unsigned char pad[14]; int x1, y1, x2, y2; int color; unsigned char dir; unsigned char pad2; };
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawLine(struct pt *, struct pt *, int);
long LineProc(long obj, long evt, long p)
{
	struct pt a, b;
	struct lineinst *h;

	switch (evt) {
	case EVT_DRAW:
		break;
	default:
		return ViewableProc(obj, evt, p);
	}
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
