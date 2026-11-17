/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_widget_defs_m273.c (2026-11-16-92-p6-r18)
   sha256 d6e8ccc31017ee1c73049de8e8224ce0c21d45f7bdf56869afe3eaabe8b32393 (tar-sha256); compiled at -O3 -XS -Xr
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
