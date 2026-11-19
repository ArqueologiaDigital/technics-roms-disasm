/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m273a.c (2026-11-19-15-p6-r42)
   sha256 5328f0d2d1a9d1dbc8810ab857321ed3512d2cc9fe4fec68a0cf317646fb7158 (tar-sha256); compiled at -O3 -XS -Xr */
struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
struct mbcmd { void (*fn)(struct mbcmd *); struct rect r; unsigned char *bits; int color; unsigned char mode; };
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern void DrawMonoBitmap_Impl(struct rect *r, unsigned char *bits, int color);
void DrawMonoBitmap_ParamBlock(struct mbcmd *q)
{
	struct rect *r = &q->r;
	unsigned char *bits = q->bits;
	int color = q->color;

	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		DrawMonoBitmap_Impl(r, bits, color);
}
