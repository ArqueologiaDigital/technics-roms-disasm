/* Functions of ui/drawing_primitives.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ColorBlit_Impl DrawBitmapFast_Impl DrawBitmapSP2_Impl DrawBitmapSPFast_Impl DrawBitmapSP_Impl DrawBox_Impl DrawFrameSP_Impl DrawFunc_Return DrawLineWithMode_Impl DrawLine_Impl DrawQueue_Alloc DrawRing_Post DrawString DrawString_Impl IS_XSP_INSIDE_4K_REGION_AT_1C032 MovePixels_Impl */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
extern int DRAW_ENABLED;
struct sp2cmd { void (*fn)(struct sp2cmd *); struct pt p; unsigned char *bmp; int c; int d; int e; int f; };
extern void DrawBitmapSP2_Impl(struct pt *, unsigned char *, int, int, int, int);
extern void DrawBitmapSP2_Exec(struct sp2cmd *);
extern void DrawBitmapSP2_Exec(struct sp2cmd *q);
struct spcmd { void (*fn)(struct spcmd *); struct pt p; unsigned char *bmp; int c; int d; };
extern void DrawBitmapSP_Impl(struct pt *, unsigned char *, int, int);
extern void DrawBitmapSP_DeferredPath_Code(struct spcmd *);
extern void DrawBitmapSP_DeferredPath_Code(struct spcmd *q);
struct rect { int x0, y0, x1, y1; };
extern void DrawFunc_Return(void *p);
struct dscmd { void (*fn)(struct dscmd *); struct rect r; struct pt p; char *s; long font; int a; int b; };
extern void DrawString_Impl(struct rect *, struct pt *, char *, long, int, int);
extern void DrawString_DeferredPath_Code(struct dscmd *);
extern void DrawString_DeferredPath_Code(struct dscmd *q);
struct cmd_pt_lii { void *fn; struct pt p; long b; int c; int d; };
extern void DrawBitmapSPFast_Impl(struct pt *, long, int, int);
extern void DrawBmpSPFast_DeferredCode(struct cmd_pt_lii *q);

/* cc900-name: DrawBitmapSP2_Exec=DrawBitmapSP2_DeferredPath_Code */
void DrawBitmapSP2_Exec(struct sp2cmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;
	int c = q->c;
	int d = q->d;
	int e = q->e;
	int f = q->f;

	if (DRAW_ENABLED != 0)
		DrawBitmapSP2_Impl(p, bmp, c, d, e, f);
}

void DrawBitmapSP_DeferredPath_Code(struct spcmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;
	int c = q->c;
	int d = q->d;

	if (DRAW_ENABLED != 0)
		DrawBitmapSP_Impl(p, bmp, c, d);
}

void DrawString_DeferredPath_Code(struct dscmd *q)
{
	struct rect *r = &q->r;
	struct pt *p = &q->p;
	long font = q->font;
	int a = q->a;
	int b = q->b;

	if (DRAW_ENABLED != 0)
		DrawString_Impl(r, p, q->s, font, a, b);
	DrawFunc_Return(q->s);
}

/* cc900-name: DrawBmpSPFast_DeferredCode=DrawBitmapSPFast_DeferredPath_Code */
void DrawBmpSPFast_DeferredCode(struct cmd_pt_lii *q)
{
	struct pt *p;
	long b;
	int c;
	int d;

	p = &q->p;
	b = q->b;
	c = q->c;
	d = q->d;
	if (DRAW_ENABLED != 0)
		DrawBitmapSPFast_Impl(p, b, c, d);
}

/* cc900-module: ColorBlit2 DrawBitmap_Impl */
struct bmcmd { void (*fn)(struct bmcmd *); struct pt p; unsigned char *bmp; };
extern void DrawBitmap_Impl(struct pt *, unsigned char *);
extern void DrawBitmap_QueuedExec(struct bmcmd *q);

void DrawBitmap_QueuedExec(struct bmcmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;

	if (DRAW_ENABLED != 0)
		DrawBitmap_Impl(p, bmp);
}
