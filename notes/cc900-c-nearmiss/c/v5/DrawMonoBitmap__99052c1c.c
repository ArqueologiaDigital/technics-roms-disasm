/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of v5/ui_window_procs_m0.c (2026-11-19-29-p6-r46)
   sha256 99052c1c97da6d5910d9cb030f67ab125bc2074be6015ad582ccf72bcd779d2c (tar-sha256); compiled at -O3 -Xr */
/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: DrawBitmapFile_Impl DrawDottedLine_Impl DrawMonoBitmap_Impl DrawQueue_Alloc DrawRing_Post DrawWall_DoCopy GraphicsRender_ProcessEntries GraphicsRender_RetStub IS_XSP_INSIDE_4K_REGION_AT_1C032 SetChangeRect */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
struct ddcmd { void (*fn)(struct ddcmd *); struct pt a; struct pt b; int c; };
extern void DrawDottedLine_Impl(struct pt *, struct pt *, int);
extern void DrawDesignBox_ByteData_Code(struct ddcmd *q);
extern void DrawDesignBox_ByteData(struct pt *a, struct pt *b, int c);
struct rect { int x0, y0, x1, y1; };
struct mbcmd { void (*fn)(struct mbcmd *); struct rect r; unsigned char *bits; int color; unsigned char mode; };
extern unsigned char COLORBLIT_MODE;
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern void DrawMonoBitmap_Impl(struct rect *r, unsigned char *bits, int color);
extern void DrawMonoBitmap_ParamBlock(struct mbcmd *q);
extern void DrawMonoBitmap(struct rect *r, unsigned char *bits, int color);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern unsigned char OFFSCREEN_BUFFER_1[];
extern void PaletteBankRotate_Impl(void);

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawDesignBox_ByteData(struct pt *a, struct pt *b, int c)
{
	struct ddcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawDottedLine_Impl(a, b, c);
	} else {
		q = (struct ddcmd *)DrawQueue_Alloc(sizeof(struct ddcmd));
		q->fn = DrawDesignBox_ByteData_Code;
		q->a = *a;
		q->b = *b;
		q->c = c;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawMonoBitmap(struct rect *r, unsigned char *bits, int color)
{
	struct mbcmd *q;

	if (IsDrawTask() != 0) {
		COLORBLIT_MODE_ACTIVE = COLORBLIT_MODE;
		if (DRAW_ENABLED != 0)
			DrawMonoBitmap_Impl(r, bits, color);
	} else {
		q = (struct mbcmd *)DrawQueue_Alloc(sizeof(struct mbcmd));
		q->fn = DrawMonoBitmap_ParamBlock;
		q->r = *r;
		q->bits = bits;
		q->color = color;
		q->mode = COLORBLIT_MODE;
		DrawRing_Post(q);
	}
}

void DrawMonoBitmap_ParamBlock(struct mbcmd *q)
{
	struct rect *r = &q->r;
	unsigned char *bits = q->bits;
	int color = q->color;

	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		DrawMonoBitmap_Impl(r, bits, color);
}

void PaletteBankRotate_Impl(void)
{
	unsigned char *b;
	int x;
	int y;
	unsigned char *p;

	b = OFFSCREEN_BUFFER_1;
	Mem_Copy((void *)0x56800L, b, 0x9600);
	b += 0x9600;
	Mem_Copy((void *)0x5fe00L, b, 0x9600);
	p = OFFSCREEN_BUFFER_1;
	y = 0;
	do {
		x = 0;
		do {
			if (*p >= 0xe0)
				*p -= 0x90;
			else
				*p += 0x10;
			p++;
			x++;
		} while (x < 320);
		y++;
	} while (y < 240);
	b = OFFSCREEN_BUFFER_1;
	Mem_Copy((void *)0x69800L, b, 0x9600);
	b += 0x9600;
	Mem_Copy((void *)0x72e00L, b, 0x9600);
}
