/* Functions of ui/drawing_primitives.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: ClipBlit_Replace_Impl ColorBlit2_Impl ColorBlit_Impl DrawBitmapFast_Impl DrawBitmapSP2_Impl DrawBitmapSPFast_Impl DrawBitmapSP_Impl DrawBox_Impl DrawDesignBox_Impl DrawDottedLineWithMode_Impl DrawFrameSP_Impl DrawFrame_Impl DrawFunc_Return DrawIcons_Impl DrawLineWithMode_Impl DrawLine_Impl DrawQueue_Alloc DrawRing_Post DrawString DrawString_Impl Gfx_BlitDirtyRegions IS_XSP_INSIDE_4K_REGION_AT_1C032 MovePixels_Impl */   /* scripts/analysis/cc900/module_calls.py v10 */

struct rect { int x0, y0, x1, y1; };
struct cmd_r_i { void *fn; struct rect r; int n; };
extern int DRAW_ENABLED;
extern void DrawFrame_Impl(struct rect *, int);
extern void DrawFrame_QueuedExec(struct cmd_r_i *q);
struct pt { int x, y; };
struct cmd_pt_l { void *fn; struct pt p; long n; };
extern void DrawIcons_Impl(struct pt *, long);
extern void DrawIcons_QueuedExec(struct cmd_pt_l *q);
struct bfcmd { void (*fn)(struct bfcmd *); struct pt p; unsigned char *bmp; };
extern void DrawBitmapFast_Impl(struct pt *, unsigned char *);
extern void DrawBitmapFast_QueuedExec(struct bfcmd *);
extern void DrawBitmapFast_QueuedExec(struct bfcmd *q);
struct dbcmd { void (*fn)(struct dbcmd *); struct rect r; int c; };
extern void DrawBox_Impl(struct rect *, int);
extern void DrawBox_QueuedExec(struct dbcmd *);
extern void DrawBox_QueuedExec(struct dbcmd *q);
struct dfcmd { void (*fn)(struct dfcmd *); struct pt p; int b; int c; };
extern void DrawFrameSP_Impl(struct pt *, int, int);
extern void DrawFrameSP_QueuedExec(struct dfcmd *);
extern void DrawFrameSP_QueuedExec(struct dfcmd *q);
struct dlcmd { void (*fn)(struct dlcmd *); struct pt a; struct pt b; int c; };
extern void DrawLine_Impl(struct pt *, struct pt *, int);
extern void DrawLine_QueuedExec(struct dlcmd *);
extern void DrawLine_QueuedExec(struct dlcmd *q);
struct mpcmd { void (*fn)(struct mpcmd *); struct rect r; struct pt p; };
extern void MovePixels_Impl(struct rect *, struct pt *);
extern void MovePixels_QueuedExec(struct mpcmd *);
extern void MovePixels_QueuedExec(struct mpcmd *q);

void DrawFrame_QueuedExec(struct cmd_r_i *q)
{
	struct rect *r;
	int n;

	r = &q->r;
	n = q->n;
	if (DRAW_ENABLED != 0)
		DrawFrame_Impl(r, n);
}

void DrawIcons_QueuedExec(struct cmd_pt_l *q)
{
	struct pt *p;
	long n;

	p = &q->p;
	n = q->n;
	if (DRAW_ENABLED != 0)
		DrawIcons_Impl(p, n);
}

void DrawBitmapFast_QueuedExec(struct bfcmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;

	if (DRAW_ENABLED != 0)
		DrawBitmapFast_Impl(p, bmp);
}

void DrawBox_QueuedExec(struct dbcmd *q)
{
	struct rect *r = &q->r;
	int c = q->c;

	if (DRAW_ENABLED != 0)
		DrawBox_Impl(r, c);
}

void DrawFrameSP_QueuedExec(struct dfcmd *q)
{
	struct pt *p = &q->p;
	int b = q->b;
	int c = q->c;

	if (DRAW_ENABLED != 0)
		DrawFrameSP_Impl(p, b, c);
}

void DrawLine_QueuedExec(struct dlcmd *q)
{
	struct pt *a = &q->a;
	struct pt *b = &q->b;
	int c = q->c;

	if (DRAW_ENABLED != 0)
		DrawLine_Impl(a, b, c);
}

void MovePixels_QueuedExec(struct mpcmd *q)
{
	struct rect *r = &q->r;
	struct pt *p = &q->p;

	if (DRAW_ENABLED != 0)
		MovePixels_Impl(r, p);
}
