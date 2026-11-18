/* Functions of ui/drawing_primitives.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ClipBlit_Replace_Impl ColorBlit2_Impl ColorBlit_Impl DrawBitmapFast_Impl DrawBitmapSP2_Impl DrawBitmapSPFast_Impl DrawBitmapSP_Impl DrawBox_Impl DrawDesignBox_Impl DrawDottedLineWithMode_Impl DrawFrameSP_Impl DrawFrame_Impl DrawFunc_Return DrawIcons_Impl DrawLineWithMode_Impl DrawLine_Impl DrawQueue_Alloc DrawRing_Post DrawString DrawString_Impl Gfx_BlitDirtyRegions IS_XSP_INSIDE_4K_REGION_AT_1C032 MovePixels_Impl */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern void DrawBitmapSPFast_Impl(struct pt *, long, int, int);
extern void DrawBmpSPFast_DeferredCode(unsigned char *q);
extern void DrawBitmapSPFast(struct pt *p, long b, int c, int d);
struct rect { int x0, y0, x1, y1; };
extern void DrawFrame_Impl(struct rect *, int);
extern void DrawFrame_QueuedExec(unsigned char *q);
extern void DrawFrame(struct rect *r, int n);
extern void DrawIcons_Impl(struct pt *, long);
extern void DrawIcons_QueuedExec(unsigned char *q);
extern void DrawIcons(struct pt *p, long n);
extern int IsDrawTask(void);
struct bfcmd { void (*fn)(struct bfcmd *); struct pt p; unsigned char *bmp; };
extern void DrawBitmapFast_Impl(struct pt *, unsigned char *);
extern void DrawBitmapFast_QueuedExec(struct bfcmd *);
extern void DrawBitmapFast(struct pt *p, unsigned char *bmp);
extern void DrawBitmapFast_QueuedExec(struct bfcmd *q);
struct spcmd { void (*fn)(struct spcmd *); struct pt p; unsigned char *bmp; int c; int d; };
extern void DrawBitmapSP_Impl(struct pt *, unsigned char *, int, int);
extern void DrawBitmapSP_DeferredPath_Code(struct spcmd *);
extern void DrawBitmapSP(struct pt *p, unsigned char *bmp, int c, int d);
extern void DrawBitmapSP_DeferredPath_Code(struct spcmd *q);
struct sp2cmd { void (*fn)(struct sp2cmd *); struct pt p; unsigned char *bmp; int c; int d; int e; int f; };
extern void DrawBitmapSP2_Impl(struct pt *, unsigned char *, int, int, int, int);
extern void DrawBitmapSP2_Exec(struct sp2cmd *);
extern void DrawBitmapSP2(struct pt *p, unsigned char *bmp, int c, int d, int e, int f);
extern void DrawBitmapSP2_Exec(struct sp2cmd *q);
struct dbcmd { void (*fn)(struct dbcmd *); struct rect r; int c; };
extern void DrawBox_Impl(struct rect *, int);
extern void DrawBox_QueuedExec(struct dbcmd *);
extern void DrawBox(struct rect *r, int c);
extern void DrawBox_QueuedExec(struct dbcmd *q);
struct dfcmd { void (*fn)(struct dfcmd *); struct pt p; int b; int c; };
extern void DrawFrameSP_Impl(struct pt *, int, int);
extern void DrawFrameSP_QueuedExec(struct dfcmd *);
extern void DrawFrameSP(struct pt *p, int b, int c);
extern void DrawFrameSP_QueuedExec(struct dfcmd *q);
struct dlcmd { void (*fn)(struct dlcmd *); struct pt a; struct pt b; int c; };
extern void DrawLine_Impl(struct pt *, struct pt *, int);
extern void DrawLine_QueuedExec(struct dlcmd *);
extern void DrawLine(struct pt *a, struct pt *b, int c);
extern void DrawLine_QueuedExec(struct dlcmd *q);
extern int __cdecl Strlen(char *);
extern char *__cdecl Strcpy(char *, char *);
struct dscmd { void (*fn)(struct dscmd *); struct rect r; struct pt p; char *s; long font; int a; int b; };
extern void DrawString_Impl(struct rect *, struct pt *, char *, long, int, int);
extern void DrawString_DeferredPath_Code(struct dscmd *);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern void DrawString(struct rect *r, struct pt *p, char *s, long font, int a, int b);
extern void DrawString_DeferredPath_Code(struct dscmd *q);
struct mpcmd { void (*fn)(struct mpcmd *); struct rect r; struct pt p; };
extern void MovePixels_Impl(struct rect *, struct pt *);
extern void MovePixels_QueuedExec(struct mpcmd *);
extern void MovePixels(struct rect *r, struct pt *p);
extern void MovePixels_QueuedExec(struct mpcmd *q);

