/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/drawing_primitives_m273.c (2026-11-18-28-p6-r36)
   sha256 3cd8a79d1347281f0d4750a4952b700028d8d9e18a624b59329febbf03fe1725 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: DrawBitmapSP2_Exec=DrawBitmapSP2_DeferredPath_Code
   cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern int IsDrawTask(void);
struct sp2cmd { void (*fn)(struct sp2cmd *); struct pt p; unsigned char *bmp; int c; int d; int e; int f; };
extern void DrawBitmapSP2_Impl(struct pt *, unsigned char *, int, int, int, int);
extern void DrawBitmapSP2_Exec(struct sp2cmd *);
extern void DrawBitmapSP2_Exec(struct sp2cmd *q);
void DrawBitmapSP2(struct pt *p, unsigned char *bmp, int c, int d, int e, int f)
{
	struct sp2cmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmapSP2_Impl(p, bmp, c, d, e, f);
	} else {
		q = (struct sp2cmd *)DrawQueue_Alloc(sizeof(struct sp2cmd));
		q->fn = DrawBitmapSP2_Exec;
		q->p = *p;
		q->bmp = bmp;
		q->c = c;
		q->d = d;
		q->e = e;
		q->f = f;
		DrawRing_Post(q);
	}
}
