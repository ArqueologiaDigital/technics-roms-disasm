/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/ui_widget_defs_m271.c (2026-11-16-125-p6-r26-staged)
   sha256 11c21d746f1ddae7f6edc3892029f4a755181251b8328d95aec68a215161a07c (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define NAKA_MAINFUNC_MainAutoFree   0x1400003L
#define NAKA_MAINFUNC_MainRamControl 0x1400008L
#define EVT_AUTO_FREE                0x1e00023L
#define EVT_RAM_GET                  0x1e00068L
struct ramreq { long addr; int size; long r6; long r10; long r14; long r18; };
extern void *__cdecl Malloc(unsigned int);
extern long MainFuncCall(long, long, void *);
void MainRamGet(long addr, int size)
{
    struct ramreq *r;

    r = (struct ramreq *)Malloc(sizeof(struct ramreq));
    r->addr = addr;
    r->size = size;
    r->r6 = 0;
    r->r10 = 0;
    r->r14 = 0;
    r->r18 = 0;
    MainFuncCall(NAKA_MAINFUNC_MainRamControl, EVT_RAM_GET, r);
    MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, r);
}
