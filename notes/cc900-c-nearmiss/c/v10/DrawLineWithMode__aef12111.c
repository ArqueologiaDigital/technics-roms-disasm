/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_window_procs_m273.c (2026-11-18-28-p6-r36)
   sha256 aef1211117a3ec94925755b0307806a542d2fb02afda4d6ae73d44578cd99b3d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE;
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern int IsDrawTask(void);
struct lmcmd { void (*fn)(struct lmcmd *); struct pt a; struct pt b; int c; unsigned char mode; };
extern void DrawLineWithMode_Impl(struct pt *, struct pt *, int);
extern void DrawLineWithMode_ParamBlock(struct lmcmd *);
extern void DrawLineWithMode_ParamBlock(struct lmcmd *q);
void DrawLineWithMode(struct pt *a, struct pt *b, int c)
{
	struct lmcmd *q;

	if (IsDrawTask() != 0) {
		COLORBLIT_MODE_ACTIVE = COLORBLIT_MODE;
		if (DRAW_ENABLED != 0)
			DrawLineWithMode_Impl(a, b, c);
	} else {
		q = (struct lmcmd *)DrawQueue_Alloc(sizeof(struct lmcmd));
		q->fn = DrawLineWithMode_ParamBlock;
		q->a = *a;
		q->b = *b;
		q->c = c;
		q->mode = COLORBLIT_MODE;
		DrawRing_Post(q);
	}
}
