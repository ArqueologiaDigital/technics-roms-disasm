/* lane_p6 helper K, round 27r1, form a: module 272 (ui/ui_widget_defs.s), family of 2 x 75 B: ApFunctionProc /
   MainFunctionProc, the table procs of the ApFunction / MainFunction classes.  MT_GetName returns the name pointer
   of the object from the slot 0x300 above its own (as FunctionProc's GET_NAME case, p6_G_25r1m272a), MT_GetClassSp
   the class id; everything else goes on to FunctionProc (a tail jump).  Switch with the cases in reverse compare
   order (CLASS_SP, then GET_NAME).  Form a: default written first.
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
		i = (unsigned int)obj;
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
		i = (unsigned int)obj;
		return ((long *)OBJECT_REGISTRY[t + 0x300].data)[i];
	}
}
