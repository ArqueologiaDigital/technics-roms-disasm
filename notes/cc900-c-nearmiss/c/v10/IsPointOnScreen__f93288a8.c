/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_2m273a.c (2026-11-16-53-p6-r11)
   sha256 f93288a836308a7b1890efebe6510dbb7cb59b81a44dbc2ab6e7601fa8cdcbb2 (tar-sha256); compiled at -Xr */
struct point { int x, y; };
int IsPointOnScreen(struct point *p)
{
    if (p->x < 0 || p->x >= 320 || p->y < 0 || p->y >= 240)
        return 0;
    return 1;
}
