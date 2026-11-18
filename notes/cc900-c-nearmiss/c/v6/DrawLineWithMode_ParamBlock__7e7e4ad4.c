/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_window_procs_m0.c (2026-11-18-28-p6-r36)
   sha256 7e7e4ad465106de0d8996003ebf10ae9083df2854d918f66ebd046c1c48bf6fe (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE_ACTIVE;
struct pt { int x, y; };
struct lmcmd { void (*fn)(struct lmcmd *); struct pt a; struct pt b; int c; unsigned char mode; };
extern void DrawLineWithMode_Impl(struct pt *, struct pt *, int);
void DrawLineWithMode_ParamBlock(struct lmcmd *q)
{
	struct pt *a = &q->a;
	struct pt *b = &q->b;
	int c = q->c;

	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		DrawLineWithMode_Impl(a, b, c);
}
