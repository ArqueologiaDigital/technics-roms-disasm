/* Phase 6, lane_p6 helper C, round 18, module 273 (modules_v10.tsv): SeGfx_StaticOp03_Bitmap, form a.
   Round 17 form b (run 118, -O3 -Xr, +4) now differs in one spot only: V4.23 takes the op's position address
   (XIX) before the rectangle's y0 field address (XDE); the ROM the other way round.  Here the position pointer is
   assigned inside the first statement's right side, after the store target.
   Form b (p6_C_18m273b.c) and form c (p6_C_18m273c.c) name the y0 field's address before the position's, with
   two declaration orders. */
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
    q->y0 = *(pp = &s->pos) / 40;
    q->x0 = (*pp % 40) << 3;
    q->y1 = s->h + q->y0;
    q->x1 = q->x0 + (s->w << 3);
    ColorBlit2_LargeCodeBlock(q, s->bits, GFX_FG_COLOR);
}
