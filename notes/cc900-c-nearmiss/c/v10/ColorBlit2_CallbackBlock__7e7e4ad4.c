/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_window_procs_m0.c (2026-11-18-28-p6-r36)
   sha256 7e7e4ad465106de0d8996003ebf10ae9083df2854d918f66ebd046c1c48bf6fe (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE_ACTIVE;
struct cmd_r_im { void *fn; struct rect r; int n; unsigned char mode; unsigned char pad; };
extern void ColorBlit2_Impl(struct rect *, int);
void ColorBlit2_CallbackBlock(struct cmd_r_im *q)
{
	struct rect *r;
	int n;

	r = &q->r;
	n = q->n;
	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		ColorBlit2_Impl(r, n);
}
