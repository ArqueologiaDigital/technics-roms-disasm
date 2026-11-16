/* Phase 6, lane_p6 helper C, round 17, module 273 (modules_v10.tsv): SeGfx_StaticOp03_Bitmap, form c: the position
   read without a pointer local, the y1 sum as in round 16 (y0 + h); see p6_C_17m273a.c. */
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
    q->y1 = q->y0 + s->h;
    q->x1 = q->x0 + (s->w << 3);
    ColorBlit2_LargeCodeBlock(q, s->bits, GFX_FG_COLOR);
}
