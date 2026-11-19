/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/file_demo_proc_m266.c (2026-11-19-43-p6-r48)
   sha256 3d7afd2f7783c5ee2d41e46492f2d7ef32313d4cfbcc0b03ae4805dd2889f287 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern int ram_25b84;
extern unsigned char __near ram_294a;
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
		ram_294a = 133;
}
