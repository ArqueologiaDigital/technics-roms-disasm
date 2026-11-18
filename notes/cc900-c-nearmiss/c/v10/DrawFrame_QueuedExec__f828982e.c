/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/drawing_primitives_m0_xr.c (2026-11-18-28-p6-r36)
   sha256 f828982eb48156698c12515b2d04f2bd4eea3641c473bc22e492b8400c15bad9 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
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
