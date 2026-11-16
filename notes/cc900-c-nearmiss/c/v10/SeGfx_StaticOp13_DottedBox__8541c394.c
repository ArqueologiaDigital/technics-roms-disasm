/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/graphics_text_vga_m0.c (2026-11-16-92-p6-r18)
   sha256 8541c394b0b3cdc9c87eec0cbc560889ea0cd090acd6565b7848781bda3f1342 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct dsrc { unsigned char op[2]; int a2; int a4; int a6; int a8; };
struct pt { int x; int y; };
extern int GFX_FG_COLOR;
extern void DrawDottedLineWithMode(struct pt *, struct pt *, int);
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
