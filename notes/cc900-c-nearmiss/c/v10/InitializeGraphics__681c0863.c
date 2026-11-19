/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/ui_widget_defs_m273.c (2026-11-19-29-p6-r46)
   sha256 681c08632c94599ac4ddce4434adb8637ce52b2f5f85a81444f55d82009cb5ae (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
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
