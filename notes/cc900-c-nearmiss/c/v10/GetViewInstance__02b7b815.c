/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_15m272a.c (2026-11-16-100-p6-r19)
   sha256 02b7b8153dface0f83ffc152bf583ccf91a1baa7c200677e5d00e815360b1583 (tar-sha256); compiled at -Xr */
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
