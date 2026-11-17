/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_widget_defs_m273.c (2026-11-16-68-p6-r12)
   sha256 64df5cb9a289be32e163c37caa5768e0fbc9ed75408d02153f61b77bf4f175c2 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct rect { int x0, y0, x1, y1; };
extern int ram_3ef4e;
extern int DISPLAY_UPDATE_FLAG;
extern struct rect DIRTY_BBOX;
extern void Kernel_SetTaskLevel(int, int);
void SetChangeRect(struct rect *r)
{
    if (ram_3ef4e != 0)
        Kernel_SetTaskLevel(5, 3);
    DISPLAY_UPDATE_FLAG = 1;
    if (DIRTY_BBOX.y0 > r->y0)
        DIRTY_BBOX.y0 = r->y0;
    if (DIRTY_BBOX.x0 > r->x0)
        DIRTY_BBOX.x0 = r->x0;
    if (DIRTY_BBOX.x1 < r->x1)
        DIRTY_BBOX.x1 = r->x1;
    if (DIRTY_BBOX.y1 < r->y1)
        DIRTY_BBOX.y1 = r->y1;
}
