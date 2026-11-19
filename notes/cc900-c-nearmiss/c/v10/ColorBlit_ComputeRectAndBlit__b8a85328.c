/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_3m273a.c (2026-11-19-19-p6-r43)
   sha256 b8a85328993c5674abc7c9f05e2da6fda25c8cd785ff2354805e35282be551ac (tar-sha256); compiled at -O3 -XS -Xr */
struct rect { int x0, y0, x1, y1; };
struct csrc { int code; unsigned int pos; unsigned int w; int h; };
extern unsigned int GFX_BG_COLOR;
extern void ColorBlit2(struct rect *r, int n);
void ColorBlit_ComputeRectAndBlit(struct csrc *s)
{
	struct rect r;

	r.y0 = s->pos / 40;
	r.x0 = (s->pos % 40) * 8;
	r.y1 = s->h + r.y0;
	r.x1 = r.x0 + s->w * 8;
	ColorBlit2(&r, GFX_BG_COLOR);
}
