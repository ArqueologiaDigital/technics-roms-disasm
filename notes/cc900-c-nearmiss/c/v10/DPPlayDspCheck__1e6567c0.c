/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Y_22r1m232c.c (2026-11-21-21-p6-r66)
   sha256 1e6567c08c715fc9d94212fe454b41a0e7eaab4abc9ab89cfa1ba7c7391bfba7 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
#define EVT_GET_LARGE_STEP           0x1e0003eL
#define EVT_GET_SMALL_STEP           0x1e0003fL
#define EVT_GET_MAX                  0x1e00043L
#define EVT_GET_MIN                  0x1e00044L
#define EVT_GET_RAM_ADDRESS          0x1e00045L
#define EVT_GET_RAM_SIZE             0x1e00046L
#define EVT_GET_RAM_STRING           0x1e00047L
#define EVT_RAM_DATA_REQ             0x1e00082L
struct ramreq { unsigned char *addr; unsigned char pad[10]; long val; char *str; };
extern unsigned char ram_21092;
extern char PlayModeStr_Play[];
extern char DPPlayDsp_Dispatch_Str[];
extern int __cdecl Sprintf_Locked(char *, char *, ...);
long DPPlayDspCheck(long obj, long evt, long p)
{
	switch (evt) {
	case EVT_GET_RAM_STRING:
		Sprintf_Locked(((struct ramreq *)p)->str,
			((struct ramreq *)p)->val ? DPPlayDsp_Dispatch_Str : PlayModeStr_Play);
		return obj;
	case EVT_GET_LARGE_STEP:
		return 4;
	case EVT_GET_SMALL_STEP:
	case EVT_GET_RAM_SIZE:
		return 1;
	case EVT_GET_MAX:
		return 16;
	case EVT_GET_MIN:
		return -29;
	case EVT_GET_RAM_ADDRESS:
		return (long)&ram_21092;
	case EVT_RAM_DATA_REQ:
		break;
	}
	return 0;
}
