/* cc900-module: GetViewInstance */
/* Phase 6, lane_p6 helper A, round 18, form c: module 272 (ui/ui_widget_defs.s), the view relation getters,
   GetViewInstance and InheritedProc.  Getters: form a's if/else with the instance pointer taken in one step
   (`&GetViewInstance(id)->next`).  InheritedProc: form a's index temporaries declared i first, and the class table
   pointer through a second variable for the parent. */
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
    int *p;
    long t;
    unsigned long r;
    p = &GetViewInstance(id)->next;
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
    return r;
}

unsigned long GetNextView(unsigned long id)
{
    int *p;
    long t;
    unsigned long r;
    p = &GetViewInstance(id)->next;
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
    return r;
}

unsigned long PrevView(unsigned long id)
{
    int *p;
    long t;
    unsigned long r;
    p = &GetViewInstance(id)->prev;
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
    return r;
}

unsigned long GetPrevView(unsigned long id)
{
    int *p;
    long t;
    unsigned long r;
    p = &GetViewInstance(id)->prev;
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
    return r;
}

unsigned long GetSuperView(unsigned long id)
{
    int *p;
    long t;
    unsigned long r;
    p = &GetViewInstance(id)->super;
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
    return r;
}

unsigned long SubView(unsigned long id)
{
    int *p;
    long t;
    unsigned long r;
    p = &GetViewInstance(id)->sub;
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
    return r;
}

unsigned long GetSubView(unsigned long id)
{
    int *p;
    long t;
    unsigned long r;
    p = &GetViewInstance(id)->sub;
    if (*p != -1) {
        t = *p;
        r = ((unsigned long)(unsigned int)((id >> 16) & 0xfff) << 16) + t;
    } else
        r = 0xffffffffUL;
    return r;
}

long InheritedProc(unsigned long obj, long evt, long par)
{
    unsigned long save, parent;
    unsigned int i, t;
    struct clsrec *c, *pc;
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
        pc = (struct clsrec *)OBJECT_REGISTRY[t].data;
        r = pc[i].proc(obj, evt, par);
        ram_2bc14 = save;
    } else
        r = 0;
    return r;
}
