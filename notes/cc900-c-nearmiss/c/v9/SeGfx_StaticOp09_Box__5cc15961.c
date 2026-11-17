/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/graphics_text_vga_m273.c (2026-11-16-92-p6-r18)
   sha256 5cc159613c1f66cf9f961c1e3ca369defb25d90e1a6aa473e72a1a3222d94e9b (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct dsrc { unsigned char op[2]; int a2; int a4; int a6; int a8; };
struct rect { int x0; int y0; int x1; int y1; };
extern int GFX_FG_COLOR;
extern void DrawRect(struct rect *, int);
void SeGfx_StaticOp09_Box(struct dsrc *s)
{
    struct rect r;
    r.x0 = s->a2;
    r.y0 = s->a4;
    r.x1 = s->a6;
    r.y1 = s->a8;
    DrawRect(&r, GFX_FG_COLOR);
}
