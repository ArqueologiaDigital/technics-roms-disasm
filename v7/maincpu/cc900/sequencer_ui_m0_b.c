/* Functions of sequencer/sequencer_ui.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SMFMute_ClearBit0 SMFMute_GetBit0Status SMFMute_GetBit1Status SMFMute_GetUpperBits SqAftSet_LookupTableEntry */   /* scripts/analysis/cc900/module_calls.py v10 */

#define EVT_SHOW                     0x1c00001L
#define EVT_SET_PARAM                0x1e0003bL
#define EVT_GET_TOGGLE_SW            0x1e70017L
struct vi { unsigned char pad[40]; long func; };
extern long ram_2108c;
extern long InheritedProc(long, long, long);
extern void *GetViewInstance(long);
extern long ApFuncCall(long, long, long);
extern long SendEvent(long, long, long);
extern long AcMuteToggleBoxProc(long obj, long evt, long p);
#define EVT_DIRECT_PLAY_MUTE         0x1e7000bL
#define NAKA_MAINFUNC_MiddleFuncCall 0x147001cL
extern unsigned int ram_21086;
extern unsigned char ram_21088;
extern unsigned char ram_2108a;
extern long MainFuncCall(long, long, long);
void SqAftSet_LookupTableEntry(unsigned char a);
extern void SqAftSet_LookupTableEntry(unsigned char a);
extern long SMFMuteOnOffFunc(long obj, long evt, long p);
long SMFMute_GetBit0Status(void);
long SMFMute_GetBit1Status(void);
extern long SMFMute_GetBit0Status(void);
extern long SMFMute_GetBit1Status(void);
long SMFMute_GetUpperBits(void);
long SMFMute_ClearBit0(void);
extern long SMFMute_GetUpperBits(void);
extern long SMFMute_ClearBit0(void);

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

long SMFMute_GetUpperBits(void)
{
	return ram_21086 & 0xfffc;
}
