/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_20m271a.c (2026-11-16-128-p6-r27)
   sha256 cf6f728f95f4b0960a78ca772ea2731644d39654b4b1d9894469d77f9865cdac (tar-sha256); compiled at -Xr */
extern void *__cdecl Malloc(unsigned int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void MainFuncCall(long fn, long evt, void *par);
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainBitControl 0x1400007L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_BIT_PUT 0x1e00067L
struct bitreq { long id; long v; int c; long z; };
void MainBitPut(struct bitreq *req)
{
    struct bitreq *p;
    p = (struct bitreq *)Malloc(sizeof(struct bitreq));
    Mem_Copy(p, req, sizeof(struct bitreq));
    MainFuncCall(NAKA_MAINFUNC_MainBitControl, EVT_BIT_PUT, p);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
}
