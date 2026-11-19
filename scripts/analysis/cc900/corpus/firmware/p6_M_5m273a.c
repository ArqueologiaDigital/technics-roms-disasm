/* Phase 6, lane_p6 helper M, round 5, module 273, form a: ColorBlit_Variant_ByteData / SeGfx_BoundOp08_ColorBlit
   (run r43: +11).  Everything up to the index is the ROM's code except the registers: V4.23 gave the mask (and v,
   which shares it) E and the shift count L; the ROM has the mask / v in L and the count in E (then the index in HL,
   the table into XBC and the entry pointer computed from them).  This form: s declared before m (the loads stay in
   the ROM's order, p[4] then p[5]). */
/* cc900-module: ColorBlit2 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
extern unsigned int GFX_BG_COLOR;
extern void ColorBlit2(struct rect *r, int n);
extern void ColorBlit_Variant_ByteData(unsigned char *p);
extern void SeGfx_BoundOp08_ColorBlit(unsigned char *p);

void ColorBlit_Variant_ByteData(unsigned char *p)
{
	struct rect r;
	unsigned char *cell;
	unsigned char s;
	unsigned char m;
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
	unsigned char s;
	unsigned char m;
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
