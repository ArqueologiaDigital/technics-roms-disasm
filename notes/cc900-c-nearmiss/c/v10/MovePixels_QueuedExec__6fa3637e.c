/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m273a.c (2026-11-18-12-p6-r35)
   sha256 6fa3637e333b6b6b507de0c084754c41e66a8f074d4f63dc29f857986e6eb4b8 (tar-sha256); compiled at -O3 -XS -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
struct mpcmd { void (*fn)(struct mpcmd *); struct rect r; struct pt p; };
extern void MovePixels_Impl(struct rect *, struct pt *);
void MovePixels_QueuedExec(struct mpcmd *q)
{
	struct rect *r = &q->r;
	struct pt *p = &q->p;

	if (DRAW_ENABLED != 0)
		MovePixels_Impl(r, p);
}
