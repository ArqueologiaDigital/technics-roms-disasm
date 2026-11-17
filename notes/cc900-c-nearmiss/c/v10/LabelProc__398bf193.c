/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_3m271a.c (2026-11-16-87-p6-r15)
   sha256 398bf193653f771704572214181f9880b953589dd687521d5158b4163a9e4df0 (tar-sha256); compiled at -O3 -XS -Xr */
#define EVT_DRAW              0x1c0000dL
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct vinst { unsigned char pad[14]; struct rect r; long l22; long l26; int i30; };
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
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
	DrawString((struct rect *)&r.x1, &pt, (char *)h->l22, h->l26, h->i30, 0xf7);
	return 0;
}
