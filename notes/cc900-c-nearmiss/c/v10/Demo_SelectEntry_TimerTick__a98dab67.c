/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_5m266a.c (2026-11-19-37-p6-r47)
   sha256 a98dab67ae1480a4f29b32439601a043a72bf18784d25f740486ec023b2390b8 (tar-sha256); compiled at -O3 -XS -Xr */
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
