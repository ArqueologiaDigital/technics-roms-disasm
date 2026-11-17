/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m0.c (2026-11-17-6-p6-r30-staged)
   sha256 47c5b2956267f854bb877a6f5af62d2cc7db83834a7450cc4cedd184de662582 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
#define EVT_SHOW                 0x1c00001L
#define EVT_SET_LANG             0x1e80070L
#define NAKA_VIEW_HelpNotXWin    0xe70005L
#define NAKA_VIEW_HelpXWin       0xe7000aL
extern long ApPostEvent(long, long, long);
extern unsigned char Get_Region_Code(void);
extern void SLIDE_Parse_Header(long, unsigned char *);
extern unsigned char __near ram_2954;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char __near ACTIVE_TITLE_PREVIOUS;
extern unsigned char HELP_LANGUAGE;
long HelpLangChkMain(long obj, long ev)
{
	switch (ev) {
	case EVT_SHOW:
		if (ACTIVE_TITLE == 231 && ACTIVE_TITLE_PREVIOUS != 238) {
			if (Get_Region_Code() == 3) ApPostEvent(NAKA_VIEW_HelpXWin, EVT_SHOW, 0);
			else ApPostEvent(NAKA_VIEW_HelpNotXWin, EVT_SHOW, 0);
		}
		ram_2954 = 255;
		SLIDE_Parse_Header(*(long *)(0x988018L + (unsigned char)(HELP_LANGUAGE << 2)), (unsigned char *)0x69800L);
		break;
	case EVT_SET_LANG:
		SLIDE_Parse_Header(*(long *)(0x988018L + (unsigned char)(HELP_LANGUAGE << 2)), (unsigned char *)0x69800L);
		break;
	}
	return 0;
}
