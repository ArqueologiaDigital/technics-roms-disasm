/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_widget_defs_m271.c (2026-11-17-1-p6-r28-staged)
   sha256 dbf0049cb0cc41e34aea198a822b60250f77526c12f76ff45a26a1258d282ad1 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void *__cdecl Malloc(unsigned int);
extern void MainFuncCall(long fn, long evt, void *par);
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainBitControl 0x1400007L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_BIT_GET 0x1e00066L
struct bitreq { long id; long v; int c; long z; };
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
