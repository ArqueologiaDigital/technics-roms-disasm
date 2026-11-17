/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_16m273b.c (2026-11-16-107-p6-r21)
   sha256 adfdf0e5155f1a15f8ed86a5cc4669bfea4ece68c55b523a56249fd7061baf1d (tar-sha256); compiled at -O3 -Xr */
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
