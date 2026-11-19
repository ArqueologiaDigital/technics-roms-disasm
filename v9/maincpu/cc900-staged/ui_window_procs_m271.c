/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawDesignFrame GetClientBox */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_DRAW            0x1c0000dL
#define EVT_DRAW_SELECTED   0x1e0004eL
#define EVT_GET_INDEX       0x1e00051L
#define EVT_CHECK_INDEX     0x1e00050L
#define EVT_GET_BOX_BORDER  0x1e000b1L
#define EVT_GET_BOX_COLOR   0x1e000b2L
struct rect { int x0, y0, x1, y1; };
struct vwbox { unsigned char pad[14]; struct rect box; int color; int border; int index; };
extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern void DrawDesignBox(struct rect *, int, int);
extern void GetClientBox(long, struct rect *);
extern void DrawDesignFrame(struct rect *, int, int, int);
extern long VwBoxProc(long obj, long evt, long p);

long VwBoxProc(long obj, long evt, long p)
{
    struct rect box;
    struct vwbox *v;

    switch (evt) {
    case EVT_DRAW:
        ViewableProc(obj, evt, p);
        v = GetViewInstance(obj);
        DrawDesignBox(&v->box, v->border, v->color);
        return 0;
    case EVT_DRAW_SELECTED:
        GetClientBox(obj, &box);
        v = GetViewInstance(obj);
        if ((int)p != 0)
            DrawDesignFrame(&box, 1, 2, 0xf2);
        else
            DrawDesignFrame(&box, 1, 2, v->color);
        return 0;
    case EVT_GET_INDEX:
        return ((struct vwbox *)GetViewInstance(obj))->index;
    case EVT_CHECK_INDEX:
        v = GetViewInstance(obj);
        return (unsigned int)((long)v->index == p);
    case EVT_GET_BOX_BORDER:
        return ((struct vwbox *)GetViewInstance(obj))->border;
    case EVT_GET_BOX_COLOR:
        return ((struct vwbox *)GetViewInstance(obj))->color;
    default:
        return ViewableProc(obj, evt, p);
    }
}
