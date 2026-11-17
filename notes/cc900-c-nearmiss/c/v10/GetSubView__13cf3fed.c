/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_A_18m272b.c (2026-11-16-118-p6-r23)
   sha256 13cf3fed52109b049cfb5c7454e75b2ef6d1bc0563846f6420029b6900e87d6d (tar-sha256); compiled at -Xr */
/* cc900-module: GetViewInstance */
/* Phase 6, lane_p6 helper A, round 18, form b: module 272 (ui/ui_widget_defs.s), the view relation getters,
   GetViewInstance and InheritedProc.  Getters: `!= -1` with the sum returned inside the if and 0xffffffff after it.
   InheritedProc: the class record reached by one expression (a macro) instead of index temporaries. */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];
/* a class record of a class table: the class proc, then the parent class id (24 bytes) */
struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
extern unsigned long ram_2bc14;
#define CLASSREC(id) (&((struct clsrec *)OBJECT_REGISTRY[(unsigned int)(((id) >> 16) & 0xfff)].data)[(unsigned int)((id) & 0xffff)])

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
    if (*p != -1) {
        t = *p;
        return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    }
    return 0xffffffffUL;
}

unsigned long GetNextView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->next;
    if (*p != -1) {
        t = *p;
        return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    }
    return 0xffffffffUL;
}

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

unsigned long GetPrevView(unsigned long id)
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

unsigned long GetSuperView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->super;
    if (*p != -1) {
        t = *p;
        return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    }
    return 0xffffffffUL;
}

unsigned long SubView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->sub;
    if (*p != -1) {
        t = *p;
        return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    }
    return 0xffffffffUL;
}

unsigned long GetSubView(unsigned long id)
{
    struct viewable *v;
    int *p;
    long t;
    v = GetViewInstance(id);
    p = &v->sub;
    if (*p != -1) {
        t = *p;
        return ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    }
    return 0xffffffffUL;
}

long InheritedProc(unsigned long obj, long evt, long par)
{
    unsigned long save, parent;
    long r;
    save = ram_2bc14;
    parent = CLASSREC(save)->parent;
    if (parent != 0xffffffffUL) {
        ram_2bc14 = parent;
        r = CLASSREC(parent)->proc(obj, evt, par);
        ram_2bc14 = save;
    } else
        r = 0;
    return r;
}
