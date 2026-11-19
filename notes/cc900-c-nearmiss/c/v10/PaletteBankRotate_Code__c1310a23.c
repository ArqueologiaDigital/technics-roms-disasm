/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_N_1m273a.c (2026-11-19-15-p6-r42)
   sha256 c1310a23f18a74a8dfc3ac4af2458e38ff0bd5ade5af22ecdbf98b93dde01317 (tar-sha256); compiled at -O3 -XS -Xr */
/* lane_p6 helper N, round 1, form a: module 273.
   InitializeGraphics (ui/ui_widget_defs.s) and the PaletteBankRotate trio (ui/ui_window_procs.s): the draw-queue
   shape without the DRAW_ENABLED test (direct = tail jump to the Impl, else a 4-byte queued entry whose code stub
   jumps to the Impl).  Form a: the direct path first.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ChangePalette ChangeWall ChangeWallPalette DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 InitDrawTask LcdOn PaletteBankRotate_Impl SetChangeRect UpdateScreen */
/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */

struct rect { int x0, y0, x1, y1; };
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void *__cdecl Memset(void *, int, unsigned int);
extern unsigned char OFFSCREEN_BUFFER_1[];
extern unsigned char OFFSCREEN_BUFFER_2[];
extern unsigned char OFFSCREEN_BUFFER_3[];
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
extern void PaletteBankRotate_Impl(void);
extern void PaletteBankRotate_Code(unsigned char *q);

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

void PaletteBankRotate(void)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0) {
		PaletteBankRotate_Impl();
	} else {
		q = DrawQueue_Alloc(4);
		*(void **)q = (void *)PaletteBankRotate_Code;
		DrawRing_Post(q);
	}
}

void PaletteBankRotate_Code(unsigned char *q)
{
	PaletteBankRotate_Impl();
}

void PaletteBankRotate_Impl(void)
{
	unsigned char *b;
	unsigned char *p;
	int x;
	int y;

	b = OFFSCREEN_BUFFER_1;
	Mem_Copy(OFFSCREEN_BUFFER_2, b, 0x9600);
	b += 0x9600;
	Mem_Copy(OFFSCREEN_BUFFER_3, b, 0x9600);
	p = OFFSCREEN_BUFFER_1;
	for (y = 0; y < 240; y++)
		for (x = 0; x < 320; x++) {
			if (*p >= 0xe0)
				*p -= 0x90;
			else
				*p += 0x10;
			p++;
		}
	b = OFFSCREEN_BUFFER_1;
	Mem_Copy((void *)0x69800L, b, 0x9600);
	b += 0x9600;
	Mem_Copy((void *)0x72e00L, b, 0x9600);
}
