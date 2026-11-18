/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/drawing_primitives_m273.c (2026-11-18-28-p6-r36)
   sha256 3cd8a79d1347281f0d4750a4952b700028d8d9e18a624b59329febbf03fe1725 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern int IsDrawTask(void);
struct spcmd { void (*fn)(struct spcmd *); struct pt p; unsigned char *bmp; int c; int d; };
extern void DrawBitmapSP_Impl(struct pt *, unsigned char *, int, int);
extern void DrawBitmapSP_DeferredPath_Code(struct spcmd *);
extern void DrawBitmapSP_DeferredPath_Code(struct spcmd *q);
void DrawBitmapSP(struct pt *p, unsigned char *bmp, int c, int d)
{
	struct spcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmapSP_Impl(p, bmp, c, d);
	} else {
		q = (struct spcmd *)DrawQueue_Alloc(sizeof(struct spcmd));
		q->fn = DrawBitmapSP_DeferredPath_Code;
		q->p = *p;
		q->bmp = bmp;
		q->c = c;
		q->d = d;
		DrawRing_Post(q);
	}
}
