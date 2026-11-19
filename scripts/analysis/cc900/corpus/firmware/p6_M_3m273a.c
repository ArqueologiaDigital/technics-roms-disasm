/* Phase 6, lane_p6 helper M, round 3, module 273, form a: retries of the colour-blit ops (run r41).
   ColorBlit_ComputeRectAndBlit (+38): r.y1 = s->h + r.y0 (V4.23 loads the right operand; the ROM loads r.y0).
   ColorBlit_Variant_ByteData / SeGfx_BoundOp08_ColorBlit (+6): the ROM loads the mask and the shift count into
   locals before reading the cell, and the `and a,15; jr z` before `srl A,r` is V4.23's own guard of a plain
   `v >>= s`.  The table index is computed in bytes ((unsigned char)(v * 3), (unsigned char)(v << 2)) into an
   int-sized table, which gives the ROM's byte mul / sll, extz and add hl,hl. */
/* cc900-module: ColorBlit2 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
struct csrc { int code; unsigned int pos; unsigned int w; int h; };
extern unsigned int GFX_BG_COLOR;
extern void ColorBlit2(struct rect *r, int n);
extern void ColorBlit_ComputeRectAndBlit(struct csrc *s);
extern void ColorBlit_Variant_ByteData(unsigned char *p);
extern void SeGfx_BoundOp08_ColorBlit(unsigned char *p);

void ColorBlit_ComputeRectAndBlit(struct csrc *s)
{
	struct rect r;

	r.y0 = s->pos / 40;
	r.x0 = (s->pos % 40) * 8;
	r.y1 = s->h + r.y0;
	r.x1 = r.x0 + s->w * 8;
	ColorBlit2(&r, GFX_BG_COLOR);
}

void ColorBlit_Variant_ByteData(unsigned char *p)
{
	struct rect r;
	unsigned char *cell;
	unsigned char m;
	unsigned char s;
	unsigned char v;
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
	unsigned char *cell;
	unsigned char m;
	unsigned char s;
	unsigned char v;
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
