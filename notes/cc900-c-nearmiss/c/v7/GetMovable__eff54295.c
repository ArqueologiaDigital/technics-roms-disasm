/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_widget_defs_m0_xr.c (2026-11-16-92-p6-r18)
   sha256 eff54295436c71b3712263b7e744cb6f9b96f1e0811f0c408e527cd06b660bf4 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
extern struct viewable *GetViewInstance(unsigned long id);
int GetMovable(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x2) == 0;
}
