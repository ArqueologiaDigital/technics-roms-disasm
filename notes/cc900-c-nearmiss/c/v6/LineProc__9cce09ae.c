/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_window_procs_m0.c (2026-11-16-92-p6-r18)
   sha256 9cce09aefe6231e93a79cc17a188dd3b0a973f216002592f1300127c3f22158a (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void *GetViewInstance(long);
#define EVT_DRAW              0x1c0000dL
extern long ViewableProc(long, long, long);
struct pt { int x, y; };
struct lineinst { unsigned char pad[14]; int x1, y1, x2, y2; int color; unsigned char dir; unsigned char pad2; };
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
