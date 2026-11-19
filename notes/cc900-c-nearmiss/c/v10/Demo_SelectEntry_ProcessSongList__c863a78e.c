/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_8m266a.c (2026-11-19-68-p6-r52)
   sha256 c863a78e071c51472296d872e8b32a271d36026298ac6fae1c9eca82d4624b4d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned char __near DEMO_ACTIVE_ENTRY;
extern unsigned char __near DEMO_TARGET_SONG;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near DEMO_PLAY_STATE;
extern void Demo_PreSetupAndScan(void);
extern void Demo_WaitForDisplayBit(void);
extern void Banner_Loop_Check(void);
extern void SeqInit_FinalEvent(void);
extern void Demo_SelectEntry_AfterSongLoad(void);
extern void Demo_ResetCountdownTimer(void);
extern void Seq_DispatchEventType6(int);
void Demo_SelectEntry_ProcessSongList(void)
{
	if (SEQ_ACTIVE_PARTS == 0)
		goto countdown;
	if (DEMO_CONTROL_FLAGS & 0x08) {
		if (DEMO_ACTIVE_ENTRY != DEMO_TARGET_SONG)
			return;
		Demo_PreSetupAndScan();
		Demo_WaitForDisplayBit();
		Banner_Loop_Check();
		if (ACTIVE_TITLE != 228)
			SeqInit_FinalEvent();
		Demo_SelectEntry_AfterSongLoad();
		return;
	}
	Demo_PreSetupAndScan();
	Demo_WaitForDisplayBit();
	Banner_Loop_Check();
	if (DEMO_ACTIVE_ENTRY != DEMO_TARGET_SONG) {
		if (ACTIVE_TITLE != 228)
			SeqInit_FinalEvent();
		goto countdown;
	} else {
		DEMO_PLAY_STATE = 4;
		if (ACTIVE_TITLE != 228)
			SeqInit_FinalEvent();
		Seq_DispatchEventType6(DEMO_ACTIVE_ENTRY);
	}
	return;
countdown:
	Demo_ResetCountdownTimer();
}
