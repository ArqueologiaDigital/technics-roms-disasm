/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/drawing_primitives_m273.c (2026-11-18-28-p6-r36)
   sha256 3cd8a79d1347281f0d4750a4952b700028d8d9e18a624b59329febbf03fe1725 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
struct rect { int x0, y0, x1, y1; };
extern int IsDrawTask(void);
struct mpcmd { void (*fn)(struct mpcmd *); struct rect r; struct pt p; };
extern void MovePixels_Impl(struct rect *, struct pt *);
extern void MovePixels_QueuedExec(struct mpcmd *);
extern void MovePixels_QueuedExec(struct mpcmd *q);
void MovePixels(struct rect *r, struct pt *p)
{
	struct mpcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			MovePixels_Impl(r, p);
	} else {
		q = (struct mpcmd *)DrawQueue_Alloc(sizeof(struct mpcmd));
		q->fn = MovePixels_QueuedExec;
		q->r = *r;
		q->p = *p;
		DrawRing_Post(q);
	}
}
