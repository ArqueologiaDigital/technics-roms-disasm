/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m273a.c (2026-11-18-12-p6-r35)
   sha256 6fa3637e333b6b6b507de0c084754c41e66a8f074d4f63dc29f857986e6eb4b8 (tar-sha256); compiled at -O3 -XS -Xr */
struct pt { int x, y; };
extern int DRAW_ENABLED;
struct bfcmd { void (*fn)(struct bfcmd *); struct pt p; unsigned char *bmp; };
extern void DrawBitmapFast_Impl(struct pt *, unsigned char *);
void DrawBitmapFast_QueuedExec(struct bfcmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;

	if (DRAW_ENABLED != 0)
		DrawBitmapFast_Impl(p, bmp);
}
