/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_N_1m273b.c (2026-11-19-15-p6-r42)
   sha256 14717891cacdd869be6ffe8c0590b5ee84a8874036e30a5a3da21b1d673e5af0 (tar-sha256); compiled at -O3 -Xr
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
	r.x0 = 0;
	r.y0 = 0;
	r.x1 = 319;
	r.y1 = 239;
	SetChangeRect(&r);
	UpdateScreen();
	LcdOn();
}
