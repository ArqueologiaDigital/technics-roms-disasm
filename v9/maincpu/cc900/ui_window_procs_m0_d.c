/* Functions of ui/ui_window_procs.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ClipBlit_Replace_Impl ColorBlit2_Impl ColorBlit_Impl DrawBitmapFast_Impl DrawBitmapSP2_Impl DrawBitmapSPFast_Impl DrawBitmapSP_Impl DrawBox_Impl DrawDesignBox_Impl DrawDottedLineWithMode_Impl DrawFrameSP_Impl DrawFrame_Impl DrawFunc_Return DrawIcons_Impl DrawLineWithMode_Impl DrawLine_Impl DrawQueue_Alloc DrawRing_Post DrawString DrawString_Impl Gfx_BlitDirtyRegions IS_XSP_INSIDE_4K_REGION_AT_1C032 MovePixels_Impl */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE_ACTIVE;
struct cbcmd { void (*fn)(struct cbcmd *); struct rect r; int c; unsigned char mode; };
extern void ColorBlit_Impl(struct rect *, int);
extern void ColorBlit_CallbackBlock(struct cbcmd *);
extern void ColorBlit_CallbackBlock(struct cbcmd *q);
struct pt { int x, y; };
struct lmcmd { void (*fn)(struct lmcmd *); struct pt a; struct pt b; int c; unsigned char mode; };
extern void DrawLineWithMode_Impl(struct pt *, struct pt *, int);
extern void DrawLineWithMode_ParamBlock(struct lmcmd *);
extern void DrawLineWithMode_ParamBlock(struct lmcmd *q);
struct cmd_r_im { void *fn; struct rect r; int n; unsigned char mode; unsigned char pad; };
extern void ColorBlit2_Impl(struct rect *, int);
extern void ColorBlit2_CallbackBlock(struct cmd_r_im *q);
struct cmd_pt_pt { void *fn; struct pt a; struct pt b; int m; unsigned char mode; unsigned char pad; };
extern void DrawDottedLineWithMode_Impl(struct pt *, struct pt *, int);
extern void DrawDottedLineMode_ParamBlock(struct cmd_pt_pt *q);

void ColorBlit_CallbackBlock(struct cbcmd *q)
{
	struct rect *r = &q->r;
	int c = q->c;

	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		ColorBlit_Impl(r, c);
}

void DrawLineWithMode_ParamBlock(struct lmcmd *q)
{
	struct pt *a = &q->a;
	struct pt *b = &q->b;
	int c = q->c;

	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		DrawLineWithMode_Impl(a, b, c);
}

void ColorBlit2_CallbackBlock(struct cmd_r_im *q)
{
	struct rect *r;
	int n;

	r = &q->r;
	n = q->n;
	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		ColorBlit2_Impl(r, n);
}

/* cc900-name: DrawDottedLineMode_ParamBlock=DrawDottedLineWithMode_ParamBlock */
void DrawDottedLineMode_ParamBlock(struct cmd_pt_pt *q)
{
	struct pt *a;
	struct pt *b;
	int m;

	a = &q->a;
	b = &q->b;
	m = q->m;
	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		DrawDottedLineWithMode_Impl(a, b, m);
}
