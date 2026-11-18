/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_1m271a.c (2026-11-18-12-p6-r35)
   sha256 45167abbdbe727f1f9b5e54eada91b4f98f8c86266279e50196b46a4b0bc793b (tar-sha256); compiled at -O3 -XS -Xr */
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
