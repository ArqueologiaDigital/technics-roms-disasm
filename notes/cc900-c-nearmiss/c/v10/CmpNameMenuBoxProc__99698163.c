/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_22r2m159b.c (2026-11-21-21-p6-r66)
   sha256 99698163567eb90fdb2d9ba9d621a9a727e06ea0042273b400be20f31daf70f5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_DRAW              0x1c0000dL
#define EVT_PARA_DRAW         0x1c0000fL
extern unsigned char __near STYLE_SECTION;
extern long InheritedProc(long, long, long);
extern long SendEvent(long, long, long);
long CmpNameMenuBoxProc(long obj, long evt, long p)
{
	if (evt == EVT_DRAW) {
		if (STYLE_SECTION < 12) {
			InheritedProc(obj, evt, p);
			SendEvent(obj, EVT_PARA_DRAW, 0L);
		}
		return 0;
	}
	return InheritedProc(obj, evt, p);
}
