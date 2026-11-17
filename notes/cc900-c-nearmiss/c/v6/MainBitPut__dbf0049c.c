/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_widget_defs_m271.c (2026-11-17-1-p6-r28-staged)
   sha256 dbf0049cb0cc41e34aea198a822b60250f77526c12f76ff45a26a1258d282ad1 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void *__cdecl Malloc(unsigned int);
extern void MainFuncCall(long fn, long evt, void *par);
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainBitControl 0x1400007L
#define EVT_AUTO_FREE 0x1e00023L
struct bitreq { long id; long v; int c; long z; };
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
#define EVT_BIT_PUT 0x1e00067L
void MainBitPut(struct bitreq *req)
{
    struct bitreq *p;
    p = (struct bitreq *)Malloc(sizeof(struct bitreq));
    Mem_Copy(p, req, sizeof(struct bitreq));
    MainFuncCall(NAKA_MAINFUNC_MainBitControl, EVT_BIT_PUT, p);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
}
