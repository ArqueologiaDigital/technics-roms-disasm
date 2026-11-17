/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ButtonState_PaintProc DrawEditSw GetBoxCenter GetEditSwPoint VwBoxProc */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void *__cdecl Malloc(unsigned int);
extern void MainFuncCall(long fn, long evt, void *par);
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainBitControl 0x1400007L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_BIT_GET 0x1e00066L
struct bitreq { long id; long v; int c; long z; };
extern void MainBitGet(long id, long v);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
#define EVT_BIT_PUT 0x1e00067L
extern void MainBitPut(struct bitreq *req);
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define EVT_LSW_ADD 0x1e00058L
struct lswreq { long id; int a; int b; long z; };
extern int MainLswAdd(long id, int a, int b);
#define EVT_LSW_PUT 0x1e00057L
extern int MainLswPut(long id, int a, int b);
#define NAKA_MAINFUNC_MainRamControl 0x1400008L
#define EVT_RAM_ADD 0x1e0006aL
struct ramreq { char b[22]; };
extern void MainRamAdd(struct ramreq *req);
#define EVT_RAM_PUT 0x1e00069L
extern void MainRamPut(struct ramreq *req);
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
extern long PsEditSwBoxProc(long obj, long evt, long p);

void MainBitGet(long id, long v)
{
    struct bitreq *p;
    p = (struct bitreq *)Malloc(sizeof(struct bitreq));
    p->id = id;
    p->v = v;
    p->c = 0;
    p->z = 0;
    MainFuncCall(NAKA_MAINFUNC_MainBitControl, EVT_BIT_GET, p);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
}

void MainBitPut(struct bitreq *req)
{
    struct bitreq *p;
    p = (struct bitreq *)Malloc(sizeof(struct bitreq));
    Mem_Copy(p, req, sizeof(struct bitreq));
    MainFuncCall(NAKA_MAINFUNC_MainBitControl, EVT_BIT_PUT, p);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
}

int MainLswAdd(long id, int a, int b)
{
    struct lswreq *p;
    p = (struct lswreq *)Malloc(sizeof(struct lswreq));
    p->id = id;
    p->a = a;
    p->b = b;
    p->z = 0;
    MainFuncCall(NAKA_MAINFUNC_MainPmanControl, EVT_LSW_ADD, p);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
    return 0;
}

int MainLswPut(long id, int a, int b)
{
    struct lswreq *p;
    p = (struct lswreq *)Malloc(sizeof(struct lswreq));
    p->id = id;
    p->a = a;
    p->b = b;
    p->z = 0;
    MainFuncCall(NAKA_MAINFUNC_MainPmanControl, EVT_LSW_PUT, p);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
    return 0;
}

void MainRamAdd(struct ramreq *req)
{
    struct ramreq *p;
    p = (struct ramreq *)Malloc(sizeof(struct ramreq));
    *p = *req;
    MainFuncCall(NAKA_MAINFUNC_MainRamControl, EVT_RAM_ADD, p);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
}

void MainRamPut(struct ramreq *req)
{
    struct ramreq *p;
    p = (struct ramreq *)Malloc(sizeof(struct ramreq));
    *p = *req;
    MainFuncCall(NAKA_MAINFUNC_MainRamControl, EVT_RAM_PUT, p);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
}

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
