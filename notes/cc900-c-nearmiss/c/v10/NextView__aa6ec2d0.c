/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_A_17m272a.c (2026-11-16-107-p6-r21)
   sha256 aa6ec2d0e676fb8af565d48da4e4e05744dd70b70f6dd440f3e8f26ea4d5dcaa (tar-sha256); compiled at -O3 -Xr */
/* cc900-module: GetViewInstance */
/* Phase 6, lane_p6 helper A, round 17, form a: module 272 (ui/ui_widget_defs.s), the view relation getters and
   GetViewInstance. */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];

struct viewable *GetViewInstance(unsigned long id)
{
    unsigned long t;
    unsigned int i;
    struct viewable **d;
    t = (id >> 16) & 0xfff;
    id &= 0xffff;
    i = id;
    d = OBJECT_REGISTRY[(unsigned int)t].data;
    return d[i];
}

unsigned long NextView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->next;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    return r;
}

unsigned long GetNextView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->next;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    return r;
}

unsigned long PrevView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->prev;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    return r;
}

unsigned long GetPrevView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->prev;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    return r;
}

unsigned long GetSuperView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->super;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    return r;
}

unsigned long SubView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->sub;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    return r;
}

unsigned long GetSubView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->sub;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    return r;
}

