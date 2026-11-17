/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_20m271b.c (2026-11-16-128-p6-r27)
   sha256 0a2511542ad4640a05aaaff489adc4f9b3a2ddc7305132cc5373962ff49e6961 (tar-sha256); compiled at -Xr */
extern void *__cdecl Malloc(unsigned int);
extern void MainFuncCall(long fn, long evt, void *par);
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainBitControl 0x1400007L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_BIT_GET 0x1e00066L
struct bitreq { unsigned long id; long v; int c; long z; };
void MainBitGet(unsigned long id, long v)
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
