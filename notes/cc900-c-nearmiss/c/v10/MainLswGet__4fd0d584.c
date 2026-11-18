/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_1m271b.c (2026-11-18-12-p6-r35)
   sha256 4fd0d584b045ef203f133b9946170b09895552c68437bae1196158d1091ab7f8 (tar-sha256); compiled at -Xr */
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_LSW_GET 0x1e00059L
struct lswreq { long id; int a; int b; long z; };
extern void *__cdecl Malloc(unsigned int);
extern void FuncCall(long fn, long evt, void *par);
int MainLswGet(long id)
{
    struct lswreq *p;
    p = (struct lswreq *)Malloc(sizeof(struct lswreq));
    p->id = id;
    p->a = 0;
    p->b = 0;
    p->z = 0;
    FuncCall(NAKA_MAINFUNC_MainPmanControl, EVT_LSW_GET, p);
    FuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
    return 0;
}
