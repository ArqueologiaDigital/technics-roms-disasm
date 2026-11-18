/* Phase 6, lane_p6 helper I, round 4, module 271 (ui/ui_window_procs.s), form a.  New.
   VwBoxProc(obj, evt, p): the view box's window procedure.  EVT_DRAW: the base ViewableProc, then the design box
   (DrawDesignBox(&v->box, v->border, v->color)); EVT_DRAW_SELECTED: the client box framed (DrawDesignFrame(&box, 1,
   2, colour), 0xf2 when p != 0 (tested as 16 bits), else v->color); EVT_GET_INDEX / EVT_GET_BOX_BORDER /
   EVT_GET_BOX_COLOR: the view's int at +0x1a / +0x18 / +0x16 (a shared tail with the offset in a register: here a
   long local and a goto); EVT_CHECK_INDEX: v->index == p; anything else ViewableProc.  The ROM compares the
   events last case first (written in source order DRAW .. GET_BOX_COLOR), the DRAW case falls out of the compare
   chain.  Form b: the field read written out in each case (V4.23's cross-jumping left to do the sharing). */
/* cc900-module: DrawDesignFrame GetClientBox */

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
    long off;

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
        off = 0x1a;
        goto field;
    case EVT_CHECK_INDEX:
        v = GetViewInstance(obj);
        return (long)v->index == p;
    case EVT_GET_BOX_BORDER:
        off = 0x18;
        goto field;
    case EVT_GET_BOX_COLOR:
        off = 0x16;
field:
        return *(int *)((char *)GetViewInstance(obj) + off);
    default:
        return ViewableProc(obj, evt, p);
    }
}
