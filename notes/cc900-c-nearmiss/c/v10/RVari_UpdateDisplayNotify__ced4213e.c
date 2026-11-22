/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_31r1m276a.c (2026-11-22-15-p6-r82)
   sha256 ced4213ebc4d84a765d62a195df43b5abd808fd5019961c3be1e2c0e5103ca82 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define NAKA_MAINFUNC_MainAutoFree   0x1400003L
#define NAKA_MAINFUNC_MainVariSet    0x1420000L
#define EVT_AUTO_FREE                0x1e00023L
#define EVT_VARI_WRITE               0x1e20000L
struct varireq { unsigned char v0, v1, v2, v3; };
struct rvview { unsigned char pad[48]; int *p48; int *p52; int *p56; int *p60; };
extern void *__cdecl Malloc(unsigned int);
extern long MainFuncCall(long, long, void *);
extern struct rvview *GetViewInstance(long);
void RVari_UpdateDisplayNotify(long obj)
{
    struct rvview *v;
    struct varireq *r;

    v = GetViewInstance(obj);
    r = (struct varireq *)Malloc(sizeof(struct varireq));
    r->v0 = *v->p48;
    r->v1 = 0;
    r->v2 = *v->p56;
    r->v3 = *v->p60;
    MainFuncCall(NAKA_MAINFUNC_MainVariSet, EVT_VARI_WRITE, r);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, r);
}
