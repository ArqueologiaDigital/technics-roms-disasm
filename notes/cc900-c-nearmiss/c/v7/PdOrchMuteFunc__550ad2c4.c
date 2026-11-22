/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of v7/sequencer_ui_m0.c (2026-11-21-22-p6-r67)
   sha256 550ad2c4d29e45f52882d62ae4cbf787223a07272ffc562f5d9ebba01f4d4490 (tar-sha256); compiled at -Xr */
/* Functions of sequencer/sequencer_ui.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SMFMute_ClearBit0 SMFMute_GetBit0Status SMFMute_GetBit1Status SMFMute_GetUpperBits SqAftSet_LookupTableEntry */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_SET_SELECTED 0x1e0004dL
extern unsigned char __near ram_d3e;
extern long InheritedProc(long, long, long);
extern unsigned char *GetViewInstance(long);
long AcModeSelBoxProc(long obj, long evt, long param);
extern long AcModeSelBoxProc(long obj, long evt, long param);
#define EVT_DIRECT_PLAY_MUTE         0x1e7000bL
#define EVT_GET_TOGGLE_SW            0x1e70017L
#define NAKA_MAINFUNC_MiddleFuncCall 0x147001cL
extern unsigned int ram_21086;
extern long MainFuncCall(long, long, long);
long SMFMute_GetUpperBits(void);
long SMFMute_ClearBit0(void);
extern long SMFMute_GetUpperBits(void);
extern long SMFMute_ClearBit0(void);
extern long DocOrchMuteFunc(long obj, long evt, long p);
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
extern long MuteChSetFunc(long obj, long evt, long p);
extern long PdOrchMuteFunc(long obj, long evt, long p);
long SMFMute_GetBit0Status(void);
long SMFMute_GetBit1Status(void);
extern long SMFMute_GetBit0Status(void);
extern long SMFMute_GetBit1Status(void);
extern long Rt1MuteFunc(long obj, long evt, long p);
extern long Rt2MuteFunc(long obj, long evt, long p);
#define EVT_GET_STRING               0x1e0003aL
#define EVT_SONG_NAME_SET            0x1e70001L
extern long SendEvent(long, long, long);
extern long GetNamingWindowID(void);
extern long SeqNameOKFunc(long obj, long evt, long p);

long AcModeSelBoxProc(long obj, long evt, long param)
{
	switch (evt) {
	default:
		return InheritedProc(obj, evt, param);
	case EVT_SET_SELECTED:
		InheritedProc(obj, evt, param);
		if (param == 1) ram_d3e = GetViewInstance(obj)[0x32];
		break;
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

/* cc900-data: MuteChSetFunc 1 = MuteChSetFunc_CaseTable */
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

long SMFMute_ClearBit0(void)
{
	return ram_21086 & 0xfffe;
}

long SMFMute_GetBit1Status(void)
{
	return ram_21086 & 2;
}

long SeqNameOKFunc(long obj, long evt, long p)
{
	SendEvent(GetNamingWindowID(), EVT_GET_STRING, 0x20c92L);
	MainFuncCall(NAKA_MAINFUNC_MiddleFuncCall, EVT_SONG_NAME_SET, 0x20c92L);
	return 0;
}
