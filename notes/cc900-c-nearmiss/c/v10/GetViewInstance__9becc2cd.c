/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_17m272b.c (2026-11-16-107-p6-r21)
   sha256 9becc2cd8dae4e83d67fe76085e7aa93cb7915353763549a839daa540ab10536 (tar-sha256); compiled at -Xr */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];
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
