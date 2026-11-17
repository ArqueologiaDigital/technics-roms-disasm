/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_18m266a.c (2026-11-16-123-p6-r25)
   sha256 b76e60467ea7fb38017771b55ab4d84f8af22fe1cdf1fdb36e369a8a1574e804 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near DEMO_CURRENT_SONG;
extern unsigned char DemoSong_TitleCol[];
extern void UI_ChangeTitleByIndex(unsigned char i);
void Demo_SelectEntry_DrawSecondary(void)
{
    if (!(DEMO_CONTROL_FLAGS & 8)) return;
    if (ACTIVE_TITLE != 0xe4) UI_ChangeTitleByIndex(DemoSong_TitleCol[DEMO_CURRENT_SONG * 2]);
}
