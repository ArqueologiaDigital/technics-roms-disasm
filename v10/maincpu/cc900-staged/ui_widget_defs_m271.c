/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawEditSw GetBoxCenter GetEditSwPoint PsInvisibleBoxProc */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_DRAW            0x1c0000dL
#define EVT_PARA_DRAW       0x1c0000fL
#define EVT_CHECK_EDIT_SW   0x1e00053L
extern long SendEvent(long, long, long);
#define EVT_GET_STRING      0x1e0003aL
extern long PsInvisibleBoxProc(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
extern char IvExit_GetText_Str_EXIT[];
extern long IvExitProc(long obj, long evt, long p);
#define NAKA_MAINFUNC_MainAutoFree   0x1400003L
#define NAKA_MAINFUNC_MainRamControl 0x1400008L
#define EVT_AUTO_FREE                0x1e00023L
#define EVT_RAM_GET                  0x1e00068L
struct ramreq { long addr; int size; long r6; long r10; long r14; long r18; };
extern void *__cdecl Malloc(unsigned int);
extern long MainFuncCall(long, long, void *);
extern void MainRamGet(long addr, int size);

long IvExitProc(long obj, long evt, long p)
{
    switch (evt) {
    default:
        return PsInvisibleBoxProc(obj, evt, p);
    case EVT_DRAW:
        PsInvisibleBoxProc(obj, evt, p);
        SendEvent(obj, EVT_PARA_DRAW, 0);
        return 0;
    case EVT_GET_STRING:
        Strcpy((char *)p, IvExit_GetText_Str_EXIT);
        return 0;
    case EVT_CHECK_EDIT_SW:
        return (unsigned int)(p == 0xf);
    }
}

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
