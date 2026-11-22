/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_ui_m0.c (2026-11-21-22-p6-r67)
   sha256 550ad2c4d29e45f52882d62ae4cbf787223a07272ffc562f5d9ebba01f4d4490 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
#define EVT_DIRECT_PLAY_MUTE         0x1e7000bL
#define NAKA_MAINFUNC_MiddleFuncCall 0x147001cL
extern long MainFuncCall(long, long, long);
#define EVT_GET_LARGE_STEP           0x1e0003eL
#define EVT_GET_SMALL_STEP           0x1e0003fL
#define EVT_GET_MAX                  0x1e00043L
#define EVT_GET_RAM_ADDRESS          0x1e00045L
#define EVT_GET_RAM_SIZE             0x1e00046L
#define EVT_GET_RAM_STRING           0x1e00047L
#define EVT_RAM_DATA_REQ             0x1e00082L
struct ramreq { unsigned char *addr; unsigned char pad[10]; long val; char *str; };
extern unsigned char ram_21088;
extern unsigned char ram_2108a;
extern char *MuteChSet_Dispatch_PtrTable[];
extern char *__cdecl Strcpy(char *, char *);
void SqAftSet_LookupTableEntry(unsigned char a);
extern void SqAftSet_LookupTableEntry(unsigned char a);
long MuteChSetFunc(long obj, long evt, long p)
{
	switch (evt) {
	case EVT_GET_RAM_STRING:
		Strcpy(((struct ramreq *)p)->str, MuteChSet_Dispatch_PtrTable[((struct ramreq *)p)->val]);
		return obj;
	case EVT_GET_LARGE_STEP:
	case EVT_GET_SMALL_STEP:
	case EVT_GET_RAM_SIZE:
		return 1;
	case EVT_GET_MAX:
		return 15;
	case EVT_GET_RAM_ADDRESS:
		return (long)&ram_2108a;
	case EVT_RAM_DATA_REQ:
		if (ram_21088 == 1) {
			SqAftSet_LookupTableEntry(ram_2108a);
			MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
		}
		break;
	}
	return 0;
}
