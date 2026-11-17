/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_11m272b.c (2026-11-16-87-p6-r15)
   sha256 e69f5a536e7392052bfcb5c0c6f838ee79289cebe7a2c6b4803291f1b58ff7f7 (tar-sha256); compiled at -O3 -XS -Xr */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
struct objent { char hdr[10]; struct viewable **data; };
extern struct objent OBJECT_REGISTRY[];
struct viewable *GetViewInstance(unsigned long id)
{
    unsigned long t;
    unsigned int i;
    struct viewable **d;
    t = (id >> 16) & 0xfff;
    id &= 0xffff;
    i = id;
    d = OBJECT_REGISTRY[(unsigned int)t].data;
    return *(d + i);
}
