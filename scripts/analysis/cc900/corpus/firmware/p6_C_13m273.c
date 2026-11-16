/* Phase 6, lane_p6 helper C, round 13, module 273 (modules_v10.tsv): more ops of v10 display/graphics_text_vga.s's
   SeGfx table, after the four box ops that matched in run 88 (p6_C_11m273.c).
   - the six line ops: two points on the stack (the first-declared at the higher slot), one calr;
   - SeGfx_StaticOp03_Bitmap: a text-cell position (40 cells per row, 8 pixels per cell) made into a pixel rectangle. */
/* cc900-module: DrawLineWithMode DrawDottedLineWithMode ColorBlit2_LargeCodeBlock */

struct dsrc { unsigned char op[2]; int a2; int a4; int a6; int a8; };
struct bsrc { unsigned char op[2]; long bits; unsigned int pos; unsigned int w; int h; };
struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };

extern int GFX_FG_COLOR;

extern void DrawLineWithMode(struct pt *, struct pt *, int);
extern void DrawDottedLineWithMode(struct pt *, struct pt *, int);
extern void ColorBlit2_LargeCodeBlock(struct rect *, long, int);

void SeGfx_StaticOp00_Line(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
}

void SeGfx_StaticOp01_Line(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
}

void SeGfx_StaticOp02_Line(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
}

void SeGfx_StaticOp11_DottedLine(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawDottedLineWithMode(&a, &b, GFX_FG_COLOR);
}

void SeGfx_StaticOp12_DottedLine(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawDottedLineWithMode(&a, &b, GFX_FG_COLOR);
}

void SeGfx_StaticOp15_DottedLine(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawDottedLineWithMode(&a, &b, GFX_FG_COLOR);
}

void SeGfx_StaticOp03_Bitmap(struct bsrc *s)
{
    struct rect r;
    r.y0 = s->pos / 40;
    r.x0 = (s->pos % 40) << 3;
    r.y1 = r.y0 + s->h;
    r.x1 = r.x0 + (s->w << 3);
    ColorBlit2_LargeCodeBlock(&r, s->bits, GFX_FG_COLOR);
}
