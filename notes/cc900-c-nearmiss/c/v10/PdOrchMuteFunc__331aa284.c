/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_Y_22r1m232a.c (2026-11-21-21-p6-r66)
   sha256 331aa284e803c3aed9b377c150febbab28167b39056a40b2435e4f51312279c6 (tar-sha256); compiled at -Xr */
/* lane_p6 helper Y, round 22r1, form a: module 232 (sequencer/sequencer_ui.s), the SMF mute / demo-medley
   display widgets that sat inside pool22_X's SqAftSet_LookupTableEntry span (never pooled on their own).
   SMFMute_Get* are the four tail-called getters of Rt1 / Rt2 / DocOrch / PdOrch MuteFunc (ROM: `jr z, Get*`).
   Form a: the mute funcs call MainFuncCall in each branch (the ROM repeats the argument loads and shares the
   call); table switches written in ROM block order; compare-chain switches in ROM compare order.
   cc900-options: -O3 -Xr
*/
/* cc900-data: MuteChSetFunc 1 = MuteChSetFunc_CaseTable */
/* cc900-data: DemoMedDspCheck 1 = DemoMedDspCheck_CaseTable */
/* cc900-data: DPPlayDspCheck 1 = DPPlayDspCheck_CaseTable */
/* cc900-data: DPPauseDspCheck 1 = DPPauseDspCheck_CaseTable */
/* cc900-module: SMFMute_ClearBit0 SMFMute_GetBit0Status SMFMute_GetBit1Status SMFMute_GetUpperBits SqAftSet_LookupTableEntry */
/* cc900-name: AcDemoMedley_Str=AcDemoMedley_HandleScrollEvent_Str */
/* cc900-name: AcDemoMedley_Str_2=AcDemoMedley_HandleScrollEvent_Str_2 */

#define EVT_SHOW                     0x1c00001L
#define EVT_HIDE                     0x1c00002L
#define EVT_PAINT                    0x1c0000bL
#define EVT_REPAINT                  0x1c0000cL
#define EVT_PARA_DRAW                0x1c0000fL
#define EVT_GET_STRING               0x1e0003aL
#define EVT_SET_PARAM                0x1e0003bL
#define EVT_GET_LARGE_STEP           0x1e0003eL
#define EVT_GET_SMALL_STEP           0x1e0003fL
#define EVT_GET_MAX                  0x1e00043L
#define EVT_GET_MIN                  0x1e00044L
#define EVT_GET_RAM_ADDRESS          0x1e00045L
#define EVT_GET_RAM_SIZE             0x1e00046L
#define EVT_GET_RAM_STRING           0x1e00047L
#define EVT_GET_STRING_LENGTH        0x1e0007cL
#define EVT_RAM_DATA_REQ             0x1e00082L
#define EVT_GET_NAMING_MODE          0x1e00084L
#define EVT_SONG_NAME_SET            0x1e70001L
#define EVT_DIRECT_PLAY_MUTE         0x1e7000bL
#define EVT_GET_TOGGLE_SW            0x1e70017L
#define NAKA_MAINFUNC_MiddleFuncCall 0x147001cL

struct ramreq { unsigned char *addr; unsigned char pad[10]; long val; char *str; };
struct vi { unsigned char pad[40]; long func; };

extern unsigned int ram_21086;
extern unsigned char ram_21088;
extern unsigned char ram_2108a;
extern long ram_2108c;
extern unsigned char ram_21090;
extern unsigned char ram_21092;
extern unsigned char ram_21094;
extern char ram_20ca2[];
extern char ram_f280[];
extern unsigned int SqAftSet_LookupTableEntry_Table[];
extern char *MuteChSet_Dispatch_PtrTable[];
extern char AcDemoMedley_Str[];
extern char AcDemoMedley_Str_2[];
extern char MedleyDisp_Blank[];
extern char DemoMedDsp_Dispatch_Str[];
extern char PlayModeStr_Play[];
extern char DPPlayDsp_Dispatch_Str[];
extern char PlayModeStr_Pause[];
extern char DPPauseDsp_Dispatch_Str[];

extern long MainFuncCall(long, long, long);
extern long InheritedProc(long, long, long);
extern void *GetViewInstance(long);
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);
extern long GetNamingWindowID(void);
extern char *__cdecl Strcpy(char *, char *);
extern char *__cdecl Strncpy(char *, char *, unsigned int);
extern int __cdecl Sprintf_Locked(char *, char *, ...);

void SqAftSet_LookupTableEntry(unsigned char a);
long SMFMute_GetBit0Status(void);
long SMFMute_GetBit1Status(void);
long SMFMute_GetUpperBits(void);
long SMFMute_ClearBit0(void);

void SqAftSet_LookupTableEntry(unsigned char a)
{
	ram_21086 = SqAftSet_LookupTableEntry_Table[a];
}

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

