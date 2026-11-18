/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/drawing_primitives_m0_xr.c (2026-11-18-28-p6-r36)
   sha256 f828982eb48156698c12515b2d04f2bd4eea3641c473bc22e492b8400c15bad9 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern int DRAW_ENABLED;
struct pt { int x, y; };
struct cmd_pt_l { void *fn; struct pt p; long n; };
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
