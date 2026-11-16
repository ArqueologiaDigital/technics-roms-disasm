/* Phase 6, lane_p6 helper A, round 9, form a: module 272 of modules_v10.tsv (ui/ui_widget_defs.s), the view
   accessors that reach GetViewInstance with calr; every same-module callee is defined in this file.
   Object id: bits 16..27 = object table entry, bits 0..15 = index into that entry's instance array. */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];

struct viewable *GetViewInstance(unsigned long id)
{
    unsigned long t;
    t = (id >> 16) & 0xfff;
    id &= 0xffff;
    return OBJECT_REGISTRY[(unsigned int)t].data[(unsigned int)id];
}

void SetChange(unsigned long id, int f)
{
    unsigned int *p;
    p = &GetViewInstance(id)->flags;
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
    unsigned int *p;
    p = &GetViewInstance(id)->flags;
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
    unsigned int *p;
    p = &GetViewInstance(id)->flags;
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
    unsigned int *p;
    p = &GetViewInstance(id)->flags;
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
    unsigned long r;
    p = &GetViewInstance(id)->next;
    if (*p == -1)
        return 0xffffffffUL;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + (long)*p;
    return r;
}

unsigned long GetNextView(unsigned long id)
{
    int *p;
    unsigned long r;
    p = &GetViewInstance(id)->next;
    if (*p == -1)
        return 0xffffffffUL;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + (long)*p;
    return r;
}

unsigned long PrevView(unsigned long id)
{
    int *p;
    unsigned long r;
    p = &GetViewInstance(id)->prev;
    if (*p == -1)
        return 0xffffffffUL;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + (long)*p;
    return r;
}

unsigned long GetPrevView(unsigned long id)
{
    int *p;
    unsigned long r;
    p = &GetViewInstance(id)->prev;
    if (*p == -1)
        return 0xffffffffUL;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + (long)*p;
    return r;
}

unsigned long GetSuperView(unsigned long id)
{
    int *p;
    unsigned long r;
    p = &GetViewInstance(id)->super;
    if (*p == -1)
        return 0xffffffffUL;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + (long)*p;
    return r;
}

unsigned long SubView(unsigned long id)
{
    int *p;
    unsigned long r;
    p = &GetViewInstance(id)->sub;
    if (*p == -1)
        return 0xffffffffUL;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + (long)*p;
    return r;
}

unsigned long GetSubView(unsigned long id)
{
    int *p;
    unsigned long r;
    p = &GetViewInstance(id)->sub;
    if (*p == -1)
        return 0xffffffffUL;
    r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + (long)*p;
    return r;
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
