/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_28r1m272c.c (2026-11-22-9-p6-r76)
   sha256 dcf9fb774e803b94f10826b1f0dad53486bb2b57f79d9b4c1685907bdbff2ece (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct objent { long cls; long (*proc)(unsigned long, long, long); int count; void *data; };
extern struct objent OBJECT_REGISTRY[];
#define EVT_GET_CLASS_SP		0x1e00000L
#define EVT_GET_NAME			0x1e00015L
#define NAKA_CLASS_MainFunction		0x1600003L
extern long FunctionProc(unsigned long obj, long evt, long par);
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
		return *((long *)OBJECT_REGISTRY[t + 0x300].data + i);
	}
}
