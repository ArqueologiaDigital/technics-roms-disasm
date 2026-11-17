/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_3m273b.c (2026-11-16-72-p6-r13)
   sha256 448fc86f6108fa8bddd61b279d44707db1c70c2649d5e4b293e4a1c1d5d71237 (tar-sha256); compiled at -Xr */
struct point { int x, y; };
int IsPointOnScreen(struct point *p)
{
    if (p->x < 0 || p->x >= 320 || p->y < 0 || p->y >= 240)
        return 0;
    return 1;
}
