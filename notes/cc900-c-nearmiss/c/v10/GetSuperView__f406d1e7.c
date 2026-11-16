/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_A_18m272a.c (2026-11-16-118-p6-r23)
   sha256 f406d1e78bbc41537dfa3cd0487d473f970f0a0fa9eecd205fb7a9eeb5aaa659 (tar-sha256); compiled at -O3 -Xr */
/* cc900-module: GetViewInstance */
/* Phase 6, lane_p6 helper A, round 18, form a: module 272 (ui/ui_widget_defs.s), the view relation getters,
   GetViewInstance and InheritedProc.  The getters now test `!= -1` so that the 0xffffffff case comes last (the ROM's
   jr z to the bottom); the sum keeps round 17a's `id part + t` order, which at -O3 -Xr gave the ROM's add/ld. */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];
/* a class record of a class table: the class proc, then the parent class id (24 bytes) */
struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
extern unsigned long ram_2bc14;

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
    unsigned long r;
    v = GetViewInstance(id);
    p = &v->next;
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
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
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
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
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
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
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
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
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
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
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
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
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
    return r;
}

/* The base-class call: the current class (0x2bc14) is replaced by its parent for the call of the parent's proc,
   which gets this proc's three arguments unchanged; 0 when there is no parent. */
long InheritedProc(unsigned long obj, long evt, long par)
{
    unsigned long save, parent;
    unsigned int t, i;
    struct clsrec *c;
    long r;
    save = ram_2bc14;
    t = (unsigned int)((save >> 16) & 0xfff);
    i = (unsigned int)(save & 0xffff);
    c = (struct clsrec *)OBJECT_REGISTRY[t].data;
    parent = c[i].parent;
    if (parent != 0xffffffffUL) {
        ram_2bc14 = parent;
        t = (unsigned int)((parent >> 16) & 0xfff);
        i = (unsigned int)(parent & 0xffff);
        c = (struct clsrec *)OBJECT_REGISTRY[t].data;
        r = c[i].proc(obj, evt, par);
        ram_2bc14 = save;
    } else
        r = 0;
    return r;
}
