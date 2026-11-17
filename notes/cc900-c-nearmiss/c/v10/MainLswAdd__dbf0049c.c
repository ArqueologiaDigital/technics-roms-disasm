/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_widget_defs_m271.c (2026-11-17-1-p6-r28-staged)
   sha256 dbf0049cb0cc41e34aea198a822b60250f77526c12f76ff45a26a1258d282ad1 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void *__cdecl Malloc(unsigned int);
extern void MainFuncCall(long fn, long evt, void *par);
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define EVT_AUTO_FREE 0x1e00023L
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define EVT_LSW_ADD 0x1e00058L
struct lswreq { long id; int a; int b; long z; };
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
