/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/drawing_primitives_m0_xr.c (2026-11-18-28-p6-r36)
   sha256 f828982eb48156698c12515b2d04f2bd4eea3641c473bc22e492b8400c15bad9 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
struct pt { int x, y; };
struct mpcmd { void (*fn)(struct mpcmd *); struct rect r; struct pt p; };
extern void MovePixels_Impl(struct rect *, struct pt *);
void MovePixels_QueuedExec(struct mpcmd *q)
{
	struct rect *r = &q->r;
	struct pt *p = &q->p;

	if (DRAW_ENABLED != 0)
		MovePixels_Impl(r, p);
}
