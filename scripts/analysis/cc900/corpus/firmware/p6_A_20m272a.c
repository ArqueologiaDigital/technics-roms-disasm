/* Phase 6, lane_p6 helper A, round 20, form a: module 272 (ui/ui_widget_defs.s), InheritedProc: `&save;` with the class id read into x, copied to save, x shifted. */
struct objent { char hdr[10]; void *data; };
extern struct objent OBJECT_REGISTRY[];
/* a class record of a class table: the class proc, then the parent class id (24 bytes) */
struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
extern unsigned long ram_2bc14;

long InheritedProc(unsigned long obj, long evt, long par)
{
    unsigned long x;
    unsigned long save, parent;
    unsigned int i, t;
    struct clsrec *c, *pc;
    long r;
    &save;
    x = ram_2bc14;
    save = x;
    t = (unsigned int)((x >> 16) & 0xfff);
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
