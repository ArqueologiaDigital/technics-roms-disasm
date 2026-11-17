/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_widget_defs_m271.c (2026-11-17-1-p6-r28-staged)
   sha256 dbf0049cb0cc41e34aea198a822b60250f77526c12f76ff45a26a1258d282ad1 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
#define EVT_DRAW            0x1c0000dL
#define EVT_PARA_DRAW       0x1c0000fL
#define EVT_REPAINT         0x1c0000cL
#define EVT_CHECK_EDIT_SW   0x1e00053L
#define EVT_SET_VISIBLE     0x1e0009cL
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L
extern void *GetViewInstance(long);
extern long SendEvent(long, long, long);
extern int GetVisible(long);
extern void GetBox(long, struct rect *);
extern void GetEditSwPoint(unsigned int, struct pt *);
extern void DrawEditSw(unsigned int);
extern void DrawBox(struct rect *, int);
struct esinst { unsigned char pad[36]; unsigned int swid; };
#define EVT_GET_STRING      0x1e0003aL
extern long VwBoxProc(long, long, long);
extern void ButtonState_PaintProc(long, int);
long PsEditSwBoxProc(long obj, long evt, long p)
{
    struct esinst *t;
    struct pt pt;
    struct rect box;
    struct esinst *h;

    switch (evt) {
    default:
        return VwBoxProc(obj, evt, p);
    case EVT_GET_STRING:
        *(char *)p = 0;
        return 0;
    case EVT_DRAW:
        VwBoxProc(obj, evt, p);
        h = GetViewInstance(obj);
        GetEditSwPoint(h->swid, (struct pt *)&pt.x);
        if (pt.y != 0xef)
            DrawEditSw(h->swid);
        return 0;
    case EVT_PARA_DRAW:
        ButtonState_PaintProc(obj, (unsigned char)p);
        return 0;
    case EVT_CHECK_EDIT_SW:
        t = GetViewInstance(obj);
        if (GetVisible(obj) != 0 && t->swid == SendEvent(0x2600024L, EVT_MAKE_EDIT_SW_ID, p))
            return 1;
        return 0;
    case EVT_SET_VISIBLE:
        VwBoxProc(obj, evt, p);
        if (GetVisible(obj) != 0)
            SendEvent(obj, EVT_REPAINT, 0);
        else {
            t = GetViewInstance(obj);
            GetBox(obj, (struct rect *)&box.x1);
            GetEditSwPoint(t->swid, (struct pt *)&pt.x);
            if (pt.y != 0xef) {
                if (pt.x != 0x13f)
                    box.x1 = 0;
                else
                    box.x2 = 0x13f;
            }
            DrawBox(&box, 0xf5);
        }
        return 0;
    }
}
