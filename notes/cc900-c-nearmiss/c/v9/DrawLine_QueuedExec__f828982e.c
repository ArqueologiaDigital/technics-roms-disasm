/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/drawing_primitives_m0_xr.c (2026-11-18-28-p6-r36)
   sha256 f828982eb48156698c12515b2d04f2bd4eea3641c473bc22e492b8400c15bad9 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern int DRAW_ENABLED;
struct pt { int x, y; };
struct dlcmd { void (*fn)(struct dlcmd *); struct pt a; struct pt b; int c; };
extern void DrawLine_Impl(struct pt *, struct pt *, int);
void DrawLine_QueuedExec(struct dlcmd *q)
{
	struct pt *a = &q->a;
	struct pt *b = &q->b;
	int c = q->c;

	if (DRAW_ENABLED != 0)
		DrawLine_Impl(a, b, c);
}
