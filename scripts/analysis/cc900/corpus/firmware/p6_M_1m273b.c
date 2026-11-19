/* Phase 6, lane_p6 helper M, round 1, module 273, form b (alternatives to p6_M_1m273a.c).
   ColorBlit_ByteData / SeGfx_BoundOp08_ColorBlit: the rectangle copied by struct assignment instead of field by field.
   ColorBlit_Variant_ByteData / SeGfx_BoundOp08_ColorBlit: the variable shift behind an explicit zero test (the ROM's
   `and a,15; jr z` before `srl A,r`), the shift count in a local. */
/* cc900-module: ColorBlit2 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
struct cent { unsigned int pos; unsigned int w; int h; };
struct rop { int code; struct rect r; };
extern unsigned int GFX_BG_COLOR;
extern void ColorBlit2(struct rect *r, int n);
extern void ColorBlit_ByteData(struct rop *p);
extern void ColorBlit_Variant_ByteData(unsigned char *p);
extern void SeGfx_BoundOp08_ColorBlit(unsigned char *p);

void ColorBlit_ByteData(struct rop *p)
{
	struct rect r;

	r = p->r;
	ColorBlit2(&r, GFX_BG_COLOR);
}

void ColorBlit_Variant_ByteData(unsigned char *p)
{
	struct rect r;
	unsigned char v;
	unsigned char s;
	struct cent *e;

	v = *(unsigned char *)*(unsigned int *)(p + 2) & p[4];
	s = p[5] & 15;
	if (s != 0)
		v >>= s;
	e = &(*(struct cent **)(p + 7))[v];
	r.y0 = e->pos / 40;
	r.x0 = (e->pos % 40) * 8;
	r.y1 = r.y0 + e->h;
	r.x1 = r.x0 + e->w * 8;
	ColorBlit2(&r, GFX_BG_COLOR);
}

void SeGfx_BoundOp08_ColorBlit(unsigned char *p)
{
	struct rect r;
	unsigned char v;
	unsigned char s;

	v = *(unsigned char *)*(unsigned int *)(p + 2) & p[4];
	s = p[5] & 15;
	if (s != 0)
		v >>= s;
	r = (*(struct rect **)(p + 7))[v];
	ColorBlit2(&r, GFX_BG_COLOR);
}
