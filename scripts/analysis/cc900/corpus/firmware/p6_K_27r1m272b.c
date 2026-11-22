/* lane_p6 helper K, round 27r1, form b: module 272 (ui/ui_widget_defs.s), family of 2 x 75 B: ApFunctionProc /
   MainFunctionProc (see form a).  Form b: the default (the tail jump to FunctionProc) written last, and the
   index spelled obj & 0xffff, in one expression.
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
	switch (evt) {
	case EVT_GET_CLASS_SP:
		return NAKA_CLASS_ApFunction;
	case EVT_GET_NAME:
		return ((long *)OBJECT_REGISTRY[(unsigned int)((obj >> 16) & 0xfff) + 0x300].data)
			[(unsigned int)(obj & 0xffff)];
	default:
		return FunctionProc(obj, evt, par);
	}
}

long MainFunctionProc(unsigned long obj, long evt, long par)
{
	switch (evt) {
	case EVT_GET_CLASS_SP:
		return NAKA_CLASS_MainFunction;
	case EVT_GET_NAME:
		return ((long *)OBJECT_REGISTRY[(unsigned int)((obj >> 16) & 0xfff) + 0x300].data)
			[(unsigned int)(obj & 0xffff)];
	default:
		return FunctionProc(obj, evt, par);
	}
}
