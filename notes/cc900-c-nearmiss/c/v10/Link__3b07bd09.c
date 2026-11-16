/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_A_13m272b.c (2026-11-16-92-p6-r18)
   sha256 3b07bd099ae5cede1ce300fbdb5ec03530496806bfabf5982cc93120f22266db (tar-sha256); compiled at -O3 -XS -Xr */
/* cc900-module: GetNextView GetPrevView GetSubView GetSuperView GetViewInstance SetChange */
/* Phase 6, lane_p6 helper A, round 13, form b (the sum returned as `s + t`, the index widened in the subscript,
   the sub link stored through an integer address): the module-272 functions (ui/ui_widget_defs.s) still differing after
   run 87.  Relation getters: the ROM loads the signed field first (XBC), builds the shifted entry in XWA, adds there
   and moves the sum to XHL, so the sum is built in a local.  Unlink: the ROM loads `next` before the instance
   pointer when it stores the superview's sub link.  GetViewInstance: the index is widened as an unsigned long. */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];
extern void SetChange(unsigned long id, int f);

struct viewable *GetViewInstance(unsigned long id)
{
    unsigned long t;
    unsigned int i;
    struct viewable **d;
    t = (id >> 16) & 0xfff;
    id &= 0xffff;
    i = id;
    d = OBJECT_REGISTRY[(unsigned int)t].data;
    return *(d + (unsigned long)i);
}

unsigned long NextView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long s;
    v = GetViewInstance(id);
    p = &v->next;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    s = (unsigned int)((id >> 16) & 0xfff);
    s <<= 16;
    return s + t;
}

unsigned long GetNextView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long s;
    v = GetViewInstance(id);
    p = &v->next;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    s = (unsigned int)((id >> 16) & 0xfff);
    s <<= 16;
    return s + t;
}

unsigned long PrevView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long s;
    v = GetViewInstance(id);
    p = &v->prev;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    s = (unsigned int)((id >> 16) & 0xfff);
    s <<= 16;
    return s + t;
}

unsigned long GetPrevView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long s;
    v = GetViewInstance(id);
    p = &v->prev;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    s = (unsigned int)((id >> 16) & 0xfff);
    s <<= 16;
    return s + t;
}

unsigned long GetSuperView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long s;
    v = GetViewInstance(id);
    p = &v->super;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    s = (unsigned int)((id >> 16) & 0xfff);
    s <<= 16;
    return s + t;
}

unsigned long SubView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long s;
    v = GetViewInstance(id);
    p = &v->sub;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    s = (unsigned int)((id >> 16) & 0xfff);
    s <<= 16;
    return s + t;
}

unsigned long GetSubView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    unsigned long s;
    v = GetViewInstance(id);
    p = &v->sub;
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    s = (unsigned int)((id >> 16) & 0xfff);
    s <<= 16;
    return s + t;
}

void Link(unsigned long id, unsigned long v)
{
    unsigned long s;
    struct viewable *w;
    if (GetNextView(id) != 0xffffffffUL) {
        do
            id = GetNextView(id);
        while (GetNextView(id) != 0xffffffffUL);
    }
    GetViewInstance(id)->next = v;
    SetChange(id, 1);
    s = GetSuperView(id);
    w = GetViewInstance(v);
    w->prev = id;
    w->super = s;
    SetChange(v, 1);
}

void Unlink(unsigned long id)
{
    unsigned long prev, next;
    unsigned long x;
    prev = GetPrevView(id);
    if (prev != 0xffffffffUL) {
        x = (unsigned long)GetViewInstance(prev);
        ((struct viewable *)x)->next = GetNextView(id);
        SetChange(prev, 1);
        GetViewInstance(id)->prev = -1;
        SetChange(id, 1);
    }
    next = GetNextView(id);
    if (next != 0xffffffffUL) {
        GetViewInstance(next)->prev = prev;
        SetChange(next, 1);
        GetViewInstance(id)->next = -1;
        SetChange(id, 1);
    }
    x = GetSuperView(id);
    if (x != 0xffffffffUL) {
        prev = (unsigned long)GetViewInstance(x);
        if (GetSubView(x) == id) {
            *(int *)(prev + 6) = next;
            SetChange(id, 1);
        }
        GetViewInstance(id)->super = -1;
        SetChange(id, 1);
    }
}
