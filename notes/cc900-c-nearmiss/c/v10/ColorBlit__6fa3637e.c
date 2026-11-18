/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_K_1m273a.c (2026-11-18-12-p6-r35)
   sha256 6fa3637e333b6b6b507de0c084754c41e66a8f074d4f63dc29f857986e6eb4b8 (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, lane_p6 helper K, round 1, module 273 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a:
   the drawing primitives' task-side wrappers (ui/drawing_primitives.s, ui/ui_window_procs.s) and their queued
   executors.  On the draw task's own stack (IS_XSP_INSIDE_4K_REGION_AT_1C032 != 0) a wrapper calls its _Impl at once
   when DRAW_ENABLED is set; from any other task it builds a draw command {executor, copies of the arguments} with
   DrawQueue_Alloc and posts it with DrawRing_Post.  Each executor reloads the arguments from the command (into
   registers, BEFORE the DRAW_ENABLED test: form a reads them into locals first) and calls the _Impl when DRAW_ENABLED
   is set; the call sits inside the `if`, so it stays `calr; ret` (not a tail jump).
   DrawString's direct path passes ((cmd *)XIZ)->s, i.e. the uninitialised command pointer's string field, and not its
   own string argument: written here as the ROM does it.
   DrawStringLeftJustify: the descent stays in HL across the struct copy (a register local: -O3 -Xr expected). */
/* cc900-module: ColorBlit_Impl DrawBitmapFast_Impl DrawBitmapSP2_Impl DrawBitmapSP_Impl DrawBox_Impl DrawFrameSP_Impl DrawFunc_Return DrawLineWithMode_Impl DrawLine_Impl DrawQueue_Alloc DrawRing_Post DrawString DrawString_Impl IS_XSP_INSIDE_4K_REGION_AT_1C032 MovePixels_Impl */   /* scripts/analysis/cc900/module_calls.py v10 */
/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-name: DrawBitmapSP2_Exec=DrawBitmapSP2_DeferredPath_Code */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern void DrawFunc_Return(void *p);
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE;
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern int __cdecl Strlen(char *);
extern char *__cdecl Strcpy(char *, char *);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);

struct dlcmd { void (*fn)(struct dlcmd *); struct pt a; struct pt b; int c; };
struct dbcmd { void (*fn)(struct dbcmd *); struct rect r; int c; };
struct dfcmd { void (*fn)(struct dfcmd *); struct pt p; int b; int c; };
struct mpcmd { void (*fn)(struct mpcmd *); struct rect r; struct pt p; };
struct bfcmd { void (*fn)(struct bfcmd *); struct pt p; unsigned char *bmp; };
struct spcmd { void (*fn)(struct spcmd *); struct pt p; unsigned char *bmp; int c; int d; };
struct sp2cmd { void (*fn)(struct sp2cmd *); struct pt p; unsigned char *bmp; int c; int d; int e; int f; };
struct dscmd { void (*fn)(struct dscmd *); struct rect r; struct pt p; char *s; long font; int a; int b; };
struct lmcmd { void (*fn)(struct lmcmd *); struct pt a; struct pt b; int c; unsigned char mode; };
struct cbcmd { void (*fn)(struct cbcmd *); struct rect r; int c; unsigned char mode; };

extern void DrawLine_Impl(struct pt *, struct pt *, int);
extern void DrawBox_Impl(struct rect *, int);
extern void DrawFrameSP_Impl(struct pt *, int, int);
extern void MovePixels_Impl(struct rect *, struct pt *);
extern void DrawBitmapFast_Impl(struct pt *, unsigned char *);
extern void DrawBitmapSP_Impl(struct pt *, unsigned char *, int, int);
extern void DrawBitmapSP2_Impl(struct pt *, unsigned char *, int, int, int, int);
extern void DrawString_Impl(struct rect *, struct pt *, char *, long, int, int);
extern void DrawLineWithMode_Impl(struct pt *, struct pt *, int);
extern void ColorBlit_Impl(struct rect *, int);

extern void DrawLine_QueuedExec(struct dlcmd *);
extern void DrawBox_QueuedExec(struct dbcmd *);
extern void DrawFrameSP_QueuedExec(struct dfcmd *);
extern void MovePixels_QueuedExec(struct mpcmd *);
extern void DrawBitmapFast_QueuedExec(struct bfcmd *);
extern void DrawBitmapSP_DeferredPath_Code(struct spcmd *);
extern void DrawBitmapSP2_Exec(struct sp2cmd *);
extern void DrawString_DeferredPath_Code(struct dscmd *);
extern void DrawLineWithMode_ParamBlock(struct lmcmd *);
extern void ColorBlit_CallbackBlock(struct cbcmd *);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);

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

void DrawLine_QueuedExec(struct dlcmd *q)
{
	struct pt *a = &q->a;
	struct pt *b = &q->b;
	int c = q->c;

	if (DRAW_ENABLED != 0)
		DrawLine_Impl(a, b, c);
}

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

void DrawBox_QueuedExec(struct dbcmd *q)
{
	struct rect *r = &q->r;
	int c = q->c;

	if (DRAW_ENABLED != 0)
		DrawBox_Impl(r, c);
}

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

void DrawFrameSP_QueuedExec(struct dfcmd *q)
{
	struct pt *p = &q->p;
	int b = q->b;
	int c = q->c;

	if (DRAW_ENABLED != 0)
		DrawFrameSP_Impl(p, b, c);
}

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

void MovePixels_QueuedExec(struct mpcmd *q)
{
	struct rect *r = &q->r;
	struct pt *p = &q->p;

	if (DRAW_ENABLED != 0)
		MovePixels_Impl(r, p);
}

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

void DrawBitmapFast_QueuedExec(struct bfcmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;

	if (DRAW_ENABLED != 0)
		DrawBitmapFast_Impl(p, bmp);
}

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

void DrawBitmapSP_DeferredPath_Code(struct spcmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;
	int c = q->c;
	int d = q->d;

	if (DRAW_ENABLED != 0)
		DrawBitmapSP_Impl(p, bmp, c, d);
}

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

void DrawStringLeftJustify(struct rect *r, struct pt *p, char *s, long font, int a, int b)
{
	int h;
	int d;
	struct pt at;

	h = GetCharHeight(font);
	d = GetCharDescent(font);
	at = *p;
	at.x = r->x0 + 4;
	at.y -= (h - d) / 2;
	at.y += GetCenteredDelta(font);
	DrawString(r, &at, s, font, a, b);
}

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

void DrawLineWithMode_ParamBlock(struct lmcmd *q)
{
	struct pt *a = &q->a;
	struct pt *b = &q->b;
	int c = q->c;

	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		DrawLineWithMode_Impl(a, b, c);
}

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

void ColorBlit_CallbackBlock(struct cbcmd *q)
{
	struct rect *r = &q->r;
	int c = q->c;

	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		ColorBlit_Impl(r, c);
}
