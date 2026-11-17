/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_15m272b.c (2026-11-16-100-p6-r19)
   sha256 9209dfd827d812333ac9966bc88bc744668b23b97465d57065fa7e1319901b66 (tar-sha256); compiled at -Xr */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];
struct viewable *GetViewInstance(unsigned long id)
{
    unsigned long t;
    unsigned int i;
    t = (id >> 16) & 0xfff;
    id &= 0xffff;
    i = id;
    return OBJECT_REGISTRY[(unsigned int)t].data[i];
}
