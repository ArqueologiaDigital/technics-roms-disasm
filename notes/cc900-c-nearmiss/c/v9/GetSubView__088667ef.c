/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_widget_defs_m272.c (2026-11-16-122-p6-r24-staged)
   sha256 088667ef9921df9def8d2f926bfca400689be92e45aeaab97bbc728e4fa5f2cc (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
extern struct viewable *GetViewInstance(unsigned long id);
unsigned long GetSubView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->sub;
    if (*p != -1) {
        t = *p;
        return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    }
    return 0xffffffffUL;
}
