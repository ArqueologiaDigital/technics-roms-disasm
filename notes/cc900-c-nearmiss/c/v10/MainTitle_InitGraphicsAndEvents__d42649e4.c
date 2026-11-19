/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_2m270a.c (2026-11-19-19-p6-r43)
   sha256 d42649e4ee4132438053458dfc8ed297072e107c7159d3a8104ca319166a57a8 (tar-sha256); compiled at -O3 -XS -Xr */
#define TITLE_PS 0x1a00000L
#define TITLE_WELCOM 0x1a000efL
#define EVT_SET_NOT_DRAW_FLAG 0x1e0009eL
#define EVT_SHOW 0x1c00001L
#define EVT_CHANGE_MODE 0x1c00014L
#define EVT_INTERRUPT_TITLE 0x1c00016L
#define NAKA_MODE_MD_NORMAL 0x1800001L
extern void InitializeGraphics(void);
extern void InitializeEventQueue(void);
extern void InitializeTimer(void);
extern void InitializeObjectTable(void);
extern void LcdOn(void);
extern long PostEvent(long, long, long);
void MainTitle_InitGraphicsAndEvents(void)
{
	InitializeGraphics();
	InitializeEventQueue();
	InitializeTimer();
	InitializeObjectTable();
	LcdOn();
	PostEvent(TITLE_PS, EVT_SET_NOT_DRAW_FLAG, 1);
	PostEvent(0, EVT_SHOW, 0);
	PostEvent(-1, EVT_CHANGE_MODE, NAKA_MODE_MD_NORMAL);
	PostEvent(-1, EVT_INTERRUPT_TITLE, TITLE_WELCOM);
}
