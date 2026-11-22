/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_36r1m271a.c (2026-11-22-25-p6-r92)
   sha256 eb051c8c16f5d15baf7e87dfeacabe6218c9b9e2ecb3fd177c59e1c930569ffb (tar-sha256); compiled at -Xr */
struct rect { int x1, y1, x2, y2; };
extern void DrawFrame(struct rect *r, int n);
void DrawDesignFrame(struct rect *r, int style, int thick, int color)
{
    struct rect b;
    register long i;

    b = *r;
    if (style == 1)
        for (i = 0; i < thick; i++) {
            DrawFrame(&b, color);
            b.y1++;
            b.y2--;
            b.x1++;
            b.x2--;
        }
}
