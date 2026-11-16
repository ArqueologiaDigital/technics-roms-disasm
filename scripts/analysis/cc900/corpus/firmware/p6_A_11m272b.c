/* cc900-module: GetNextView GetPrevView GetSubView GetSuperView GetViewInstance SetChange */
/* Phase 6, lane_p6 helper A, round 11, form b: module 272 of modules_v10.tsv (ui/ui_widget_defs.s), the view
   accessors.  Round 10 form b already gives the ROM's bytes for the Set / Get flag pairs, GetBox and SetBox once the
   calr displacements are resolved; this round fixes the relation getters (instance pointer in a local, so that V4.23
   takes the field address with lda into XWA as the ROM does) and Unlink (the ROM's frame holds only prev, next and
   the homed id).  Object id: bits 16..27 = object table entry, bits 0..15 = index into that entry's instances. */
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
    return *(d + i);
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
    struct viewable *v;
    int *p;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->next;
    if (*p == -1)
        return 0xffffffffUL;
    r = (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
    return r;
}

unsigned long GetNextView(unsigned long id)
{
    struct viewable *v;
    int *p;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->next;
    if (*p == -1)
        return 0xffffffffUL;
    r = (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
    return r;
}

unsigned long PrevView(unsigned long id)
{
    struct viewable *v;
    int *p;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->prev;
    if (*p == -1)
        return 0xffffffffUL;
    r = (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
    return r;
}

unsigned long GetPrevView(unsigned long id)
{
    struct viewable *v;
    int *p;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->prev;
    if (*p == -1)
        return 0xffffffffUL;
    r = (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
    return r;
}

unsigned long GetSuperView(unsigned long id)
{
    struct viewable *v;
    int *p;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->super;
    if (*p == -1)
        return 0xffffffffUL;
    r = (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
    return r;
}

unsigned long SubView(unsigned long id)
{
    struct viewable *v;
    int *p;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->sub;
    if (*p == -1)
        return 0xffffffffUL;
    r = (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
    return r;
}

unsigned long GetSubView(unsigned long id)
{
    struct viewable *v;
    int *p;
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->sub;
    if (*p == -1)
        return 0xffffffffUL;
    r = (long)*p + ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16);
    return r;
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

/* The ROM's frame: prev at +8 (also reused for the superview's instance), next at +4, the id homed at +12; the
   prev view's instance and then the superview's id live in XIZ. */
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
            ((struct viewable *)prev)->sub = next;
            SetChange(id, 1);
        }
        GetViewInstance(id)->super = -1;
        SetChange(id, 1);
    }
}
