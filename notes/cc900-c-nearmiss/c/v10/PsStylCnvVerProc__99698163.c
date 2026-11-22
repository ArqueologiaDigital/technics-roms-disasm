/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_A_22r2m159b.c (2026-11-21-21-p6-r66)
   sha256 99698163567eb90fdb2d9ba9d621a9a727e06ea0042273b400be20f31daf70f5 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_SHOW              0x1c00001L
#define EVT_HIDE              0x1c00002L
#define EVT_PAINT             0x1c0000bL
#define EVT_REPAINT           0x1c0000cL
#define EVT_PARA_DRAW         0x1c0000fL
#define EVT_GET_STR_PTR       0x1e00089L
extern char __near ram_3f68[];
extern long InheritedProc(long, long, long);
extern long SendEvent(long, long, long);
extern char *__cdecl Strcpy(char *, char *);
long PsStylCnvVerProc(long obj, long evt, long p)
{
	char buf[512];

	switch (evt) {
	default:
		return InheritedProc(obj, evt, p);
	case EVT_HIDE:
	case EVT_SHOW:
		InheritedProc(obj, evt, p);
		break;
	case EVT_GET_STR_PTR:
		return (long)ram_3f68;
	case EVT_PAINT:
	case EVT_REPAINT:
		InheritedProc(obj, evt, p);
		Strcpy(buf, ram_3f68);
		SendEvent(obj, EVT_PARA_DRAW, (long)buf);
		break;
	}
	return 0;
}
