/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/graphics_text_vga_m0.c (2026-11-16-111-p6-r22-staged)
   sha256 2d94d57e435ee0443845f5df75764e6e121895dff7e1efaf2d6b34d1787b67a9 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct dsrc { unsigned char op[2]; int a2; int a4; int a6; int a8; };
struct pt { int x; int y; };
extern int GFX_FG_COLOR;
extern void DrawLineWithMode(struct pt *, struct pt *, int);
void SeGfx_StaticOp01_Line(struct dsrc *s)
{
    struct pt a, b;
    a.x = s->a2;
    a.y = s->a4;
    b.x = s->a6;
    b.y = s->a8;
    DrawLineWithMode(&a, &b, GFX_FG_COLOR);
}
