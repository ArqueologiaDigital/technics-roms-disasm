/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m273b.c (2026-11-18-12-p6-r35)
   sha256 609aa860dafa55d0054032d8040501bfeacaf6f522408b994773e0ec4fdeb5b1 (tar-sha256); compiled at -O3 -XS -Xr */
struct rect { int x0, y0, x1, y1; };
struct cmd_r_i { void *fn; struct rect r; int n; };
extern int DRAW_ENABLED;
extern void DrawFrame_Impl(struct rect *, int);
void DrawFrame_QueuedExec(struct cmd_r_i *q)
{
	struct rect *r;
	int n;

	r = &q->r;
	n = q->n;
	if (DRAW_ENABLED != 0)
		DrawFrame_Impl(r, n);
}
