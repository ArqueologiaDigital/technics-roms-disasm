/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct point { int x, y; };

int IsPointOnScreen(struct point *p)
{
    if (p->x < 0 || p->x >= 320 || p->y < 0 || p->y >= 240)
        return 0;
    return 1;
}

/* cc900-module: ClipBlit_Replace_Impl ColorBlit2_Impl ColorBlit_Impl DrawBitmapFast_Impl DrawBitmapSP2_Impl DrawBitmapSPFast_Impl DrawBitmapSP_Impl DrawBox_Impl DrawDesignBox_Impl DrawDottedLineWithMode_Impl DrawFrameSP_Impl DrawFrame_Impl DrawFunc_Return DrawIcons_Impl DrawLineWithMode_Impl DrawLine_Impl DrawQueue_Alloc DrawRing_Post DrawString DrawString_Impl Gfx_BlitDirtyRegions IS_XSP_INSIDE_4K_REGION_AT_1C032 MovePixels_Impl */
struct pt { int x, y; };
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void ClipBlit_Replace_Impl(struct pt *, int);
extern void ClipBlit_Replace_ParamBlock(unsigned char *q);
extern void ClipBlit_Replace(struct pt *p, int n);
struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE;
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern void ColorBlit2_Impl(struct rect *, int);
extern void ColorBlit2_CallbackBlock(unsigned char *q);
extern void ColorBlit2(struct rect *r, int n);
extern void DrawDesignBox_Impl(struct rect *, int, int);
extern void DrawDesignBox_QueueCallback(unsigned char *q);
extern void DrawDesignBox(struct rect *r, int a, int b);
extern void DrawDottedLineWithMode_Impl(struct pt *, struct pt *, int);
extern void DrawDottedLineMode_ParamBlock(unsigned char *q);
extern void DrawDottedLineWithMode(struct pt *a, struct pt *b, int m);
extern int IsDrawTask(void);
struct cbcmd { void (*fn)(struct cbcmd *); struct rect r; int c; unsigned char mode; };
extern void ColorBlit_Impl(struct rect *, int);
extern void ColorBlit_CallbackBlock(struct cbcmd *);
extern void ColorBlit(struct rect *r, int c);
extern void ColorBlit_CallbackBlock(struct cbcmd *q);
struct lmcmd { void (*fn)(struct lmcmd *); struct pt a; struct pt b; int c; unsigned char mode; };
extern void DrawLineWithMode_Impl(struct pt *, struct pt *, int);
extern void DrawLineWithMode_ParamBlock(struct lmcmd *);
extern void DrawLineWithMode(struct pt *a, struct pt *b, int c);
extern void DrawLineWithMode_ParamBlock(struct lmcmd *q);

