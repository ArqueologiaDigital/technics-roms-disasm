/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/ui_widget_defs_m271.c (2026-11-18-28-p6-r36)
   sha256 ed56b75cb355c393c29e78af9db3f13dd6eea3cb3ec4b985e1c1b2fa2060e079 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_LSW_GET 0x1e00059L
struct lswreq { long id; int a; int b; long z; };
extern void *__cdecl Malloc(unsigned int);
extern void FuncCall(long fn, long evt, void *par);
int MainLswGet(long id)
{
    struct lswreq *p;
    p = (struct lswreq *)Malloc(sizeof(struct lswreq));
    p->id = id;
    p->a = 0;
    p->b = 0;
    p->z = 0;
    FuncCall(NAKA_MAINFUNC_MainPmanControl, EVT_LSW_GET, p);
    FuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
    return 0;
}
