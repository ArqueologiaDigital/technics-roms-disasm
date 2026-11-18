/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/drawing_primitives_m273.c (2026-11-18-28-p6-r36)
   sha256 3cd8a79d1347281f0d4750a4952b700028d8d9e18a624b59329febbf03fe1725 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern int IsDrawTask(void);
struct dfcmd { void (*fn)(struct dfcmd *); struct pt p; int b; int c; };
extern void DrawFrameSP_Impl(struct pt *, int, int);
extern void DrawFrameSP_QueuedExec(struct dfcmd *);
extern void DrawFrameSP_QueuedExec(struct dfcmd *q);
void DrawFrameSP(struct pt *p, int b, int c)
{
	struct dfcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawFrameSP_Impl(p, b, c);
	} else {
		q = (struct dfcmd *)DrawQueue_Alloc(sizeof(struct dfcmd));
		q->fn = DrawFrameSP_QueuedExec;
		q->p = *p;
		q->b = b;
		q->c = c;
		DrawRing_Post(q);
	}
}
