/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_18m272b.c (2026-11-16-118-p6-r23)
   sha256 13cf3fed52109b049cfb5c7454e75b2ef6d1bc0563846f6420029b6900e87d6d (tar-sha256); compiled at -Xr */
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
