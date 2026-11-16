/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_widget_defs_m272_xr.c (2026-11-16-92-p6-r18)
   sha256 97a388927330aa1e8fb4e02fe3c1ade305d64cc6285bc54d620dde5c5af0c598 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
struct box { int x, y, w, h; };
struct viewable { char hdr[4]; int super, sub, next, prev; unsigned int flags; struct box box; };
extern struct viewable *GetViewInstance(unsigned long id);
int GetVisible(unsigned long id)
{
    return (GetViewInstance(id)->flags & 0x1) == 0;
}
