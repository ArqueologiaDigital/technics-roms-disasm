/* Phase 6, lane_p6 helper L, round 2, form a: module 270 (boot/main_title_ctrl_panel.s).
   - MainTitle_InitGraphicsAndEvents: five initialisers, then four PostEvents (the last a tail jp). */
/* (no module-local callee) */

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
extern void MainTitle_InitGraphicsAndEvents(void);

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
