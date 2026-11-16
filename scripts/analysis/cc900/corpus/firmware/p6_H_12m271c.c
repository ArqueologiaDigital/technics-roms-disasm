/* Form c: as form a, plus PsToggleBoxProc takes the address of t in a statement that computes nothing: run 118 gave
   SET_VISIBLE's short use of t the XIZ home (the ROM keeps it in the frame at +4); LayoutB's round 11 form c showed
   that an address-taken local stays out of the homes.
   lane_p6 helper H, round 12, module 271 (ui/ui_widget_defs.s), form a: PsToggleBoxProc, IvExitProc, MainRamGet from
   round 11 form c (run 118: +17 / +80 / +45).
   PsToggleBoxProc: (1) the rectangle / point arguments the ROM computes before the other arguments are spelt as
   member addresses with a cast (`(struct pt *)&pt.x`, LabelProc's idiom): GetEditSwPoint's point before the switch
   number, DrawStringCentered's box and centre before its stack arguments.  (2) The zero returns are `break`s to one
   `return 0` after the switch, so that the hit test is no longer folded into a set-on-condition and the REPAINT
   SendEvent is not merged with the other two.  (3) SET_VISIBLE as an if / else (no early return).
   IvExitProc: the hit test widened unsigned (the ROM's extz).  MainRamGet: the request passed as a pointer (no
   cast), so it is loaded last into XDE. */
/* cc900-module: DrawEditSw GetBoxCenter GetEditSwPoint PsInvisibleBoxProc */

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

    (void)&t;
    switch (evt) {
    case EVT_DRAW:
        ViewableProc(obj, evt, p);
        h = GetViewInstance(obj);
        GetEditSwPoint(h->swid, (struct pt *)&pt.x);
        if (pt.y != 0xef)
            DrawEditSw(h->swid);
        SendEvent(obj, EVT_PARA_DRAW, *h->value);
        break;
    case EVT_PARA_DRAW:
        ViewableProc(obj, evt, p);
        t = GetViewInstance(obj);
        if (*t->value != p)
            *t->value = (int)p;
        GetClientBox(obj, &box);
        GetBoxCenter(&box, &c);
        if (*t->value != 0) {
            if (t->swid <= 7)
                DrawDesignBox(&t->r, 0xca, 10);
            else
                DrawDesignBox(&t->r, 0xc3, 10);
            DrawStringCentered((struct rect *)&box.x1, (struct pt *)&c.x, t->on, t->font, 0xff, 0xf7);
        } else {
            if (t->swid <= 7)
                DrawDesignBox(&t->r, 0xc9, 7);
            else
                DrawDesignBox(&t->r, 0xc1, 7);
            DrawStringCentered((struct rect *)&box.x1, (struct pt *)&c.x, t->off, t->font, 0, 0xf7);
        }
        break;
    case EVT_CHECK_EDIT_SW:
        t = GetViewInstance(obj);
        if (GetVisible(obj) == 0)
            break;
        if (t->swid == SendEvent(0x2600024L, EVT_MAKE_EDIT_SW_ID, p))
            return 1;
        break;
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
        break;
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
        break;
    default:
        return ViewableProc(obj, evt, p);
    }
    return 0;
}

#define EVT_GET_STRING      0x1e0003aL
extern long PsInvisibleBoxProc(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern char IvExit_GetText_Str_EXIT[];

long IvExitProc(long obj, long evt, long p)
{
    switch (evt) {
    default:
        return PsInvisibleBoxProc(obj, evt, p);
    case EVT_DRAW:
        PsInvisibleBoxProc(obj, evt, p);
        SendEvent(obj, EVT_PARA_DRAW, 0);
        return 0;
    case EVT_GET_STRING:
        Strcpy((char *)p, IvExit_GetText_Str_EXIT);
        return 0;
    case EVT_CHECK_EDIT_SW:
        return (unsigned int)(p == 0xf);
    }
}

#define NAKA_MAINFUNC_MainAutoFree   0x1400003L
#define NAKA_MAINFUNC_MainRamControl 0x1400008L
#define EVT_AUTO_FREE                0x1e00023L
#define EVT_RAM_GET                  0x1e00068L

struct ramreq { long addr; int size; long r6; long r10; long r14; long r18; };
extern void *__cdecl Malloc(unsigned int);
extern long MainFuncCall(long, long, void *);

void MainRamGet(long addr, int size)
{
    struct ramreq *r;

    r = (struct ramreq *)Malloc(sizeof(struct ramreq));
    r->addr = addr;
    r->size = size;
    r->r6 = 0;
    r->r10 = 0;
    r->r14 = 0;
    r->r18 = 0;
    MainFuncCall(NAKA_MAINFUNC_MainRamControl, EVT_RAM_GET, r);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, r);
}
