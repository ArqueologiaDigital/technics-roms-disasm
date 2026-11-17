/* Phase 6, lane_p6 helper D, round 22, module 235 (v10 sequencer/sequencer_engine.s), form b of p6_D_22m235.c:
   the unsigned char page index declared before the language local.  Round 21's notes:
   HelpLang_DispatchDataBlock.  Round 20 differed from the first instruction: the ROM loads SWBTWR_PAYLOAD_1 into A
   and compares there (V4.23 compared memory), and it reads the page index into BC before the language switch
   (language in E, table in XWA): the payload byte and the index go through locals.  Form b (p6_D_21m235b.c)
   also takes the language into a local. */

#define EVT_SHOW                 0x1c00001L
#define NAKA_VIEW_HelpSwTtl1Scr  0xe7000eL
#define NAKA_VIEW_HelpTtlStr1    0xe70010L
#define NAKA_VIEW_HelpSwTtl2Scr  0xe70017L
#define NAKA_VIEW_HelpTtlStr2    0xe70019L
#define NAKA_VIEW_HelpSwTtl3Scr  0xe70024L
#define NAKA_VIEW_HelpTtlStr3    0xe70026L
#define NAKA_VIEW_HelpSwTtl4Scr  0xe7002cL
#define NAKA_VIEW_HelpTtlStr4    0xe7002fL

extern long ApPostEvent(long, long, long);

extern unsigned char __near SWBTWR_PAYLOAD_1;
extern unsigned char __near SWBTWR_PAYLOAD_2;
extern unsigned char __near ram_296e;
extern unsigned char __near ram_2970;
extern unsigned char __near ACTIVE_TITLE;
extern unsigned char HELP_LANGUAGE;
extern unsigned char HelpLang_ByteTable0[], HelpLang_ByteTable1[], HelpLang_ByteTable2[], HelpLang_ByteTable3[];
extern unsigned char FontPalette_Gradient7[];

void HelpLang_DispatchDataBlock(void)
{
	unsigned char a;
	unsigned char i;
	unsigned char l;
	unsigned char *t;

	a = SWBTWR_PAYLOAD_1;
	if (a != 19) return;
	a = SWBTWR_PAYLOAD_2;
	ram_296e = a;
	if (a == ram_2970) return;
	if (a > 49) return;
	ram_2970 = a;
	if (ACTIVE_TITLE != 231) return;
	l = HELP_LANGUAGE;
	i = ram_296e;
	switch (l) {
	case 1:
		t = HelpLang_ByteTable1;
		break;
	case 2:
		t = HelpLang_ByteTable2;
		break;
	case 3:
		t = HelpLang_ByteTable3;
		break;
	case 5:
		t = FontPalette_Gradient7;
		break;
	default:
		t = HelpLang_ByteTable0;
		break;
	}
	a = t[i];
	if (a == 1) {
		ApPostEvent(NAKA_VIEW_HelpSwTtl1Scr, EVT_SHOW, 0);
		ApPostEvent(NAKA_VIEW_HelpTtlStr1, EVT_SHOW, 0);
	} else if (a == 2) {
		ApPostEvent(NAKA_VIEW_HelpSwTtl2Scr, EVT_SHOW, 0);
		ApPostEvent(NAKA_VIEW_HelpTtlStr2, EVT_SHOW, 0);
	} else if (a == 3) {
		ApPostEvent(NAKA_VIEW_HelpSwTtl3Scr, EVT_SHOW, 0);
		ApPostEvent(NAKA_VIEW_HelpTtlStr3, EVT_SHOW, 0);
	} else {
		ApPostEvent(NAKA_VIEW_HelpSwTtl4Scr, EVT_SHOW, 0);
		ApPostEvent(NAKA_VIEW_HelpTtlStr4, EVT_SHOW, 0);
	}
}
