/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_27r1m272a.c (2026-11-22-7-p6-r74)
   sha256 362f9fff8f237fb74c4593d128c33c76739c5baab71ef645b0fa25639aa9ec42 (tar-sha256); compiled at -O3 -Xr
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
		i = (unsigned int)obj;
		return ((long *)OBJECT_REGISTRY[t + 0x300].data)[i];
	}
}
