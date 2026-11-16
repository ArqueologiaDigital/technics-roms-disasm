/* Phase 6, lane_p6 helper C, round 16, module 273 (modules_v10.tsv): SeGfx_StaticOp03_Bitmap, form b: the rectangle
   and the op's position word through pointer locals (form a, p6_C_16m273a.c, also names the y0 field's address). */
/* cc900-module: ColorBlit2_LargeCodeBlock */

struct bsrc { unsigned char op[2]; long bits; unsigned int pos; unsigned int w; int h; };
struct rect { int x0; int y0; int x1; int y1; };

extern int GFX_FG_COLOR;

extern void ColorBlit2_LargeCodeBlock(struct rect *, long, int);

void SeGfx_StaticOp03_Bitmap(struct bsrc *s)
{
    struct rect r;
    struct rect *q;
    unsigned int *pp;
    q = &r;
    pp = &s->pos;
    q->y0 = *pp / 40;
    q->x0 = (*pp % 40) << 3;
    q->y1 = q->y0 + s->h;
    q->x1 = q->x0 + (s->w << 3);
    ColorBlit2_LargeCodeBlock(q, s->bits, GFX_FG_COLOR);
}
