/* Phase 6, lane_p6 helper C, round 11, module 273 (modules_v10.tsv): four box-drawing ops of v10
   display/graphics_text_vga.s's SeGfx table.  Each copies the op's rectangle (words +2..+8) to a local and calls the
   module's DrawRect / DrawLineWithMode / DrawDottedLineWithMode by calr with GFX_FG_COLOR.  The locals are declared in
   the order of their stack slots, highest first (V4.23 gives the first-declared struct the highest slot). */
/* cc900-module: DrawRect DrawLineWithMode DrawDottedLineWithMode */

struct dsrc { unsigned char op[2]; int a2; int a4; int a6; int a8; };
struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };

extern int GFX_FG_COLOR;

extern void DrawRect(struct rect *, int);
extern void DrawLineWithMode(struct pt *, struct pt *, int);
extern void DrawDottedLineWithMode(struct pt *, struct pt *, int);

void SeGfx_StaticOp09_Box(struct dsrc *s)
{
    struct rect r;
    r.x0 = s->a2;
    r.y0 = s->a4;
    r.x1 = s->a6;
    r.y1 = s->a8;
    DrawRect(&r, GFX_FG_COLOR);
}

void SeGfx_StaticOp0A_ShadowBox2(struct dsrc *s)
{
    struct rect r;
    struct pt a, b;
    r.x0 = s->a2;
    r.y0 = s->a4;
    r.x1 = s->a6;
    r.y1 = s->a8;
    DrawRect(&r, GFX_FG_COLOR);
    a.x = s->a6 + 1;
    a.y = s->a4 + 1;
    b.x = s->a6 + 1;
    b.y = s->a8 + 1;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
    a.x = s->a6 + 2;
    a.y = s->a4 + 2;
    b.x = s->a6 + 2;
    b.y = s->a8 + 2;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
    a.x = s->a2 + 1;
    a.y = s->a8 + 1;
    b.x = s->a6 + 1;
    b.y = s->a8 + 1;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
    a.x = s->a2 + 2;
    a.y = s->a8 + 2;
    b.x = s->a6 + 2;
    b.y = s->a8 + 2;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
}

void SeGfx_StaticOp13_DottedBox(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a4;
    DrawDottedLineWithMode(&a, &b, GFX_FG_COLOR);
    a.x = s->a2;
    a.y = s->a8;
    b.x = s->a6;
    b.y = s->a8;
    DrawDottedLineWithMode(&a, &b, GFX_FG_COLOR);
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a2;
    b.y = s->a8;
    DrawDottedLineWithMode(&a, &b, GFX_FG_COLOR);
    a.x = s->a6;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawDottedLineWithMode(&a, &b, GFX_FG_COLOR);
}

void SeGfx_StaticOp22_ShadowBox1(struct dsrc *s)
{
    struct rect r;
    struct pt a, b;
    r.x0 = s->a2;
    r.y0 = s->a4;
    r.x1 = s->a6;
    r.y1 = s->a8;
    DrawRect(&r, GFX_FG_COLOR);
    a.x = s->a6 + 1;
    a.y = s->a4 + 1;
    b.x = s->a6 + 1;
    b.y = s->a8 + 1;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
    a.x = s->a2 + 1;
    a.y = s->a8 + 1;
    b.x = s->a6 + 1;
    b.y = s->a8 + 1;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
}
