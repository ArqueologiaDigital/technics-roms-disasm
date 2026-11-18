/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m273b.c (2026-11-18-12-p6-r35)
   sha256 609aa860dafa55d0054032d8040501bfeacaf6f522408b994773e0ec4fdeb5b1 (tar-sha256); compiled at -O3 -XS -Xr */
struct pt { int x, y; };
struct cmd_pt_l { void *fn; struct pt p; long n; };
extern int DRAW_ENABLED;
extern void DrawIcons_Impl(struct pt *, long);
void DrawIcons_QueuedExec(struct cmd_pt_l *q)
{
	struct pt *p;
	long n;

	p = &q->p;
	n = q->n;
	if (DRAW_ENABLED != 0)
		DrawIcons_Impl(p, n);
}
