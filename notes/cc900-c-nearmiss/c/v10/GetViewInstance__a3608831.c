/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_13m272a.c (2026-11-16-92-p6-r18)
   sha256 a36088310bceecd332f3e5a35b567f4ee6ee9fa0a4a5c56c0d14da0d24fc109f (tar-sha256); compiled at -O3 -XS -Xr */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];
struct viewable *GetViewInstance(unsigned long id)
{
    unsigned long t;
    unsigned int i;
    struct viewable **d;
    unsigned long k;
    t = (id >> 16) & 0xfff;
    id &= 0xffff;
    i = id;
    d = OBJECT_REGISTRY[(unsigned int)t].data;
    k = i;
    k <<= 2;
    return *(struct viewable **)((unsigned long)d + k);
}
