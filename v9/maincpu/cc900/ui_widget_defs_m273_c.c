/* Functions of ui/ui_widget_defs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ChangePalette ChangeWall ChangeWallPalette DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 InitDrawTask LcdOn PaletteBankRotate_Impl SetChangeRect UpdateScreen */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
extern void *__cdecl Memset(void *, int, unsigned int);
extern unsigned char OFFSCREEN_BUFFER_1[];
extern void InitDrawTask(void);
extern int Kernel_StartTask(int);
extern int ram_3ef92;
extern void InitPaletteRGB(void);
extern void ChangeWall(int);
extern void ChangePalette(int);
extern void ChangeWallPalette(int);
extern void SetChangeRect(struct rect *r);
extern void UpdateScreen(void);
extern void LcdOn(void);
extern void InitializeGraphics(void);

void InitializeGraphics(void)
{
	struct rect r;
	unsigned char *p;

	InitDrawTask();
	Kernel_StartTask(5);
	ram_3ef92 = 1;
	InitPaletteRGB();
	ChangeWall(0);
	ChangePalette(2);
	ChangeWallPalette(0);
	p = OFFSCREEN_BUFFER_1;
	Memset(p, 0, 0x9600);
	p += 0x9600;
	Memset(p, 0, 0x9600);
	r.y0 = 0;
	r.x0 = 0;
	r.x1 = 319;
	r.y1 = 239;
	SetChangeRect(&r);
	UpdateScreen();
	LcdOn();
}
