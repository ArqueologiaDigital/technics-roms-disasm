/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/drawing_primitives_m273.c (2026-11-19-29-p6-r46)
   sha256 12ad5e0707a872042ac47d0cb8b23ae760e9c90f8d7998fd93c934c092a63300 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
struct bfcmd { void (*fn)(struct bfcmd *); struct pt p; long b; };
extern void DrawBitmapFile_Impl(struct pt *, long);
extern void DrawBitmapFile_QueuedExec(struct bfcmd *q);
void DrawBitmapFile(struct pt *p, long b)
{
	struct bfcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmapFile_Impl(p, b);
	} else {
		q = (struct bfcmd *)DrawQueue_Alloc(sizeof(struct bfcmd));
		q->fn = DrawBitmapFile_QueuedExec;
		q->p = *p;
		q->b = b;
		DrawRing_Post(q);
	}
}
