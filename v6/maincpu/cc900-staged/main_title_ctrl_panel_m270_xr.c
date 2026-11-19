/* Functions of boot/main_title_ctrl_panel.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

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
