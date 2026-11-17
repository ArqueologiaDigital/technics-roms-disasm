/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_18m273b.c (2026-11-16-123-p6-r25)
   sha256 af31cddfc791f6edd634cf2b49762a5a5b4ff995540503d46073dee9b3099112 (tar-sha256); compiled at -Xr */
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
