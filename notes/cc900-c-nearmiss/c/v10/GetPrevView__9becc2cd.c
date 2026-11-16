/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_A_17m272b.c (2026-11-16-107-p6-r21)
   sha256 9becc2cd8dae4e83d67fe76085e7aa93cb7915353763549a839daa540ab10536 (tar-sha256); compiled at -O3 -Xr */
/* cc900-module: GetViewInstance */
/* Phase 6, lane_p6 helper A, round 17, form b: module 272 (ui/ui_widget_defs.s), the view relation getters and
   GetViewInstance. */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];

struct viewable *GetViewInstance(unsigned long id)
{
    unsigned int i;
    unsigned long t;
    struct viewable **d;
    t = (id >> 16) & 0xfff;
    i = (unsigned int)(id & 0xffff);
    d = OBJECT_REGISTRY[(unsigned int)t].data;
    return d[i];
}

unsigned long NextView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->next;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return t + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long GetNextView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->next;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return t + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long PrevView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->prev;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return t + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long GetPrevView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->prev;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return t + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long GetSuperView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->super;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return t + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long SubView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->sub;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return t + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long GetSubView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->sub;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return t + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

