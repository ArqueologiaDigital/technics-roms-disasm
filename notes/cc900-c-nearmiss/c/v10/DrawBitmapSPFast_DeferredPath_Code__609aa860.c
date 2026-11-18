/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m273b.c (2026-11-18-12-p6-r35)
   sha256 609aa860dafa55d0054032d8040501bfeacaf6f522408b994773e0ec4fdeb5b1 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-name: DrawBmpSPFast_DeferredCode=DrawBitmapSPFast_DeferredPath_Code */
struct pt { int x, y; };
struct cmd_pt_lii { void *fn; struct pt p; long b; int c; int d; };
extern int DRAW_ENABLED;
extern void DrawBitmapSPFast_Impl(struct pt *, long, int, int);
void DrawBmpSPFast_DeferredCode(struct cmd_pt_lii *q)
{
	struct pt *p;
	long b;
	int c;
	int d;

	p = &q->p;
	b = q->b;
	c = q->c;
	d = q->d;
	if (DRAW_ENABLED != 0)
		DrawBitmapSPFast_Impl(p, b, c, d);
}
