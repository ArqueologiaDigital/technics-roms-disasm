/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/drawing_primitives_m0.c (2026-11-18-28-p6-r36)
   sha256 48e752fc37df044022acdc1ee921e9c1aacdd62e25f84226ff092a562a43c042 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: DrawBitmapSP2_Exec=DrawBitmapSP2_DeferredPath_Code */
struct pt { int x, y; };
extern int DRAW_ENABLED;
struct sp2cmd { void (*fn)(struct sp2cmd *); struct pt p; unsigned char *bmp; int c; int d; int e; int f; };
extern void DrawBitmapSP2_Impl(struct pt *, unsigned char *, int, int, int, int);
void DrawBitmapSP2_Exec(struct sp2cmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;
	int c = q->c;
	int d = q->d;
	int e = q->e;
	int f = q->f;

	if (DRAW_ENABLED != 0)
		DrawBitmapSP2_Impl(p, bmp, c, d, e, f);
}
