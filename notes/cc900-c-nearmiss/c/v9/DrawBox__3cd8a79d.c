/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/drawing_primitives_m273.c (2026-11-18-28-p6-r36)
   sha256 3cd8a79d1347281f0d4750a4952b700028d8d9e18a624b59329febbf03fe1725 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
struct rect { int x0, y0, x1, y1; };
extern int IsDrawTask(void);
struct dbcmd { void (*fn)(struct dbcmd *); struct rect r; int c; };
extern void DrawBox_Impl(struct rect *, int);
extern void DrawBox_QueuedExec(struct dbcmd *);
extern void DrawBox_QueuedExec(struct dbcmd *q);
void DrawBox(struct rect *r, int c)
{
	struct dbcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBox_Impl(r, c);
	} else {
		q = (struct dbcmd *)DrawQueue_Alloc(sizeof(struct dbcmd));
		q->fn = DrawBox_QueuedExec;
		q->r = *r;
		q->c = c;
		DrawRing_Post(q);
	}
}
