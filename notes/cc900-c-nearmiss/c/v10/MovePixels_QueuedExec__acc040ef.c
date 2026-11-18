/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m273b.c (2026-11-18-12-p6-r35)
   sha256 acc040ef3de2958bb52b1c846bb6623907e6e98f4e295c697226fda8148f4174 (tar-sha256); compiled at -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
struct mpcmd { void (*fn)(struct mpcmd *); struct rect r; struct pt p; };
extern void MovePixels_Impl(struct rect *, struct pt *);
void MovePixels_QueuedExec(struct mpcmd *q)
{
	if (DRAW_ENABLED != 0)
		MovePixels_Impl(&q->r, &q->p);
}
