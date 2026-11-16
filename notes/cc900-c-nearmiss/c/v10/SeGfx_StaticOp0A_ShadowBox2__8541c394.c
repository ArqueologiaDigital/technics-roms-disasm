/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/graphics_text_vga_m0.c (2026-11-16-92-p6-r18)
   sha256 8541c394b0b3cdc9c87eec0cbc560889ea0cd090acd6565b7848781bda3f1342 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct dsrc { unsigned char op[2]; int a2; int a4; int a6; int a8; };
struct rect { int x0; int y0; int x1; int y1; };
struct pt { int x; int y; };
extern int GFX_FG_COLOR;
extern void DrawRect(struct rect *, int);
extern void DrawLineWithMode(struct pt *, struct pt *, int);
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
