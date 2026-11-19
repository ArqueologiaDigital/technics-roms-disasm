/* Phase 6, lane_p6 helper M, round 5, module 273, form b (alternative to p6_M_5m273a.c): v declared first, then
   s, then m (register order of the mask / count / value locals). */
/* cc900-module: ColorBlit2 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
extern unsigned int GFX_BG_COLOR;
extern void ColorBlit2(struct rect *r, int n);
extern void ColorBlit_Variant_ByteData(unsigned char *p);
extern void SeGfx_BoundOp08_ColorBlit(unsigned char *p);

void ColorBlit_Variant_ByteData(unsigned char *p)
{
	struct rect r;
	unsigned char v;
	unsigned char *cell;
	unsigned char s;
	unsigned char m;
	unsigned int *e;

	cell = (unsigned char *)*(unsigned int *)(p + 2);
	m = p[4];
	s = p[5];
	v = *cell & m;
	v >>= s;
	e = &(*(unsigned int **)(p + 7))[(unsigned char)(v * 3)];
	r.y0 = e[0] / 40;
	r.x0 = (e[0] % 40) * 8;
	r.y1 = (int)e[2] + r.y0;
	r.x1 = r.x0 + e[1] * 8;
	ColorBlit2(&r, GFX_BG_COLOR);
}

void SeGfx_BoundOp08_ColorBlit(unsigned char *p)
{
	struct rect r;
	unsigned char v;
	unsigned char *cell;
	unsigned char s;
	unsigned char m;
	int *e;

	cell = (unsigned char *)*(unsigned int *)(p + 2);
	m = p[4];
	s = p[5];
	v = *cell & m;
	v >>= s;
	e = &(*(int **)(p + 7))[(unsigned char)(v << 2)];
	r.x0 = e[0];
	r.y0 = e[1];
	r.x1 = e[2];
	r.y1 = e[3];
	ColorBlit2(&r, GFX_BG_COLOR);
}
