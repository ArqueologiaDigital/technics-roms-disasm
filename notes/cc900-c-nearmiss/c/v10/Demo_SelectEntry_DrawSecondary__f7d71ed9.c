/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_18m266b.c (2026-11-16-123-p6-r25)
   sha256 f7d71ed9bf7d73b96a55522ff6f8ae35213aac6a6e69529f4da7e9e202ecdc3a (tar-sha256); compiled at -O3 -Xr */
struct democol { unsigned char title; unsigned char entry; };
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near DEMO_CURRENT_SONG;
extern struct democol DemoSong_TitleCol[];
extern void UI_ChangeTitleByIndex(unsigned char i);
void Demo_SelectEntry_DrawSecondary(void)
{
    if (!(DEMO_CONTROL_FLAGS & 8)) return;
    if (ACTIVE_TITLE != 0xe4) UI_ChangeTitleByIndex(DemoSong_TitleCol[DEMO_CURRENT_SONG].title);
}
