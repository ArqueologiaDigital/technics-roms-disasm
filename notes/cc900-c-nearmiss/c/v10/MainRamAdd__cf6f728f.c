/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_20m271a.c (2026-11-16-128-p6-r27)
   sha256 cf6f728f95f4b0960a78ca772ea2731644d39654b4b1d9894469d77f9865cdac (tar-sha256); compiled at -Xr */
extern void *__cdecl Malloc(unsigned int);
extern void MainFuncCall(long fn, long evt, void *par);
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainRamControl 0x1400008L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_RAM_ADD 0x1e0006aL
struct ramreq { char b[22]; };
void MainRamAdd(struct ramreq *req)
{
    struct ramreq *p;
    p = (struct ramreq *)Malloc(sizeof(struct ramreq));
    *p = *req;
    MainFuncCall(NAKA_MAINFUNC_MainRamControl, EVT_RAM_ADD, p);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
}