long AcMuteToggleBoxProc(long obj, long evt, long p)
{
	long v;

	if (evt != EVT_SHOW)
		return InheritedProc(obj, evt, p);
	v = ApFuncCall(((struct vi *)GetViewInstance(obj))->func, EVT_GET_TOGGLE_SW, 0L);
	ram_2108c = v;
	SendEvent(obj, EVT_SET_PARAM, v);
	InheritedProc(obj, evt, p);
	return 0;
}

long SMFMuteOnOffFunc(long obj, long evt, long p)
{
	if (evt == EVT_GET_TOGGLE_SW)
		return ram_21088;
	if (p == 1) {
		ram_21088 = 1;
		SqAftSet_LookupTableEntry(ram_2108a);
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	} else {
		ram_21088 = 0;
		ram_21086 = 0;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	}
	return 0;
}

long SMFMute_GetBit0Status(void)
{
	return ram_21086 & 1;
}

long SMFMute_GetBit1Status(void)
{
	return ram_21086 & 2;
}

long SMFMute_GetUpperBits(void)
{
	return ram_21086 & 0xfffc;
}

long SMFMute_ClearBit0(void)
{
	return ram_21086 & 0xfffe;
}

long Rt1MuteFunc(long obj, long evt, long p)
{
	if (evt == EVT_GET_TOGGLE_SW)
		return SMFMute_GetBit0Status();
	if (p == 1) {
		ram_21086 |= 1;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	} else {
		ram_21086 &= 0xfffe;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	}
	return 0;
}

long Rt2MuteFunc(long obj, long evt, long p)
{
	if (evt == EVT_GET_TOGGLE_SW)
		return SMFMute_GetBit1Status();
	if (p == 1) {
		ram_21086 |= 2;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	} else {
		ram_21086 &= 0xfffd;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	}
	return 0;
}

long DocOrchMuteFunc(long obj, long evt, long p)
{
	if (evt == EVT_GET_TOGGLE_SW)
		return SMFMute_GetUpperBits();
	if (p == 1) {
		ram_21086 |= 0xfffc;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	} else {
		ram_21086 &= 3;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	}
	return 0;
}

long PdOrchMuteFunc(long obj, long evt, long p)
{
	if (evt == EVT_GET_TOGGLE_SW)
		return SMFMute_ClearBit0();
	if (p == 1) {
		ram_21086 |= 0xfffe;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	} else {
		ram_21086 &= 1;
		MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_DIRECT_PLAY_MUTE, 0L);
	}
	return 0;
}

long SeqNameOKFunc(long obj, long evt, long p)
{
	SendEvent(GetNamingWindowID(), EVT_GET_STRING, 0x20c92L);
	MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_SONG_NAME_SET, 0x20c92L);
	return 0;
}

long SeqNamingCheck(long obj, long evt, long p)
{
	switch (evt) {
	case EVT_GET_STRING_LENGTH:
		return 16;
	case EVT_GET_NAMING_MODE:
		return 0;
	case EVT_GET_STRING:
		Strncpy(ram_20ca2, ram_f280, 16);
		ram_20ca2[16] = 0;
		Strcpy((char *)p, ram_20ca2);
		return obj;
	}
	return 0;
}

long AcDemoMedleyDispBoxProc(long obj, long evt, long p)
{
	char buf[256];

	switch (evt) {
	case EVT_REPAINT:
	case EVT_PAINT:
		InheritedProc(obj, evt, p);
		Sprintf_Locked(buf, ram_21090 == 1 ? AcDemoMedley_Str : AcDemoMedley_Str_2);
		SendEvent(obj, EVT_PARA_DRAW, (long)buf);
		return 0;
	case EVT_HIDE:
		InheritedProc(obj, evt, p);
		return 0;
	case EVT_SHOW:
		InheritedProc(obj, evt, p);
		return 0;
	default:
		return InheritedProc(obj, evt, p);
	}
}

long DemoMedDspCheck(long obj, long evt, long p)
{
	switch (evt) {
	case EVT_GET_RAM_STRING:
		Sprintf_Locked(((struct ramreq *)p)->str,
			((struct ramreq *)p)->val ? DemoMedDsp_Dispatch_Str : MedleyDisp_Blank);
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
		return (long)&ram_21090;
	case EVT_RAM_DATA_REQ:
		break;
	}
	return 0;
}

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

long DPPauseDspCheck(long obj, long evt, long p)
{
	switch (evt) {
	case EVT_GET_RAM_STRING:
		Sprintf_Locked(((struct ramreq *)p)->str,
			((struct ramreq *)p)->val ? DPPauseDsp_Dispatch_Str : PlayModeStr_Pause);
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
		return (long)&ram_21094;
	case EVT_RAM_DATA_REQ:
		break;
	}
	return 0;
}