/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void ClipBlit_Replace(struct pt *p, int n)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0)
		ClipBlit_Replace_Impl(p, n);
	else {
		q = DrawQueue_Alloc(10);
		*(void **)q = (void *)ClipBlit_Replace_ParamBlock;
		*(struct pt *)(q + 4) = *p;
		*(int *)(q + 8) = n;
		DrawRing_Post(q);
	}
}
/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void ColorBlit2(struct rect *r, int n)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0) {
		COLORBLIT_MODE_ACTIVE = COLORBLIT_MODE;
		if (DRAW_ENABLED != 0)
			ColorBlit2_Impl(r, n);
	} else {
		q = DrawQueue_Alloc(16);
		*(void **)q = (void *)ColorBlit2_CallbackBlock;
		*(struct rect *)(q + 4) = *r;
		*(int *)(q + 12) = n;
		q[14] = COLORBLIT_MODE;
		DrawRing_Post(q);
	}
}
/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawDesignBox(struct rect *r, int a, int b)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0) {
		if (DRAW_ENABLED != 0)
			DrawDesignBox_Impl(r, a, b);
	} else {
		q = DrawQueue_Alloc(16);
		*(void **)q = (void *)DrawDesignBox_QueueCallback;
		*(struct rect *)(q + 4) = *r;
		*(int *)(q + 12) = a;
		*(int *)(q + 14) = b;
		DrawRing_Post(q);
	}
}
/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-name: DrawDottedLineMode_ParamBlock=DrawDottedLineWithMode_ParamBlock */
void DrawDottedLineWithMode(struct pt *a, struct pt *b, int m)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0) {
		COLORBLIT_MODE_ACTIVE = COLORBLIT_MODE;
		if (DRAW_ENABLED != 0)
			DrawDottedLineWithMode_Impl(a, b, m);
	} else {
		q = DrawQueue_Alloc(16);
		*(void **)q = (void *)DrawDottedLineMode_ParamBlock;
		*(struct pt *)(q + 4) = *a;
		*(struct pt *)(q + 8) = *b;
		*(int *)(q + 12) = m;
		q[14] = COLORBLIT_MODE;
		DrawRing_Post(q);
	}
}
/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void ColorBlit(struct rect *r, int c)
{
	struct cbcmd *q;

	if (IsDrawTask() != 0) {
		COLORBLIT_MODE_ACTIVE = COLORBLIT_MODE;
		if (DRAW_ENABLED != 0)
			ColorBlit_Impl(r, c);
	} else {
		q = (struct cbcmd *)DrawQueue_Alloc(sizeof(struct cbcmd));
		q->fn = ColorBlit_CallbackBlock;
		q->r = *r;
		q->c = c;
		q->mode = COLORBLIT_MODE;
		DrawRing_Post(q);
	}
}
/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawLineWithMode(struct pt *a, struct pt *b, int c)
{
	struct lmcmd *q;

	if (IsDrawTask() != 0) {
		COLORBLIT_MODE_ACTIVE = COLORBLIT_MODE;
		if (DRAW_ENABLED != 0)
			DrawLineWithMode_Impl(a, b, c);
	} else {
		q = (struct lmcmd *)DrawQueue_Alloc(sizeof(struct lmcmd));
		q->fn = DrawLineWithMode_ParamBlock;
		q->a = *a;
		q->b = *b;
		q->c = c;
		q->mode = COLORBLIT_MODE;
		DrawRing_Post(q);
	}
}

/* cc900-module: ChangePalette ChangeWall ChangeWallPalette InitDrawTask LcdOn PaletteBankRotate_Impl SetChangeRect UpdateScreen */
extern void PaletteBankRotate_Impl(void);
extern void PaletteBankRotate_Code(unsigned char *q);
extern void PaletteBankRotate(void);

/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
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

/* cc900-module: ChangePalette_Impl ChangeWallPalette_Impl ChangeWall_Impl Display_FillPalBandFromEnt_Impl Display_FillPaletteBandFromEntry_Impl IsXspInDrawStack */
struct icmd { void (*fn)(struct icmd *); unsigned int w; };
extern void ChangePalette_Impl(unsigned int);
void ChangePalette_QueueCallback(struct icmd *q);
extern void ChangePalette(unsigned int w);
extern void ChangePalette_QueueCallback(struct icmd *q);
extern void ChangeWall_Impl(unsigned int);
void ChangeWall_QueueCallback(struct icmd *q);
extern void ChangeWall(unsigned int w);
extern void ChangeWall_QueueCallback(struct icmd *q);
extern void ChangeWallPalette_Impl(unsigned int);
void ChangeWallPalette_QueueCallback(struct icmd *q);
extern void ChangeWallPalette(unsigned int w);
extern void ChangeWallPalette_QueueCallback(struct icmd *q);

/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void ChangePalette(unsigned int w)
{
	struct icmd *q;

	if (IsXspInDrawStack() != 0)
		ChangePalette_Impl(w);
	else {
		q = (struct icmd *)DrawQueue_Alloc(6);
		q->fn = ChangePalette_QueueCallback;
		q->w = w;
		DrawRing_Post(q);
	}
}
/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void ChangeWall(unsigned int w)
{
	struct icmd *q;

	if (IsXspInDrawStack() != 0)
		ChangeWall_Impl(w);
	else {
		q = (struct icmd *)DrawQueue_Alloc(6);
		q->fn = ChangeWall_QueueCallback;
		q->w = w;
		DrawRing_Post(q);
	}
}
/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void ChangeWallPalette(unsigned int w)
{
	struct icmd *q;

	if (IsXspInDrawStack() != 0)
		ChangeWallPalette_Impl(w);
	else {
		q = (struct icmd *)DrawQueue_Alloc(6);
		q->fn = ChangeWallPalette_QueueCallback;
		q->w = w;
		DrawRing_Post(q);
	}
}
