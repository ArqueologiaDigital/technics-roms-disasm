/* lane_p6 helper H, round 9, module 273, form a: DrawRect_Impl with lane_sub's reload-after-store spelling:
   &r->y0 goes into a register local u and a stored local py; the first test reads through u (the ROM keeps the
   just-stored pointer in XWA), the later reads through py (the ROM reloads it from xsp+2). */
/* cc900-module: DrawLineWithMode_Impl SetChangeRect */

struct point { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void SetChangeRect(struct rect *);
extern void DrawLineWithMode_Impl(struct point *, struct point *, int);

void DrawRect_Impl(struct rect *r, int mode)
{
    struct point a, b;
    int *py;
    int *u;

    u = &r->y0;
    py = u;
    if (*u < 0)
        *py = 0;
    if (r->x0 < 0)
        r->x0 = 0;
    if (r->x1 >= 320)
        r->x1 = 319;
    if (r->y1 >= 240)
        r->y1 = 239;
    if (*py == r->y1) {
        a.y = *py;
        a.x = r->x0;
        b.x = r->x1;
        b.y = r->y1;
        DrawLineWithMode_Impl(&a, &b, mode);
    } else {
        a.y = *py;
        a.x = r->x0;
        b.x = r->x1;
        b.y = *py;
        DrawLineWithMode_Impl(&a, &b, mode);
        a.y = r->y1;
        b.y = r->y1;
        DrawLineWithMode_Impl(&a, &b, mode);
        a.y = r->y0;
        a.x = r->x0;
        b.x = r->x0;
        b.y = r->y1;
        DrawLineWithMode_Impl(&a, &b, mode);
        a.x = r->x1;
        b.x = r->x1;
        DrawLineWithMode_Impl(&a, &b, mode);
    }
    SetChangeRect(r);
}
