/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_3m273b.c (2026-11-19-19-p6-r43)
   sha256 4eb09df11815576a880c2551113b2278e19ed47256e29db43316637fee73c827 (tar-sha256); compiled at -O3 -Xr */
struct rect { int x0, y0, x1, y1; };
struct cent { unsigned int pos; unsigned int w; int h; };
extern unsigned int GFX_BG_COLOR;
extern void ColorBlit2(struct rect *r, int n);
void ColorBlit_Variant_ByteData(unsigned char *p)
{
	struct rect r;
	unsigned char *cell;
	unsigned char m;
	unsigned char s;
	unsigned char v;
	unsigned char k;
	struct cent *e;

	cell = (unsigned char *)*(unsigned int *)(p + 2);
	m = p[4];
	s = p[5];
	v = *cell & m;
	v >>= s;
	k = v * 3;
	e = (struct cent *)&(*(int **)(p + 7))[k];
	r.y0 = e->pos / 40;
	r.x0 = (e->pos % 40) * 8;
	r.y1 = e->h + r.y0;
	r.x1 = r.x0 + e->w * 8;
	ColorBlit2(&r, GFX_BG_COLOR);
}
