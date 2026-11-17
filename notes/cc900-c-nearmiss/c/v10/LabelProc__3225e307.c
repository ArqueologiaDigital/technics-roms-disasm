/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_3m271b.c (2026-11-16-87-p6-r15)
   sha256 3225e3072f4658afeb46658dde4db490957a3c9c06628f66db7a9c0d05856a4d (tar-sha256); compiled at -O3 -XS -Xr */
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
	DrawString(&(&r)[0], &pt, (char *)h->l22, h->l26, h->i30, 0xf7);
	return 0;
}
