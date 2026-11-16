/* Phase 6, lane_p6 helper C, round 17, module 273 (modules_v10.tsv): SeGfx_StaticOp03_Bitmap, form a.
   Run 107, round 16 form b at -O3 -Xr: right registers (rectangle XHL, its y0 field XDE, the op's position XIX)
   but two spots differ: V4.23 took the position's address before the y0 field's (the ROM: y0 first), and for
   y1 = y0 + h it loaded h and added y0 (the ROM loads y0 and adds h).  Here the position is read without a pointer
   local (so the y0 store address comes first) and the sum is written h + y0.
   Form b (p6_C_17m273b.c): round 16 form b with only the sum reversed; form c (p6_C_17m273c.c): no position
   pointer, sum as before. */
/* cc900-module: ColorBlit2_LargeCodeBlock */

struct bsrc { unsigned char op[2]; long bits; unsigned int pos; unsigned int w; int h; };
struct rect { int x0; int y0; int x1; int y1; };

extern int GFX_FG_COLOR;

extern void ColorBlit2_LargeCodeBlock(struct rect *, long, int);

void SeGfx_StaticOp03_Bitmap(struct bsrc *s)
{
    struct rect r;
    struct rect *q;
    q = &r;
    q->y0 = s->pos / 40;
    q->x0 = (s->pos % 40) << 3;
    q->y1 = s->h + q->y0;
    q->x1 = q->x0 + (s->w << 3);
    ColorBlit2_LargeCodeBlock(q, s->bits, GFX_FG_COLOR);
}
