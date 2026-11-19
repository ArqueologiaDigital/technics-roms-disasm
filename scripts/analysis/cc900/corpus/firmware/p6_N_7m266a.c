/* lane_p6 helper N, round 7, form a: module 266 (demo/file_demo_proc.s), new function (sibling of the matched
   Demo_SelectionEntryHandler / DemoMode_Main_Operation).
   Demo_SelectEntry_ProcessSongList: with no part playing, restarts the countdown; in auto-play waits for the
   target song, rescans and continues after the song load; in manual selection rescans and either starts auto-play
   of the selected entry (state 4) or restarts the countdown.  The two countdown restarts share one tail jump
   (V4.23's cross jump), the final dispatch call sits inside an `if` (a call, not a tail jump).
   cc900-options: -O3 -Xr
*/
/* cc900-module: Banner_Loop_Check Demo_PreSetupAndScan Demo_ResetCountdownTimer Demo_SelectEntry_AfterSongLoad Demo_WaitForDisplayBit */

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
	if (SEQ_ACTIVE_PARTS == 0) {
		Demo_ResetCountdownTimer();
		return;
	}
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
	if (DEMO_ACTIVE_ENTRY == DEMO_TARGET_SONG) {
		DEMO_PLAY_STATE = 4;
		if (ACTIVE_TITLE != 228)
			SeqInit_FinalEvent();
		Seq_DispatchEventType6(DEMO_ACTIVE_ENTRY);
		return;
	}
	if (ACTIVE_TITLE != 228)
		SeqInit_FinalEvent();
	Demo_ResetCountdownTimer();
}
