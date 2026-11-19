/* Phase 6, lane_p6 helper M, round 3, module 273, form b (alternative to p6_M_3m273a.c).
   ColorBlit_Variant_ByteData / SeGfx_BoundOp08_ColorBlit: the byte index in an unsigned char local k (k = v * 3,
   k = v * 4), the entry as a struct pointer from the int table. */
/* cc900-module: ColorBlit2 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
struct cent { unsigned int pos; unsigned int w; int h; };
extern unsigned int GFX_BG_COLOR;
extern void ColorBlit2(struct rect *r, int n);
extern void ColorBlit_Variant_ByteData(unsigned char *p);
extern void SeGfx_BoundOp08_ColorBlit(unsigned char *p);

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

void SeGfx_BoundOp08_ColorBlit(unsigned char *p)
{
	struct rect r;
	unsigned char *cell;
	unsigned char m;
	unsigned char s;
	unsigned char v;
	unsigned char k;
	struct rect *e;

	cell = (unsigned char *)*(unsigned int *)(p + 2);
	m = p[4];
	s = p[5];
	v = *cell & m;
	v >>= s;
	k = v * 4;
	e = (struct rect *)&(*(int **)(p + 7))[k];
	r.x0 = e->x0;
	r.y0 = e->y0;
	r.x1 = e->x1;
	r.y1 = e->y1;
	ColorBlit2(&r, GFX_BG_COLOR);
}
