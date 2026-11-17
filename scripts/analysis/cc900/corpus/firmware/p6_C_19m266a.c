/* Phase 6, lane_p6 helper C, round 19, module 266 (modules_v10.tsv) of v10 demo/file_demo_proc.s, form a:
   Demo_SelectEntry_DrawSecondary.  Round 18 form b (two-byte records) gave the ROM's bytes up to the call, before
   which V4.23 widened the byte argument (extz WA); the ROM passes it in A as loaded.  lane_sub's spelling (c): the
   callee's parameter declared plain char, the unsigned byte passed without a cast.  Form b (p6_C_19m266b.c):
   signed char parameter. */

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
