/* Phase 6, lane_p6 helper J, round 1, module 273 (notes/cc900-phase6-2026-11-16/modules_v10.tsv), form a.
   The draw-queue wrappers of ui/drawing_primitives.s and ui/ui_window_procs.s (ClipBlit_Replace, DrawIcons,
   DrawBitmapSPFast, DrawDottedLineWithMode, DrawFrame, DrawDesignBox, ColorBlit2, UpdateScreen) with the
   queued thunks they post, and SetApTimer (ui/ui_widget_defs.s), the twin of the matched KillApTimer.
   On the draw task's own stack (IS_XSP_INSIDE_4K_REGION_AT_1C032 != 0) a wrapper draws at once (when DRAW_ENABLED);
   from any other task it fills a DrawQueue_Alloc entry {thunk, arguments} and posts it with DrawRing_Post.
   The 32-character callee name goes through a cc900-name alias (run r33 could not resolve the cut name). */
/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-name: DrawBmpSPFast_DeferredCode=DrawBitmapSPFast_DeferredPath_Code */
/* cc900-name: DrawDottedLineMode_ParamBlock=DrawDottedLineWithMode_ParamBlock */
/* cc900-module: ClipBlit_Replace_Impl ColorBlit2_Impl DrawBitmapSPFast_Impl DrawDesignBox_Impl DrawDottedLineWithMode_Impl DrawFrame_Impl DrawIcons_Impl DrawQueue_Alloc DrawRing_Post Gfx_BlitDirtyRegions IS_XSP_INSIDE_4K_REGION_AT_1C032 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE;
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern int ram_30450;

extern void ClipBlit_Replace_Impl(struct pt *, int);
extern void DrawIcons_Impl(struct pt *, long);
extern void DrawBitmapSPFast_Impl(struct pt *, long, int, int);
extern void DrawDottedLineWithMode_Impl(struct pt *, struct pt *, int);
extern void DrawFrame_Impl(struct rect *, int);
extern void DrawDesignBox_Impl(struct rect *, int, int);
extern void ColorBlit2_Impl(struct rect *, int);
extern void Gfx_BlitDirtyRegions(void);

extern void ClipBlit_Replace_ParamBlock(unsigned char *q);
extern void DrawIcons_QueuedExec(unsigned char *q);
extern void DrawBmpSPFast_DeferredCode(unsigned char *q);
extern void DrawDottedLineMode_ParamBlock(unsigned char *q);
extern void DrawFrame_QueuedExec(unsigned char *q);
extern void DrawDesignBox_QueueCallback(unsigned char *q);
extern void ColorBlit2_CallbackBlock(unsigned char *q);
extern void UpdateScreen_CheckDirty(unsigned char *q);

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

void ClipBlit_Replace_ParamBlock(unsigned char *q)
{
	ClipBlit_Replace_Impl((struct pt *)(q + 4), *(int *)(q + 8));
}

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

void DrawIcons_QueuedExec(unsigned char *q)
{
	struct pt *p;
	long n;

	p = (struct pt *)(q + 4);
	n = *(long *)(q + 8);
	if (DRAW_ENABLED != 0)
		DrawIcons_Impl(p, n);
}

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

void DrawBmpSPFast_DeferredCode(unsigned char *q)
{
	struct pt *p;
	long b;
	int c;
	int d;

	p = (struct pt *)(q + 4);
	b = *(long *)(q + 8);
	c = *(int *)(q + 12);
	d = *(int *)(q + 14);
	if (DRAW_ENABLED != 0)
		DrawBitmapSPFast_Impl(p, b, c, d);
}

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

void DrawDottedLineMode_ParamBlock(unsigned char *q)
{
	struct pt *a;
	struct pt *b;
	int m;

	a = (struct pt *)(q + 4);
	b = (struct pt *)(q + 8);
	m = *(int *)(q + 12);
	COLORBLIT_MODE_ACTIVE = q[14];
	if (DRAW_ENABLED != 0)
		DrawDottedLineWithMode_Impl(a, b, m);
}

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

void DrawFrame_QueuedExec(unsigned char *q)
{
	struct rect *r;
	int n;

	r = (struct rect *)(q + 4);
	n = *(int *)(q + 12);
	if (DRAW_ENABLED != 0)
		DrawFrame_Impl(r, n);
}

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

void DrawDesignBox_QueueCallback(unsigned char *q)
{
	struct rect *r;
	int a;
	int b;

	r = (struct rect *)(q + 4);
	a = *(int *)(q + 12);
	b = *(int *)(q + 14);
	if (DRAW_ENABLED != 0)
		DrawDesignBox_Impl(r, a, b);
}

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

void ColorBlit2_CallbackBlock(unsigned char *q)
{
	struct rect *r;
	int n;

	r = (struct rect *)(q + 4);
	n = *(int *)(q + 12);
	COLORBLIT_MODE_ACTIVE = q[14];
	if (DRAW_ENABLED != 0)
		ColorBlit2_Impl(r, n);
}

void UpdateScreen(void)
{
	unsigned char *q;

	if (IsXspInDrawStack() != 0) {
		Gfx_BlitDirtyRegions();
		if (ram_30450 == 0)
			DRAW_ENABLED = 0;
	} else {
		q = DrawQueue_Alloc(4);
		*(void **)q = (void *)UpdateScreen_CheckDirty;
		DrawRing_Post(q);
	}
}

void UpdateScreen_CheckDirty(unsigned char *q)
{
	Gfx_BlitDirtyRegions();
	if (ram_30450 == 0)
		DRAW_ENABLED = 0;
}

/* SetApTimer: the first free slot (obj == -1) of the 128 application timers takes the new timer, which is linked
   into the list at ram_30448 ordered by expiry time; with no free slot it hangs.  Locals as the ROM keeps them:
   i in BC (unsigned: extz + shift-add * 24), the table base spilled to the frame. */
struct apt { int prev; int next; unsigned long time; long obj; long target; long event; long param; };
extern struct apt ram_2f844[];
extern unsigned long ram_30444;
extern int ram_30448;
#define APT(n) ((struct apt *)((char *)ram_2f844 + (n) * 24))

void SetApTimer(unsigned long time, long obj, long target, long event, long param)
{
	unsigned int i;
	int prev;
	int cur;
	struct apt *t;
	struct apt *u;

	for (i = 0; i < 128; i++) {
		t = &ram_2f844[i];
		if (t->obj == -1) {
			t->time = ram_30444 + time;
			t->obj = obj;
			t->target = target;
			t->event = event;
			t->param = param;
			cur = ram_30448;
			if (cur == -1) {
				ram_30448 = i;
				break;
			}
			prev = -1;
			while ((u = APT(cur))->time <= t->time) {
				prev = cur;
				cur = u->next;
				if (cur == -1)
					break;
			}
			t->prev = prev;
			t->next = cur;
			if (prev != -1)
				APT(prev)->next = i;
			if (cur != -1)
				APT(cur)->prev = i;
			if (cur == ram_30448)
				ram_30448 = i;
			break;
		}
	}
	if (i == 128)
		for (;;)
			;
}
