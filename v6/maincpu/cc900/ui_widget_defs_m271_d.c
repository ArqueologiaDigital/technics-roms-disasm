/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_LSW_PART_ADD 0x1e0005bL
struct lswadd { long id; int c; int d; long z; };
extern void *__cdecl Malloc(unsigned int);
extern long MainFuncCall(long fn, long evt, void *par);
extern int MainLswPartAdd(unsigned int part, unsigned int idx, int c, int d);

int MainLswPartAdd(unsigned int part, unsigned int idx, int c, int d)
{
	struct lswadd *p;

	p = (struct lswadd *)Malloc(sizeof(struct lswadd));
	p->id = ((unsigned long)part << 16) + idx;
	p->c = c;
	p->d = d;
	p->z = 0;
	MainFuncCall(NAKA_MAINFUNC_MainPmanControl, EVT_LSW_PART_ADD, p);
	MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
	return 0;
}
