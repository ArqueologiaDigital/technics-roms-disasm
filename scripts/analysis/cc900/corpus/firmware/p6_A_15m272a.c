/* cc900-module: GetNextView GetPrevView GetSubView GetSuperView GetViewInstance SetChange */
/* Phase 6, lane_p6 helper A, round 15, form a: module 272 (ui/ui_widget_defs.s), the functions still differing after
   run 92.  GetViewInstance without a data-pointer local (the ROM loads it into XBC and indexes from DE); the getters'
   result written as one expression (form a) or as field + shifted entry (form b). */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];
extern void SetChange(unsigned long id, int f);

struct viewable *GetViewInstance(unsigned long id)
{
    unsigned long t;
    unsigned int i;
    t = (id >> 16) & 0xfff;
    id &= 0xffff;
    i = id;
    return OBJECT_REGISTRY[(unsigned int)t].data[i];
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
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
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
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
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
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
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
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
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
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
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
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
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
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
}

void Link(unsigned long id, unsigned long v)
{
    unsigned long s;
    struct viewable *w;
    while (GetNextView(id) != 0xffffffffUL)
        id = GetNextView(id);
    GetViewInstance(id)->next = v;
    SetChange(id, 1);
    s = GetSuperView(id);
    w = GetViewInstance(v);
    w->prev = id;
    w->super = s;
    SetChange(v, 1);
}
