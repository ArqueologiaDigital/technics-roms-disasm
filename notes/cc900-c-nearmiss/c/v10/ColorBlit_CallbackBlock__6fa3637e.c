/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m273a.c (2026-11-18-12-p6-r35)
   sha256 6fa3637e333b6b6b507de0c084754c41e66a8f074d4f63dc29f857986e6eb4b8 (tar-sha256); compiled at -O3 -XS -Xr */
struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE_ACTIVE;
struct cbcmd { void (*fn)(struct cbcmd *); struct rect r; int c; unsigned char mode; };
extern void ColorBlit_Impl(struct rect *, int);
void ColorBlit_CallbackBlock(struct cbcmd *q)
{
	struct rect *r = &q->r;
	int c = q->c;

	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		ColorBlit_Impl(r, c);
}
