/* Functions of display/graphics_text_vga.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawDottedLineWithMode DrawLineWithMode DrawRect */   /* scripts/analysis/cc900/module_calls.py v10 */

struct dsrc { unsigned char op[2]; int a2; int a4; int a6; int a8; };
struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };
extern int GFX_FG_COLOR;
extern void DrawRect(struct rect *, int);
extern void DrawLineWithMode(struct pt *, struct pt *, int);
extern void SeGfx_StaticOp0A_ShadowBox2(struct dsrc *s);
extern void DrawDottedLineWithMode(struct pt *, struct pt *, int);
extern void SeGfx_StaticOp13_DottedBox(struct dsrc *s);
extern void SeGfx_StaticOp22_ShadowBox1(struct dsrc *s);

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
