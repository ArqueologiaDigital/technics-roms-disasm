/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_window_procs_m273.c (2026-11-16-68-p6-r12)
   sha256 2b6f4f38176bed3f66e7b47122c59970d11d20cffa9eede9cf6d5aafe36c4fc4 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct point { int x, y; };
int IsPointOnScreen(struct point *p)
{
    if (p->x < 0 || p->x >= 320 || p->y < 0 || p->y >= 240)
        return 0;
    return 1;
}
