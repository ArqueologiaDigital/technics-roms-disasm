/* lane_p6 helper O, round 29r1, form a: module 271 (ui/ui_widget_defs.s), MainLswPartPut (101 B, singletons29_O): the
   EVT_LSW_PART_PUT twin of the built MainLswPartAdd (v10/maincpu/cc900/ui_widget_defs_m271_d.c), its C copied with
   the other event code.
   cc900-options: -O3 -Xr
*/

#define NAKA_MAINFUNC_MainAutoFree 0x1400003L
#define NAKA_MAINFUNC_MainPmanControl 0x1400002L
#define EVT_AUTO_FREE 0x1e00023L
#define EVT_LSW_PART_PUT 0x1e0005aL
struct lswadd { long id; int c; int d; long z; };
extern void *__cdecl Malloc(unsigned int);
extern long MainFuncCall(long fn, long evt, void *par);
extern int MainLswPartPut(unsigned int part, unsigned int idx, int c, int d);

int MainLswPartPut(unsigned int part, unsigned int idx, int c, int d)
{
	struct lswadd *p;

	p = (struct lswadd *)Malloc(sizeof(struct lswadd));
	p->id = ((unsigned long)part << 16) + idx;
	p->c = c;
	p->d = d;
	p->z = 0;
	MainFuncCall(NAKA_MAINFUNC_MainPmanControl, EVT_LSW_PART_PUT, p);
	MainFuncCall(NAKA_MAINFUNC_MainAutoFree, EVT_AUTO_FREE, p);
	return 0;
}
