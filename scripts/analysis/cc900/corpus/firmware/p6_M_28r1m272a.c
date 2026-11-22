/* lane_p6 helper M, round 28r1, form a: module 272 (ui/ui_widget_defs.s), family of 2 x 75 B:
   ApFunctionProc / MainFunctionProc.  One-spot retry of helper K's p6_K_27r1m272a (run r74, O3Xr equal
   to +34: the ROM clears the high word of obj in place before copying the index to DE, and reads the
   table pointer before scaling the index).  K's form a with the index taken as obj & 0xffff.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FunctionProc */

struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
extern struct objent OBJECT_REGISTRY[];

#define EVT_GET_CLASS_SP		0x1e00000L
#define EVT_GET_NAME			0x1e00015L
#define NAKA_CLASS_ApFunction		0x1600002L
#define NAKA_CLASS_MainFunction		0x1600003L

extern long FunctionProc(unsigned long obj, long evt, long par);
extern long ApFunctionProc(unsigned long obj, long evt, long par);
extern long MainFunctionProc(unsigned long obj, long evt, long par);

long ApFunctionProc(unsigned long obj, long evt, long par)
{
	unsigned int t;
	unsigned int i;

	switch (evt) {
	default:
		return FunctionProc(obj, evt, par);
	case EVT_GET_CLASS_SP:
		return NAKA_CLASS_ApFunction;
	case EVT_GET_NAME:
		t = (unsigned int)((obj >> 16) & 0xfff);
		i = obj & 0xffff;
		return ((long *)OBJECT_REGISTRY[t + 0x300].data)[i];
	}
}

long MainFunctionProc(unsigned long obj, long evt, long par)
{
	unsigned int t;
	unsigned int i;

	switch (evt) {
	default:
		return FunctionProc(obj, evt, par);
	case EVT_GET_CLASS_SP:
		return NAKA_CLASS_MainFunction;
	case EVT_GET_NAME:
		t = (unsigned int)((obj >> 16) & 0xfff);
		i = obj & 0xffff;
		return ((long *)OBJECT_REGISTRY[t + 0x300].data)[i];
	}
}
