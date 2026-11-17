/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_20m271a.c (2026-11-16-128-p6-r27)
   sha256 cf6f728f95f4b0960a78ca772ea2731644d39654b4b1d9894469d77f9865cdac (tar-sha256); compiled at -Xr */
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
