/* Phase 6, lane_p6 helper L, round 5, form a: module 266 (demo/file_demo_proc.s), new.
   - Demo_SelectEntry_TimerTick: control-panel check, the banner check when 0x25b84 is set (a conditional call),
     then the demo countdown: at 10 parse the active entry's slide header and play (tail jrl), at 3 start the
     playback (conditional tail jrl), at 1 set 0x2966 to 133.  The ROM decrements in A and compares A with 10,
     then reloads the cell for the later tests: `--cell == 10`, then the cell. */
/* cc900-module: Demo_ParseSlideHeader Demo_SelectEntry_CheckCPanel Demo_SelectEntry_PlaySong Demo_SelectEntry_StartPlayback */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int ram_25b84;
extern unsigned char __near ram_2966;
extern unsigned char __near DEMO_TIMER_COUNTDOWN;
extern unsigned char __near DEMO_ACTIVE_ENTRY;
extern void Demo_SelectEntry_CheckCPanel(void);
extern void Banner_Loop_Check(void);
extern void Demo_ParseSlideHeader(int n);
extern void Demo_SelectEntry_PlaySong(void);
extern void Demo_SelectEntry_StartPlayback(void);
extern void Demo_SelectEntry_TimerTick(void);

void Demo_SelectEntry_TimerTick(void)
{
	Demo_SelectEntry_CheckCPanel();
	if (ram_25b84 != 0)
		Banner_Loop_Check();
	if (DEMO_TIMER_COUNTDOWN == 0)
		return;
	if (--DEMO_TIMER_COUNTDOWN == 10) {
		Demo_ParseSlideHeader(DEMO_ACTIVE_ENTRY);
		Demo_SelectEntry_PlaySong();
		return;
	}
	if (DEMO_TIMER_COUNTDOWN == 3) {
		Demo_SelectEntry_StartPlayback();
		return;
	}
	if (DEMO_TIMER_COUNTDOWN == 1)
		ram_2966 = 133;
}
