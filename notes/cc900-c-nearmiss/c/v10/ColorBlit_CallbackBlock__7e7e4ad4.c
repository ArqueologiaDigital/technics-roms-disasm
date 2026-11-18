/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_window_procs_m0.c (2026-11-18-28-p6-r36)
   sha256 7e7e4ad465106de0d8996003ebf10ae9083df2854d918f66ebd046c1c48bf6fe (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE_ACTIVE;
struct cbcmd { void (*fn)(struct cbcmd *); struct rect r; int c; unsigned char mode; };
extern void ColorBlit_Impl(struct rect *, int);
void ColorBlit_CallbackBlock(struct cbcmd *q)
{
	struct rect *r = &q->r;
	int c = q->c;

	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		ColorBlit_Impl(r, c);
}
