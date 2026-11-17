/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_D_20m235b.c (2026-11-17-2-p6-r29)
   sha256 c4c19a995d4097a0b91203c956aeb45b8d429180f1b41c40d5d9de92923310b4 (tar-sha256); compiled at -Xr */
#define EVT_SHOW                 0x1c00001L
#define EVT_SET_LANG             0x1e80070L
#define NAKA_VIEW_HelpNotXWin    0xe70005L
#define NAKA_VIEW_HelpXWin       0xe7000aL
extern long ApPostEvent(long, long, long);
extern unsigned char Get_Region_Code(void);
extern void SLIDE_Parse_Header(long, unsigned char *);
extern unsigned char __near ram_2970;
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
		ram_2970 = 255;
		SLIDE_Parse_Header(*(long *)((unsigned long)(unsigned char)(HELP_LANGUAGE << 2) + 0x988018L), (unsigned char *)0x69800L);
		break;
	case EVT_SET_LANG:
		SLIDE_Parse_Header(*(long *)((unsigned long)(unsigned char)(HELP_LANGUAGE << 2) + 0x988018L), (unsigned char *)0x69800L);
		break;
	}
	return 0;
}
