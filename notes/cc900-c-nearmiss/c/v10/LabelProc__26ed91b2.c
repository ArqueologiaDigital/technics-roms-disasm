/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_G_5m271a.c (2026-11-16-92-p6-r18)
   sha256 26ed91b231e2af8d3d0dfea837cda0ca7364fa20b4ba9832a35202b2f3865ce5 (tar-sha256); compiled at -Xr */
#define EVT_DRAW              0x1c0000dL
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct vinst { unsigned char pad[14]; struct rect r; char *str; long l26; int i30; };
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
	DrawString((struct rect *)&r.x1, &pt, h->str, h->l26, h->i30, 0xf7);
	return 0;
}
