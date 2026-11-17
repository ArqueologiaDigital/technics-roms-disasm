/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m272a.c (2026-11-16-118-p6-r23)
   sha256 f406d1e78bbc41537dfa3cd0487d473f970f0a0fa9eecd205fb7a9eeb5aaa659 (tar-sha256); compiled at -O3 -Xr */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];
struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
extern unsigned long ram_2bc14;
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
