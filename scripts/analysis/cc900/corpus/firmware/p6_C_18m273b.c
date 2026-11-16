/* Phase 6, lane_p6 helper C, round 18, module 273 (modules_v10.tsv): SeGfx_StaticOp03_Bitmap, form b: the y0
   field's address named first (py), then the position's (pp), sum written h + y0; py declared before q
   (round 16 form a, with q declared first, gave q XDE and py XHL, the ROM the reverse).  See p6_C_18m273a.c. */
/* cc900-module: ColorBlit2_LargeCodeBlock */

struct bsrc { unsigned char op[2]; long bits; unsigned int pos; unsigned int w; int h; };
struct rect { int x0; int y0; int x1; int y1; };

extern int GFX_FG_COLOR;

extern void ColorBlit2_LargeCodeBlock(struct rect *, long, int);

void SeGfx_StaticOp03_Bitmap(struct bsrc *s)
{
    struct rect r;
    int *py;
    struct rect *q;
    unsigned int *pp;
    q = &r;
    py = &q->y0;
    pp = &s->pos;
    *py = *pp / 40;
    q->x0 = (*pp % 40) << 3;
    q->y1 = s->h + *py;
    q->x1 = q->x0 + (s->w << 3);
    ColorBlit2_LargeCodeBlock(q, s->bits, GFX_FG_COLOR);
}
