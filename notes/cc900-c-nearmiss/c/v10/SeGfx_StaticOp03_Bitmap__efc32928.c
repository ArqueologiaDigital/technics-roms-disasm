/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/graphics_text_vga_m273.c (2026-11-16-125-p6-r26-staged)
   sha256 efc32928ab74605ad67a28e93000db73208a11807d8d638698f38ba7417115e8 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
    q->y1 = s->h + q->y0;
    q->x1 = q->x0 + (s->w << 3);
    ColorBlit2_LargeCodeBlock(q, s->bits, GFX_FG_COLOR);
}
