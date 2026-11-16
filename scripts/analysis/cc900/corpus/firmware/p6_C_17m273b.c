/* Phase 6, lane_p6 helper C, round 17, module 273 (modules_v10.tsv): SeGfx_StaticOp03_Bitmap, form b: round 16
   form b (run 107: +4 at -O3 -Xr) with only the y1 sum reversed (h + y0), see p6_C_17m273a.c. */
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
    q->y1 = s->h + q->y0;
    q->x1 = q->x0 + (s->w << 3);
    ColorBlit2_LargeCodeBlock(q, s->bits, GFX_FG_COLOR);
}
