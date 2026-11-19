/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_window_procs_m271.c (2026-11-19-15-p6-r42)
   sha256 42e90b08bd57adc3623f4af2f1ef36f68c91af0cc0c303718dcf2ab4aeb802fb (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
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
