/* Phase 6, lane_p6 helper A, round 20, form a: module 271 (ui/ui_widget_defs.s), the MainFunction request
   posters MainLswPut / MainLswAdd / MainBitGet / MainBitPut / MainRamPut / MainRamAdd (new).  Signed types. */
extern void *__cdecl Malloc(unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void MainFuncCall(long fn, long evt, void *par);
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define NAKA_MAINFUNC_MainBitControl 0x1400007L
#define NAKA_MAINFUNC_MainRamControl 0x1400008L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_LSW_PUT 0x1e00057L
#define EVT_LSW_ADD 0x1e00058L
#define EVT_BIT_GET 0x1e00066L
#define EVT_BIT_PUT 0x1e00067L
#define EVT_RAM_PUT 0x1e00069L
#define EVT_RAM_ADD 0x1e0006aL
/* the request blocks: LSW 12 bytes, BIT 14 bytes, RAM 22 bytes */
struct lswreq { long id; int a; int b; long z; };
struct bitreq { long id; long v; int c; long z; };
struct ramreq { char b[22]; };

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

void MainRamPut(struct ramreq *req)
{
    struct ramreq *p;
    p = (struct ramreq *)Malloc(sizeof(struct ramreq));
    *p = *req;
    MainFuncCall(NAKA_MAINFUNC_MainRamControl, EVT_RAM_PUT, p);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
}

void MainRamAdd(struct ramreq *req)
{
    struct ramreq *p;
    p = (struct ramreq *)Malloc(sizeof(struct ramreq));
    *p = *req;
    MainFuncCall(NAKA_MAINFUNC_MainRamControl, EVT_RAM_ADD, p);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
}