/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-name: DrawBmpSPFast_DeferredCode=DrawBitmapSPFast_DeferredPath_Code */
void DrawBitmapSPFast(struct pt *p, long b, int c, int d)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmapSPFast_Impl(p, b, c, d);
	} else {
		q = DrawQueue_Alloc(16);
		*(void **)q = (void *)DrawBmpSPFast_DeferredCode;
		*(struct pt *)(q + 4) = *p;
		*(long *)(q + 8) = b;
		*(int *)(q + 12) = c;
		*(int *)(q + 14) = d;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawFrame(struct rect *r, int n)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0) {
		if (DRAW_ENABLED != 0)
			DrawFrame_Impl(r, n);
	} else {
		q = DrawQueue_Alloc(14);
		*(void **)q = (void *)DrawFrame_QueuedExec;
		*(struct rect *)(q + 4) = *r;
		*(int *)(q + 12) = n;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawIcons(struct pt *p, long n)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0) {
		if (DRAW_ENABLED != 0)
			DrawIcons_Impl(p, n);
	} else {
		q = DrawQueue_Alloc(12);
		*(void **)q = (void *)DrawIcons_QueuedExec;
		*(struct pt *)(q + 4) = *p;
		*(long *)(q + 8) = n;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawBitmapFast(struct pt *p, unsigned char *bmp)
{
	struct bfcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmapFast_Impl(p, bmp);
	} else {
		q = (struct bfcmd *)DrawQueue_Alloc(sizeof(struct bfcmd));
		q->fn = DrawBitmapFast_QueuedExec;
		q->p = *p;
		q->bmp = bmp;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawBitmapSP(struct pt *p, unsigned char *bmp, int c, int d)
{
	struct spcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmapSP_Impl(p, bmp, c, d);
	} else {
		q = (struct spcmd *)DrawQueue_Alloc(sizeof(struct spcmd));
		q->fn = DrawBitmapSP_DeferredPath_Code;
		q->p = *p;
		q->bmp = bmp;
		q->c = c;
		q->d = d;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-name: DrawBitmapSP2_Exec=DrawBitmapSP2_DeferredPath_Code */
void DrawBitmapSP2(struct pt *p, unsigned char *bmp, int c, int d, int e, int f)
{
	struct sp2cmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmapSP2_Impl(p, bmp, c, d, e, f);
	} else {
		q = (struct sp2cmd *)DrawQueue_Alloc(sizeof(struct sp2cmd));
		q->fn = DrawBitmapSP2_Exec;
		q->p = *p;
		q->bmp = bmp;
		q->c = c;
		q->d = d;
		q->e = e;
		q->f = f;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawBox(struct rect *r, int c)
{
	struct dbcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBox_Impl(r, c);
	} else {
		q = (struct dbcmd *)DrawQueue_Alloc(sizeof(struct dbcmd));
		q->fn = DrawBox_QueuedExec;
		q->r = *r;
		q->c = c;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawFrameSP(struct pt *p, int b, int c)
{
	struct dfcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawFrameSP_Impl(p, b, c);
	} else {
		q = (struct dfcmd *)DrawQueue_Alloc(sizeof(struct dfcmd));
		q->fn = DrawFrameSP_QueuedExec;
		q->p = *p;
		q->b = b;
		q->c = c;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawLine(struct pt *a, struct pt *b, int c)
{
	struct dlcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawLine_Impl(a, b, c);
	} else {
		q = (struct dlcmd *)DrawQueue_Alloc(sizeof(struct dlcmd));
		q->fn = DrawLine_QueuedExec;
		q->a = *a;
		q->b = *b;
		q->c = c;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawString(struct rect *r, struct pt *p, char *s, long font, int a, int b)
{
	struct dscmd *q;
	char *buf;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawString_Impl(r, p, q->s, font, a, b);
	} else {
		buf = (char *)DrawQueue_Alloc(Strlen(s) + 1);
		q = (struct dscmd *)DrawQueue_Alloc(sizeof(struct dscmd));
		q->fn = DrawString_DeferredPath_Code;
		q->r = *r;
		q->p = *p;
		q->s = buf;
		Strcpy(buf, s);
		q->font = font;
		q->a = a;
		q->b = b;
		DrawRing_Post(q);
	}
}

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void MovePixels(struct rect *r, struct pt *p)
{
	struct mpcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			MovePixels_Impl(r, p);
	} else {
		q = (struct mpcmd *)DrawQueue_Alloc(sizeof(struct mpcmd));
		q->fn = MovePixels_QueuedExec;
		q->r = *r;
		q->p = *p;
		DrawRing_Post(q);
	}
}
