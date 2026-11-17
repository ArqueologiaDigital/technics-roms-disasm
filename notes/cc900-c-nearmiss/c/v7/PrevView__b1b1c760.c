/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_widget_defs_m0.c (2026-11-16-122-p6-r24-staged)
   sha256 b1b1c7605057af2c13556519b76083ef8d92ee5279bff8940f93890452bfd926 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
extern struct viewable *GetViewInstance(unsigned long id);
unsigned long PrevView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->prev;
    if (*p != -1) {
        t = *p;
        return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    }
    return 0xffffffffUL;
}
