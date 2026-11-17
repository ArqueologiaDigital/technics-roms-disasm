/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_3m273a.c (2026-11-16-72-p6-r13)
   sha256 5ba1ef318b28174663b3aba3c6985550332a9611b0de0af45dc19026825a46a8 (tar-sha256); compiled at -Xr */
struct point { int x, y; };
int IsPointOnScreen(struct point *p)
{
    if (p->x < 0 || p->x >= 320 || p->y < 0 || p->y >= 240)
        return 0;
    return 1;
}
