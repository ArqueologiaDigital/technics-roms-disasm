/* lane_p6 helper H, round 14, module 271 (ui/ui_widget_defs.s), form a: PsToggleBoxProc from round 13 form a.  Run 128:
   its bytes equal the ROM's except one instruction, V4.23's `ld XHL,XBC` before the PARA_DRAW branch (it copies the
   instance pointer out of XBC and then builds &swid in XBC from the copy, where the ROM builds it in XBC directly);
   every other difference is a displacement.  Here DrawDesignBox's rectangle is spelt as a cast member address
   (`(struct rect *)&t->r.x1`), which changes the order in which the hoisted addresses are made. */
/* cc900-module: DrawEditSw GetBoxCenter GetEditSwPoint */

struct pt { int x, y; };
struct rect { int x1, y1, x2, y2; };
struct tginst {
    unsigned char pad[14];
    struct rect r;
    long font;
    char *on;
    char *off;
    int *value;
    unsigned int swid;
};
#define EVT_DRAW            0x1c0000dL
#define EVT_PARA_DRAW       0x1c0000fL
#define EVT_REPAINT         0x1c0000cL
#define EVT_CHECK_EDIT_SW   0x1e00053L
#define EVT_TOGGLE_PARAM    0x1e0006cL
#define EVT_SET_PARAM       0x1e0003bL
#define EVT_GET_PARAM       0x1e0006bL
#define EVT_SET_VISIBLE     0x1e0009cL
#define EVT_MAKE_EDIT_SW_ID 0x1e00029L

extern long ViewableProc(long, long, long);
extern void *GetViewInstance(long);
extern long SendEvent(long, long, long);
extern int GetVisible(long);
extern void GetBox(long, struct rect *);
extern void GetClientBox(long, struct rect *);
extern void GetBoxCenter(struct rect *, struct pt *);
extern void GetEditSwPoint(unsigned int, struct pt *);
extern void DrawEditSw(unsigned int);
extern void DrawBox(struct rect *, int);
extern void DrawDesignBox(struct rect *, int, int);
extern void DrawStringCentered(struct rect *, struct pt *, char *, long, int, int);

long PsToggleBoxProc(long obj, long evt, long p)
{
    struct tginst *h;
    struct tginst *t;
    struct pt c;
    struct pt pt;
    struct rect box;

    switch (evt) {
    case EVT_DRAW:
        ViewableProc(obj, evt, p);
        h = GetViewInstance(obj);
        GetEditSwPoint(h->swid, (struct pt *)&pt.x);
        if (pt.y != 0xef)
            DrawEditSw(h->swid);
        SendEvent(obj, EVT_PARA_DRAW, *h->value);
        return 0;
    case EVT_PARA_DRAW:
        ViewableProc(obj, evt, p);
        t = GetViewInstance(obj);
        if (*t->value != p)
            *t->value = (int)p;
        GetClientBox(obj, &box);
        GetBoxCenter(&box, &c);
        if (*t->value != 0) {
            if (t->swid <= 7)
                DrawDesignBox((struct rect *)&t->r.x1, 0xca, 10);
            else
                DrawDesignBox((struct rect *)&t->r.x1, 0xc3, 10);
            DrawStringCentered((struct rect *)&box.x1, (struct pt *)&c.x, t->on, t->font, 0xff, 0xf7);
        } else {
            if (t->swid <= 7)
                DrawDesignBox((struct rect *)&t->r.x1, 0xc9, 7);
            else
                DrawDesignBox((struct rect *)&t->r.x1, 0xc1, 7);
            DrawStringCentered((struct rect *)&box.x1, (struct pt *)&c.x, t->off, t->font, 0, 0xf7);
        }
        return 0;
    case EVT_CHECK_EDIT_SW:
        t = GetViewInstance(obj);
        if (GetVisible(obj) != 0 && t->swid == SendEvent(0x2600024L, EVT_MAKE_EDIT_SW_ID, p))
            return 1;
        return 0;
    case EVT_TOGGLE_PARAM:
        t = GetViewInstance(obj);
        if (*t->value != 0)
            SendEvent(obj, EVT_PARA_DRAW, 0);
        else
            SendEvent(obj, EVT_PARA_DRAW, 1);
        return *t->value;
    case EVT_SET_PARAM:
        if ((int)p != *((struct tginst *)GetViewInstance(obj))->value)
            SendEvent(obj, EVT_PARA_DRAW, p);
        return 0;
    case EVT_GET_PARAM:
        return *((struct tginst *)GetViewInstance(obj))->value;
    case EVT_SET_VISIBLE:
        ViewableProc(obj, evt, p);
        if (GetVisible(obj) != 0)
            SendEvent(obj, EVT_REPAINT, 0);
        else {
            t = GetViewInstance(obj);
            GetBox(obj, (struct rect *)&box.x1);
            GetEditSwPoint(t->swid, (struct pt *)&c.x);
            if (c.y != 0xef) {
                if (c.x != 0x13f)
                    box.x1 = 0;
                else
                    box.x2 = 0x13f;
            }
            DrawBox(&box, 0xf5);
        }
        return 0;
    default:
        return ViewableProc(obj, evt, p);
    }
}
