/* Phase 6, lane_p6 helper L, round 1, form a: module 273 (draw-queue wrappers and render loops).
   - DrawBitmapFile / DrawBitmapFile_QueuedExec: DrawBitmapFast's shape, a 12-byte record {fn, pt, long}.
   - DrawDesignBox_ByteData / _Code: misnamed; DrawLine's shape for DrawDottedLine_Impl (record {fn, pt, pt, int}).
   - DrawMonoBitmap (= ColorBlit2_LargeCodeBlock, same address) / DrawMonoBitmap_ParamBlock: a rect copied by
     ldirw, the blit mode byte copied to COLORBLIT_MODE_ACTIVE in both paths.
   - DrawWall (two O3 wait loops, tail jr to DrawWall_DoCopy, tail jrl to DrawRing_Post), DrawWall_Deferred_Code
     (a tail jr), DrawWall_DoCopy (two __cdecl Mem_Copy, the change rect stored y0 first: `x0 = y0 = 0`).
   - GraphicsRender_ProcessEntries / GraphicsRender_Start: a handler table copied into the frame (struct copy of an
     extern struct), dispatch on the entry's first byte, advance by its second.
   - GraphicsRender_RetStub, GraphicsRender_ShortByteBlock, DrawFunc_Return: one-liners. */
/* cc900-module: DrawBitmapFile_Impl DrawDottedLine_Impl DrawMonoBitmap_Impl DrawQueue_Alloc DrawRing_Post DrawWall_DoCopy GraphicsRender_ProcessEntries GraphicsRender_RetStub IS_XSP_INSIDE_4K_REGION_AT_1C032 SetChangeRect */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;

/* DrawBitmapFile */
struct bfcmd { void (*fn)(struct bfcmd *); struct pt p; long b; };
extern void DrawBitmapFile_Impl(struct pt *, long);
extern void DrawBitmapFile_QueuedExec(struct bfcmd *q);
extern void DrawBitmapFile(struct pt *p, long b);

/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
void DrawBitmapFile(struct pt *p, long b)
{
	struct bfcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmapFile_Impl(p, b);
	} else {
		q = (struct bfcmd *)DrawQueue_Alloc(sizeof(struct bfcmd));
		q->fn = DrawBitmapFile_QueuedExec;
		q->p = *p;
		q->b = b;
		DrawRing_Post(q);
	}
}

void DrawBitmapFile_QueuedExec(struct bfcmd *q)
{
	struct pt *p = &q->p;
	long b = q->b;

	if (DRAW_ENABLED != 0)
		DrawBitmapFile_Impl(p, b);
}

/* DrawDottedLine, under the tree's (wrong) name DrawDesignBox_ByteData */
struct ddcmd { void (*fn)(struct ddcmd *); struct pt a; struct pt b; int c; };
extern void DrawDottedLine_Impl(struct pt *, struct pt *, int);
extern void DrawDesignBox_ByteData_Code(struct ddcmd *q);
extern void DrawDesignBox_ByteData(struct pt *a, struct pt *b, int c);

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

void DrawDesignBox_ByteData_Code(struct ddcmd *q)
{
	struct pt *a = &q->a;
	struct pt *b = &q->b;
	int c = q->c;

	if (DRAW_ENABLED != 0)
		DrawDottedLine_Impl(a, b, c);
}

/* DrawMonoBitmap */
struct mbcmd { void (*fn)(struct mbcmd *); struct rect r; unsigned char *bits; int color; unsigned char mode; };
extern unsigned char COLORBLIT_MODE;
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern void DrawMonoBitmap_Impl(struct rect *r, unsigned char *bits, int color);
extern void DrawMonoBitmap_ParamBlock(struct mbcmd *q);
extern void DrawMonoBitmap(struct rect *r, unsigned char *bits, int color);

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

/* DrawWall */
struct wcmd { void (*fn)(struct wcmd *); };
extern int ram_30450;
extern unsigned char *WALLPAPER_BITMAP;
extern unsigned char OFFSCREEN_BUFFER_1[];
extern void Kernel_SemaSignal(int);
extern void Kernel_YieldRotate(int);
extern void *__cdecl Mem_Copy(void *, void *, unsigned int);
extern void SetChangeRect(struct rect *r);
extern void DrawWall(void);
extern void DrawWall_Deferred_Code(struct wcmd *q);
extern void DrawWall_DoCopy(void);

void DrawWall(void)
{
	struct wcmd *q;

	if (IsDrawTask() != 0) {
		ram_30450 = 1;
		DRAW_ENABLED = 1;
		DrawWall_DoCopy();
	} else {
		ram_30450 = 0;
		while (DRAW_ENABLED != 0) {
			Kernel_SemaSignal(1);
			Kernel_YieldRotate(3);
		}
		ram_30450 = 1;
		while (DRAW_ENABLED == 0) {
			Kernel_SemaSignal(1);
			Kernel_YieldRotate(3);
		}
		q = (struct wcmd *)DrawQueue_Alloc(sizeof(struct wcmd));
		q->fn = DrawWall_Deferred_Code;
		DrawRing_Post(q);
	}
}

void DrawWall_Deferred_Code(struct wcmd *q)
{
	DrawWall_DoCopy();
}

void DrawWall_DoCopy(void)
{
	struct rect r;
	unsigned char *dst;
	unsigned char *src;

	src = WALLPAPER_BITMAP;
	dst = OFFSCREEN_BUFFER_1;
	Mem_Copy(dst, src, 0x9600);
	dst += 0x9600;
	src += 0x9600;
	Mem_Copy(dst, src, 0x9600);
	r.x0 = r.y0 = 0;
	r.x1 = 319;
	r.y1 = 239;
	SetChangeRect(&r);
}

/* GraphicsRender */
struct gtab36 { void (*f[36])(unsigned char *); };
struct gtab12 { void (*f[12])(unsigned char *); };
extern struct gtab36 GraphicsRender_ProcessEntries_PtrTable;
extern struct gtab12 GraphicsRender_Start_PtrTable;
extern void GraphicsRender_RetStub(unsigned char *p);
extern void GraphicsRender_ProcessEntries(unsigned char *p, unsigned char *end);
extern void GraphicsRender_ShortByteBlock(unsigned char *p);
extern void GraphicsRender_Start(unsigned char *p, unsigned char *end);

void GraphicsRender_ProcessEntries(unsigned char *p, unsigned char *end)
{
	unsigned char len;
	struct gtab36 t;
	unsigned char c;

	t = GraphicsRender_ProcessEntries_PtrTable;
	while (p < end) {
		c = p[0];
		len = p[1];
		if (c > 35) {
			GraphicsRender_RetStub(p);
			break;
		}
		t.f[c](p);
		p += len;
	}
}

void GraphicsRender_RetStub(unsigned char *p)
{
}

void GraphicsRender_ShortByteBlock(unsigned char *p)
{
	GraphicsRender_ProcessEntries(p, p + 1);
}

void GraphicsRender_Start(unsigned char *p, unsigned char *end)
{
	unsigned char len;
	struct gtab12 t;
	unsigned char c;

	t = GraphicsRender_Start_PtrTable;
	while (p < end) {
		c = p[0];
		len = p[1];
		if (c > 11) {
			GraphicsRender_RetStub(p);
			break;
		}
		t.f[c](p);
		p += len;
	}
}

void DrawFunc_Return(void *p)
{
}
