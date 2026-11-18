/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_LSW_GET 0x1e00059L
struct lswreq { long id; int a; int b; long z; };
extern void *__cdecl Malloc(unsigned int);
extern void FuncCall(long fn, long evt, void *par);
extern int MainLswGet(long id);

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
