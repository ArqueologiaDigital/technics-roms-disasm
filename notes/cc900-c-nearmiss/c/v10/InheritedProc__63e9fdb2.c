/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_20m272a.c (2026-11-16-128-p6-r27)
   sha256 63e9fdb2d0d680ae49303ec52f05d2ce6b833dad25b7801159cdaa9298815545 (tar-sha256); compiled at -O3 -Xr */
struct objent { char hdr[10]; void *data; };
extern struct objent OBJECT_REGISTRY[];
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
