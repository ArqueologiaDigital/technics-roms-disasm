/* Phase 6, lane_p6 helper C, round 18, module 266 (modules_v10.tsv) of v10 demo/file_demo_proc.s, form a:
   Demo_SelectEntry_DrawSecondary (new, memory-to-memory pool; only the routine itself, 36 bytes: the labels after
   it are other entry points).  With auto-play on (DEMO_CONTROL_FLAGS bit 3) and the title on screen not 0xe4,
   changes the title to the current demo song's title column, the byte at DemoSong_TitleCol[2 * song].  The call
   sits inside the `if`, so V4.23 keeps it a call followed by ret.  Form b (p6_C_18m266b.c): the column table as an
   array of two-byte records. */

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
