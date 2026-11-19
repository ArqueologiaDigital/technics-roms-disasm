/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/file_demo_proc_m266.c (2026-11-19-43-p6-r48)
   sha256 dcaa54051260778c82b52bc5705039ed57a4bed1c558474bfe86f89b5227f3f4 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern int ram_25b84;
extern unsigned char __near ram_2966;
extern unsigned char __near DEMO_TIMER_COUNTDOWN;
extern unsigned char __near DEMO_ACTIVE_ENTRY;
extern void Demo_SelectEntry_CheckCPanel(void);
extern void Banner_Loop_Check(void);
extern void Demo_ParseSlideHeader(int n);
extern void Demo_SelectEntry_PlaySong(void);
extern void Demo_SelectEntry_StartPlayback(void);
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
