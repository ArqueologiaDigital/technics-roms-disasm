/* lane_p6 helper N, round 8, form a: module 266 (demo/file_demo_proc.s), retry of p6_N_7m266a (p6-r51 O3Xr: +7).
   Demo_SelectEntry_ProcessSongList: the listing was the ROM's code except the manual path's end -- the ROM tests
   `jr z` to the auto-play start (placed last, its dispatch call then `ret`) and keeps the not-selected path inline,
   ending in the countdown tail jump shared with the first test.  Form a: the not-selected path in the `!=`
   branch ending in a goto to the countdown at the function's end, the auto-play in the else (so its call stays a
   call).
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
