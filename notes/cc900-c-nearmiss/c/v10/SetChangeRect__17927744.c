/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_2m273b.c (2026-11-16-53-p6-r11)
   sha256 17927744d7bdced234f7dd3b8338e30197b2f8ed2608f9f9e4721cc1e4badaeb (tar-sha256); compiled at -O3 -Xr */
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
    if (r->y0 < DIRTY_BBOX.y0)
        DIRTY_BBOX.y0 = r->y0;
    if (r->x0 < DIRTY_BBOX.x0)
        DIRTY_BBOX.x0 = r->x0;
    if (r->x1 > DIRTY_BBOX.x1)
        DIRTY_BBOX.x1 = r->x1;
    if (r->y1 > DIRTY_BBOX.y1)
        DIRTY_BBOX.y1 = r->y1;
}
