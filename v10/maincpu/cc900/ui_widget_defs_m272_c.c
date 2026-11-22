/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FunctionProc */   /* scripts/analysis/cc900/module_calls.py v10 */

struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
extern struct objent OBJECT_REGISTRY[];
#define EVT_GET_CLASS_SP		0x1e00000L
#define EVT_GET_NAME			0x1e00015L
#define NAKA_CLASS_ApFunction		0x1600002L
extern long FunctionProc(unsigned long obj, long evt, long par);
extern long ApFunctionProc(unsigned long obj, long evt, long par);
#define NAKA_CLASS_MainFunction		0x1600003L
extern long MainFunctionProc(unsigned long obj, long evt, long par);

long ApFunctionProc(unsigned long obj, long evt, long par)
{
	unsigned int t;
	unsigned int i;
	long *p;

	switch (evt) {
	default:
		return FunctionProc(obj, evt, par);
	case EVT_GET_CLASS_SP:
		return NAKA_CLASS_ApFunction;
	case EVT_GET_NAME:
		t = (unsigned int)((obj >> 16) & 0xfff);
		i = obj & 0xffff;
		p = (long *)OBJECT_REGISTRY[t + 0x300].data;
		return p[i];
	}
}

long MainFunctionProc(unsigned long obj, long evt, long par)
{
	unsigned int t;
	unsigned int i;
	long *p;

	switch (evt) {
	default:
		return FunctionProc(obj, evt, par);
	case EVT_GET_CLASS_SP:
		return NAKA_CLASS_MainFunction;
	case EVT_GET_NAME:
		t = (unsigned int)((obj >> 16) & 0xfff);
		i = obj & 0xffff;
		p = (long *)OBJECT_REGISTRY[t + 0x300].data;
		return p[i];
	}
}
