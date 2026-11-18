/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/kn5000_v10_program_m0.c (2026-11-18-33-p6-r37)
   sha256 1ad82dbb8101e9a5c03f3044369f4c999fd5e3908a48e4644c720728f0712f75 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
struct dq { void *fn; struct rect r; struct pt p; char *s; long font; int a; int b; unsigned char mode; };
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern int DRAW_ENABLED;
extern void DrawFunc_Return(void *p);
extern void TextRender_BeginDraw(struct rect *, struct pt *, char *, long, int, int);
void DrawText_PopAndReturn_Code(struct dq *q)
{
    struct rect *r;
    struct pt *p;
    long font;
    int a;
    int b;

    r = &q->r;
    p = &q->p;
    font = q->font;
    a = q->a;
    b = q->b;
    COLORBLIT_MODE_ACTIVE = q->mode;
    if (DRAW_ENABLED != 0)
        TextRender_BeginDraw(r, p, q->s, font, a, b);
    DrawFunc_Return(q->s);
}
