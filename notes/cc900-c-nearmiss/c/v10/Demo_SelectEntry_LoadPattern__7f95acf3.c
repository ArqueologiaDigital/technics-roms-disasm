/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_15b.c (2026-11-16-100-p6-r19)
   sha256 7f95acf3745d575ececbdfdbd8d96ac3fe6d9f317e9c8d0e6638d65ff9f1acb9 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near DEMO_CURRENT_SONG;
extern unsigned int __near DEMO_ACTIVE_ENTRY;
extern unsigned int DemoSong_EntryCol[];
void Demo_SelectEntry_LoadPattern(void)
{
    DEMO_ACTIVE_ENTRY = DemoSong_EntryCol[DEMO_CURRENT_SONG];
}
