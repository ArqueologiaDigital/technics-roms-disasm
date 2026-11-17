/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_2a.c (2026-11-16-68-p6-r12)
   sha256 142b615fa87d9a2c1a23991cd35a1c56f44c514ada1d12b5095f91c20ccc177a (tar-sha256); compiled at -O3 -Xr */
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
