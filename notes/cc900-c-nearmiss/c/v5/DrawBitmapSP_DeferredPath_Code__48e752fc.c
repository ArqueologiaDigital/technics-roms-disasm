/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/drawing_primitives_m0.c (2026-11-18-28-p6-r36)
   sha256 48e752fc37df044022acdc1ee921e9c1aacdd62e25f84226ff092a562a43c042 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pt { int x, y; };
extern int DRAW_ENABLED;
struct spcmd { void (*fn)(struct spcmd *); struct pt p; unsigned char *bmp; int c; int d; };
extern void DrawBitmapSP_Impl(struct pt *, unsigned char *, int, int);
void DrawBitmapSP_DeferredPath_Code(struct spcmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;
	int c = q->c;
	int d = q->d;

	if (DRAW_ENABLED != 0)
		DrawBitmapSP_Impl(p, bmp, c, d);
}
