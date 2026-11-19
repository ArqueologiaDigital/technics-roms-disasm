/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/drawing_primitives_m273.c (2026-11-19-15-p6-r42)
   sha256 ffc865047c69e2d995daef4f44e19c7ab50ee77606919e53c3125090b491b814 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
struct bmcmd { void (*fn)(struct bmcmd *); struct pt p; unsigned char *bmp; };
extern void DrawBitmap_Impl(struct pt *, unsigned char *);
extern void DrawBitmap_QueuedExec(struct bmcmd *q);
void DrawBitmap(struct pt *p, unsigned char *bmp)
{
	struct bmcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmap_Impl(p, bmp);
	} else {
		q = (struct bmcmd *)DrawQueue_Alloc(sizeof(struct bmcmd));
		q->fn = DrawBitmap_QueuedExec;
		q->p = *p;
		q->bmp = bmp;
		DrawRing_Post(q);
	}
}
