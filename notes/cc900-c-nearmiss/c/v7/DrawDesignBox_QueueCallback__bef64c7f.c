/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_window_procs_m0_xr.c (2026-11-18-28-p6-r36)
   sha256 bef64c7f8113fac23c2a4dbb9ad7c35fdbb98b51f90b9f01d1f666a4b0467cb4 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct rect { int x0, y0, x1, y1; };
struct cmd_r_ii { void *fn; struct rect r; int a; int b; };
extern int DRAW_ENABLED;
extern void DrawDesignBox_Impl(struct rect *, int, int);
void DrawDesignBox_QueueCallback(struct cmd_r_ii *q)
{
	struct rect *r;
	int a;
	int b;

	r = &q->r;
	a = q->a;
	b = q->b;
	if (DRAW_ENABLED != 0)
		DrawDesignBox_Impl(r, a, b);
}
