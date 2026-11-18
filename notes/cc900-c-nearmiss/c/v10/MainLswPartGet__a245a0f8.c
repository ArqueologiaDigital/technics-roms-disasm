/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_widget_defs_m0.c (2026-11-18-28-p6-r36)
   sha256 a245a0f8b3e34e4735387b551039b47fa453d7aca9759caca312cc5ff73fa19f (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_LSW_PART_GET 0x1e0005cL
struct lswreq { long id; int a; int b; long z; };
extern void *__cdecl Malloc(unsigned int);
extern void FuncCall(long fn, long evt, void *par);
int MainLswPartGet(unsigned int part, unsigned int idx)
{
    struct lswreq *p;
    p = (struct lswreq *)Malloc(sizeof(struct lswreq));
    p->id = ((unsigned long)part << 16) + idx;
    p->a = 0;
    p->b = 0;
    p->z = 0;
    FuncCall(NAKA_MAINFUNC_MainPmanControl, EVT_LSW_PART_GET, p);
    FuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
    return 0;
}
