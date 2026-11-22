/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_window_procs_m271.c (2026-11-22-26-p6-r93)
   sha256 9b1e68e5ea73b72eb6810bb262fec92a8ea1b1a23067d8339e9a53581f4f1853 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
