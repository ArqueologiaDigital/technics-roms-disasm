/* Phase 6, lane_p6 helper K, round 1, module 273, form b: the queued executors of p6_K_1m273a.c only, with the
   command's fields written straight into the _Impl call (form a reads them into locals before the DRAW_ENABLED test,
   as the ROM's order suggests; this form checks whether V4.23 -O3 hoists the loads itself), and DrawString with
   the string copied through the command's field. */
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

extern void DrawString_DeferredPath_Code(struct dscmd *);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);

void DrawLine_QueuedExec(struct dlcmd *q)
{
	if (DRAW_ENABLED != 0)
		DrawLine_Impl(&q->a, &q->b, q->c);
}

void DrawBox_QueuedExec(struct dbcmd *q)
{
	if (DRAW_ENABLED != 0)
		DrawBox_Impl(&q->r, q->c);
}

void DrawFrameSP_QueuedExec(struct dfcmd *q)
{
	if (DRAW_ENABLED != 0)
		DrawFrameSP_Impl(&q->p, q->b, q->c);
}

void MovePixels_QueuedExec(struct mpcmd *q)
{
	if (DRAW_ENABLED != 0)
		MovePixels_Impl(&q->r, &q->p);
}

void DrawBitmapFast_QueuedExec(struct bfcmd *q)
{
	if (DRAW_ENABLED != 0)
		DrawBitmapFast_Impl(&q->p, q->bmp);
}

void DrawBitmapSP_DeferredPath_Code(struct spcmd *q)
{
	if (DRAW_ENABLED != 0)
		DrawBitmapSP_Impl(&q->p, q->bmp, q->c, q->d);
}

void DrawBitmapSP2_Exec(struct sp2cmd *q)
{
	if (DRAW_ENABLED != 0)
		DrawBitmapSP2_Impl(&q->p, q->bmp, q->c, q->d, q->e, q->f);
}

/* form b: the string copied through the command's field */
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
		Strcpy(q->s = buf, s);
		q->font = font;
		q->a = a;
		q->b = b;
		DrawRing_Post(q);
	}
}

void DrawString_DeferredPath_Code(struct dscmd *q)
{
	if (DRAW_ENABLED != 0)
		DrawString_Impl(&q->r, &q->p, q->s, q->font, q->a, q->b);
	DrawFunc_Return(q->s);
}

void DrawLineWithMode_ParamBlock(struct lmcmd *q)
{
	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		DrawLineWithMode_Impl(&q->a, &q->b, q->c);
}

void ColorBlit_CallbackBlock(struct cbcmd *q)
{
	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		ColorBlit_Impl(&q->r, q->c);
}
