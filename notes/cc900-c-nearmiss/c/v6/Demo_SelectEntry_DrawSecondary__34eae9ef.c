/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/file_demo_proc_m266.c (2026-11-17-1-p6-r28-staged)
   sha256 34eae9efc4fde82fe6906583b1a97ab600099c929ad655683cd6b839cf3445d9 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
struct democol { unsigned char title; unsigned char entry; };
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near DEMO_CURRENT_SONG;
extern struct democol DemoSong_TitleCol[];
extern void UI_ChangeTitleByIndex(char i);
void Demo_SelectEntry_DrawSecondary(void)
{
    if (!(DEMO_CONTROL_FLAGS & 8)) return;
    if (ACTIVE_TITLE != 0xe4) UI_ChangeTitleByIndex(DemoSong_TitleCol[DEMO_CURRENT_SONG].title);
}
