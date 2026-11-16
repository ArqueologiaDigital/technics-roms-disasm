/* Phase 6, lane_p6 helper C, round 18, module 266 (modules_v10.tsv) of v10 demo/file_demo_proc.s, form b of
   Demo_SelectEntry_DrawSecondary (form a, p6_C_18m266a.c, describes it): the column table as two-byte records
   (title column, entry column) indexed by the song. */

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
