/* Phase 6, lane_p6 helper C, round 16, module 273 (modules_v10.tsv): SeGfx_StaticOp03_Bitmap again (run 100: +2).
   The ROM keeps the op pointer in XWA and holds the rectangle, its y0 field and the op's position word in pointer
   registers (XHL, XDE, XIX); V4.23 moved the op pointer to XBC.  Form a names all three pointers as locals, form b
   (p6_C_16m273b.c) only the rectangle and the position. */
/* cc900-module: ColorBlit2_LargeCodeBlock */

struct bsrc { unsigned char op[2]; long bits; unsigned int pos; unsigned int w; int h; };
struct rect { int x0; int y0; int x1; int y1; };

extern int GFX_FG_COLOR;

extern void ColorBlit2_LargeCodeBlock(struct rect *, long, int);

void SeGfx_StaticOp03_Bitmap(struct bsrc *s)
{
    struct rect r;
    struct rect *q;
    int *py;
    unsigned int *pp;
    q = &r;
    py = &q->y0;
    pp = &s->pos;
    *py = *pp / 40;
    q->x0 = (*pp % 40) << 3;
    q->y1 = *py + s->h;
    q->x1 = q->x0 + (s->w << 3);
    ColorBlit2_LargeCodeBlock(q, s->bits, GFX_FG_COLOR);
}
