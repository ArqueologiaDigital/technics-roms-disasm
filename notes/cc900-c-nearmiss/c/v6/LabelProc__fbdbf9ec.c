/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_window_procs_m271.c (2026-11-16-111-p6-r22-staged)
   sha256 fbdbf9ec000d6f183544f1e1c0b11cf8a8e519841577555714169977c21c24e6 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
#define EVT_DRAW              0x1c0000dL
struct vinst { unsigned char pad[14]; struct rect r; char *str; long l26; int i30; };
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
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
