/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m273a.c (2026-11-18-12-p6-r35)
   sha256 6fa3637e333b6b6b507de0c084754c41e66a8f074d4f63dc29f857986e6eb4b8 (tar-sha256); compiled at -O3 -XS -Xr
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
