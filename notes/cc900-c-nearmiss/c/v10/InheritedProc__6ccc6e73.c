/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_19m272a.c (2026-11-16-123-p6-r25)
   sha256 6ccc6e73c95c15de07008bf70e25cfba1efbc158a45e40aa26932e88d733b250 (tar-sha256); compiled at -O3 -Xr */
struct objent { char hdr[10]; void *data; };
extern struct objent OBJECT_REGISTRY[];
struct clsrec { long (*proc)(unsigned long, long, long); unsigned long parent; char rest[16]; };
extern unsigned long ram_2bc14;
long InheritedProc(unsigned long obj, long evt, long par)
{
    unsigned long x, save, parent;
    unsigned int i, t;
    struct clsrec *c, *pc;
    long r;
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
