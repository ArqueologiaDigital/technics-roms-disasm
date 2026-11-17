/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_A_9m272b.c (2026-11-16-53-p6-r11)
   sha256 b4a0dd4a548299c29a11c5ccc4f83977853c6174524eed9cd0624b0133045070 (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, lane_p6 helper A, round 9, form b: module 272 of modules_v10.tsv (ui/ui_widget_defs.s), the view
   accessors that reach GetViewInstance with calr; every same-module callee is defined in this file.
   Object id: bits 16..27 = object table entry, bits 0..15 = index into that entry's instance array. */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];

struct viewable *GetViewInstance(unsigned long id)
{
    unsigned long t;
    unsigned int i;
    t = (id >> 16) & 0xfff;
    i = id & 0xffff;
    return OBJECT_REGISTRY[(unsigned int)t].data[i];
}

void SetChange(unsigned long id, int f)
{
    unsigned int *p;
    p = &GetViewInstance(id)->flags;
    if (f != 0)
        *p |= 0x4;
    else
        *p &= ~0x4;
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
        *p &= ~0x8;
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
        *p &= ~0x1;
    else
        *p |= 0x1;
}

int GetVisible(unsigned long id)
{
    return !(GetViewInstance(id)->flags & 0x1);
}

void SetMovable(unsigned long id, int f)
{
    unsigned int *p;
    p = &GetViewInstance(id)->flags;
    if (f != 0)
        *p &= ~0x2;
    else
        *p |= 0x2;
}

int GetMovable(unsigned long id)
{
    return !(GetViewInstance(id)->flags & 0x2);
}

unsigned long NextView(unsigned long id)
{
    int *p;
    p = &GetViewInstance(id)->next;
    if (*p == -1)
        return 0xffffffffUL;
    return (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long GetNextView(unsigned long id)
{
    int *p;
    p = &GetViewInstance(id)->next;
    if (*p == -1)
        return 0xffffffffUL;
    return (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long PrevView(unsigned long id)
{
    int *p;
    p = &GetViewInstance(id)->prev;
    if (*p == -1)
        return 0xffffffffUL;
    return (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long GetPrevView(unsigned long id)
{
    int *p;
    p = &GetViewInstance(id)->prev;
    if (*p == -1)
        return 0xffffffffUL;
    return (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long GetSuperView(unsigned long id)
{
    int *p;
    p = &GetViewInstance(id)->super;
    if (*p == -1)
        return 0xffffffffUL;
    return (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long SubView(unsigned long id)
{
    int *p;
    p = &GetViewInstance(id)->sub;
    if (*p == -1)
        return 0xffffffffUL;
    return (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
}

unsigned long GetSubView(unsigned long id)
{
    int *p;
    p = &GetViewInstance(id)->sub;
    if (*p == -1)
        return 0xffffffffUL;
    return (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
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
    struct viewable *v;
    v = GetViewInstance(id);
    *b = v->box;
}

void SetBox(unsigned long id, struct box *b)
{
    struct viewable *v;
    v = GetViewInstance(id);
    v->box = *b;
    SetChange(id, 1);
}
