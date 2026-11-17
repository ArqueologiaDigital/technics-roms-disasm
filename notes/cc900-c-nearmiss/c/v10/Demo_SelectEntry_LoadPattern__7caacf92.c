/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_15a.c (2026-11-16-100-p6-r19)
   sha256 7caacf92b81c580e558ace02d13d4a4484a651c893c11e49cb579bb494e4fe60 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near DEMO_CURRENT_SONG;
extern unsigned int __near DEMO_ACTIVE_ENTRY;
extern unsigned int DemoSong_EntryCol[];
void Demo_SelectEntry_LoadPattern(void)
{
    DEMO_ACTIVE_ENTRY = DemoSong_EntryCol[DEMO_CURRENT_SONG];
}
