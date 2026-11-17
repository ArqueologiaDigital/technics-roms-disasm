/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_A_10m272b.c (2026-11-16-72-p6-r13)
   sha256 a98df4052e04267026e9dd0c1acacf5f2caeb8e5adf9e6533d4efa8adecaeb23 (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, lane_p6 helper A, round 10, form b: module 272 of modules_v10.tsv (ui/ui_widget_defs.s): the view
   accessors (calr to GetViewInstance and to each other), with Link and Unlink.  Every callee is defined here.
   Object id: bits 16..27 = object table entry, bits 0..15 = index into that entry's instance array. */
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

void SetChange(unsigned long id, int f)
{
    struct viewable *v;
    unsigned int *p;
    v = GetViewInstance(id);
    p = &v->flags;
    if (f != 0)
        *p |= 0x4;
    else
        *p &= 0xfffb;
}

int GetChange(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x4) != 0;
}

void SetConst(unsigned long id, int f)
{
    struct viewable *v;
    unsigned int *p;
    v = GetViewInstance(id);
    p = &v->flags;
    if (f != 0)
        *p |= 0x8;
    else
        *p &= 0xfff7;
}

int GetConst(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x8) != 0;
}

void SetVisible(unsigned long id, int f)
{
    struct viewable *v;
    unsigned int *p;
    v = GetViewInstance(id);
    p = &v->flags;
    if (f != 0)
        *p &= 0xfffe;
    else
        *p |= 0x1;
}

int GetVisible(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x1) == 0;
}

void SetMovable(unsigned long id, int f)
{
    struct viewable *v;
    unsigned int *p;
    v = GetViewInstance(id);
    p = &v->flags;
    if (f != 0)
        *p &= 0xfffd;
    else
        *p |= 0x2;
}

int GetMovable(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x2) == 0;
}

unsigned long NextView(unsigned long id)
{
    int *p;
    long t;
    p = (int *)((unsigned long)GetViewInstance(id) + 8);
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
}

unsigned long GetNextView(unsigned long id)
{
    int *p;
    long t;
    p = (int *)((unsigned long)GetViewInstance(id) + 8);
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
}

unsigned long PrevView(unsigned long id)
{
    int *p;
    long t;
    p = (int *)((unsigned long)GetViewInstance(id) + 10);
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
}

unsigned long GetPrevView(unsigned long id)
{
    int *p;
    long t;
    p = (int *)((unsigned long)GetViewInstance(id) + 10);
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
}

unsigned long GetSuperView(unsigned long id)
{
    int *p;
    long t;
    p = (int *)((unsigned long)GetViewInstance(id) + 4);
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
}

unsigned long SubView(unsigned long id)
{
    int *p;
    long t;
    p = (int *)((unsigned long)GetViewInstance(id) + 6);
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
}

unsigned long GetSubView(unsigned long id)
{
    int *p;
    long t;
    p = (int *)((unsigned long)GetViewInstance(id) + 6);
    if (*p == -1)
        return 0xffffffffUL;
    t = *p;
    return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
}

unsigned long GetLinkView(unsigned long id)
{
    if (GetSubView(id) != 0xffffffffUL)
        return GetSubView(id);
    if (GetNextView(id) != 0xffffffffUL)
        return GetNextView(id);
    while (GetNextView(id) == 0xffffffffUL) {
        id = GetSuperView(id);
        if (id == 0xffffffffUL)
            return 0xffffffffUL;
    }
    return GetNextView(id);
}

void GetBox(unsigned long id, struct box *b)
{
    *b = GetViewInstance(id)->box;
}

void SetBox(unsigned long id, struct box *b)
{
    GetViewInstance(id)->box = *b;
    SetChange(id, 1);
}

void Link(unsigned long id, unsigned long v)
{
    struct viewable *w;
    unsigned long s;
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

void Unlink(unsigned long id)
{
    unsigned long sup;
    struct viewable *v;
    unsigned long prev, next;
    prev = GetPrevView(id);
    if (prev != 0xffffffffUL) {
        v = GetViewInstance(prev);
        v->next = GetNextView(id);
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
    sup = GetSuperView(id);
    if (sup != 0xffffffffUL) {
        v = GetViewInstance(sup);
        if (GetSubView(sup) == id) {
            v->sub = next;
            SetChange(id, 1);
        }
        GetViewInstance(id)->super = -1;
        SetChange(id, 1);
    }
}
