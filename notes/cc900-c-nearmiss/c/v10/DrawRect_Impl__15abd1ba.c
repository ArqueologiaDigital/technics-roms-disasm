/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_4m273b.c (2026-11-16-87-p6-r15)
   sha256 15abd1ba3f43242d1cb6e2c491535a4da21554f9131d7582689aaa8d441f53a3 (tar-sha256); compiled at -O3 -XS -Xr */
struct point { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void SetChangeRect(struct rect *);
extern void DrawLineWithMode_Impl(struct point *, struct point *, int);
void DrawRect_Impl(struct rect *r, int mode)
{
    struct point a, b;
    int *p;

    if (r->y0 < 0)
        r->y0 = 0;
    if (r->x0 < 0)
        r->x0 = 0;
    if (r->x1 >= 320)
        r->x1 = 319;
    if (r->y1 >= 240)
        r->y1 = 239;
    if (r->y0 == r->y1) {
        a.y = r->y0;
        a.x = r->x0;
        b.x = r->x1;
        b.y = r->y1;
        DrawLineWithMode_Impl(&a, &b, mode);
    } else {
        a.y = r->y0;
        a.x = r->x0;
        b.x = r->x1;
        b.y = r->y0;
        DrawLineWithMode_Impl(&a, &b, mode);
        p = &r->y1;
        a.y = *p;
        b.y = *p;
        DrawLineWithMode_Impl(&a, &b, mode);
        a.y = r->y0;
        p = &r->x0;
        a.x = *p;
        b.x = *p;
        b.y = r->y1;
        DrawLineWithMode_Impl(&a, &b, mode);
        p = &r->x1;
        a.x = *p;
        b.x = *p;
        DrawLineWithMode_Impl(&a, &b, mode);
    }
    SetChangeRect(r);
}
