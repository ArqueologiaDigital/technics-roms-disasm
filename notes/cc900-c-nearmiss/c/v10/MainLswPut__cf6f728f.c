/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_20m271a.c (2026-11-16-128-p6-r27)
   sha256 cf6f728f95f4b0960a78ca772ea2731644d39654b4b1d9894469d77f9865cdac (tar-sha256); compiled at -Xr */
extern void *__cdecl Malloc(unsigned int);
extern void MainFuncCall(long fn, long evt, void *par);
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_LSW_PUT 0x1e00057L
struct lswreq { long id; int a; int b; long z; };
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
