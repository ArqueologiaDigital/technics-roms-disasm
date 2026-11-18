/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_J_1m273b.c (2026-11-18-12-p6-r35)
   sha256 609aa860dafa55d0054032d8040501bfeacaf6f522408b994773e0ec4fdeb5b1 (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, lane_p6 helper J, round 1, module 273, form b: the same routines as p6_J_1m273a.c with other
   spellings -- the queue entry as a typed struct (q->p = *p instead of casts on q + 4), SetApTimer with `continue`
   and the timers indexed as &ram_2f844[cur], UpdateScreen storing the zero it just read. */
/* cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-name: DrawBmpSPFast_DeferredCode=DrawBitmapSPFast_DeferredPath_Code */
/* cc900-name: DrawDottedLineMode_ParamBlock=DrawDottedLineWithMode_ParamBlock */
/* cc900-module: ClipBlit_Replace_Impl ColorBlit2_Impl DrawBitmapSPFast_Impl DrawDesignBox_Impl DrawDottedLineWithMode_Impl DrawFrame_Impl DrawIcons_Impl DrawQueue_Alloc DrawRing_Post Gfx_BlitDirtyRegions IS_XSP_INSIDE_4K_REGION_AT_1C032 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };

struct cmd_pt_i { void *fn; struct pt p; int n; };
struct cmd_pt_l { void *fn; struct pt p; long n; };
struct cmd_pt_lii { void *fn; struct pt p; long b; int c; int d; };
struct cmd_pt_pt { void *fn; struct pt a; struct pt b; int m; unsigned char mode; unsigned char pad; };
struct cmd_r_i { void *fn; struct rect r; int n; };
struct cmd_r_ii { void *fn; struct rect r; int a; int b; };
struct cmd_r_im { void *fn; struct rect r; int n; unsigned char mode; unsigned char pad; };

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

extern void ClipBlit_Replace_ParamBlock(struct cmd_pt_i *q);
extern void DrawIcons_QueuedExec(struct cmd_pt_l *q);
extern void DrawBmpSPFast_DeferredCode(struct cmd_pt_lii *q);
extern void DrawDottedLineMode_ParamBlock(struct cmd_pt_pt *q);
extern void DrawFrame_QueuedExec(struct cmd_r_i *q);
extern void DrawDesignBox_QueueCallback(struct cmd_r_ii *q);
extern void ColorBlit2_CallbackBlock(struct cmd_r_im *q);
extern void UpdateScreen_CheckDirty(void *q);

void ClipBlit_Replace(struct pt *p, int n)
{
	struct cmd_pt_i *q;

	if (IsXspInDrawStack() != 0)
		ClipBlit_Replace_Impl(p, n);
	else {
		q = (struct cmd_pt_i *)DrawQueue_Alloc(10);
		q->fn = (void *)ClipBlit_Replace_ParamBlock;
		q->p = *p;
		q->n = n;
		DrawRing_Post(q);
	}
}

void ClipBlit_Replace_ParamBlock(struct cmd_pt_i *q)
{
	ClipBlit_Replace_Impl(&q->p, q->n);
}

void DrawIcons(struct pt *p, long n)
{
	struct cmd_pt_l *q;

	if (IsXspInDrawStack() != 0) {
		if (DRAW_ENABLED != 0)
			DrawIcons_Impl(p, n);
	} else {
		q = (struct cmd_pt_l *)DrawQueue_Alloc(12);
		q->fn = (void *)DrawIcons_QueuedExec;
		q->p = *p;
		q->n = n;
		DrawRing_Post(q);
	}
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

void DrawBitmapSPFast(struct pt *p, long b, int c, int d)
{
	struct cmd_pt_lii *q;

	if (IsXspInDrawStack() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmapSPFast_Impl(p, b, c, d);
	} else {
		q = (struct cmd_pt_lii *)DrawQueue_Alloc(16);
		q->fn = (void *)DrawBmpSPFast_DeferredCode;
		q->p = *p;
		q->b = b;
		q->c = c;
		q->d = d;
		DrawRing_Post(q);
	}
}

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

void DrawDottedLineWithMode(struct pt *a, struct pt *b, int m)
{
	struct cmd_pt_pt *q;

	if (IsXspInDrawStack() != 0) {
		COLORBLIT_MODE_ACTIVE = COLORBLIT_MODE;
		if (DRAW_ENABLED != 0)
			DrawDottedLineWithMode_Impl(a, b, m);
	} else {
		q = (struct cmd_pt_pt *)DrawQueue_Alloc(16);
		q->fn = (void *)DrawDottedLineMode_ParamBlock;
		q->a = *a;
		q->b = *b;
		q->m = m;
		q->mode = COLORBLIT_MODE;
		DrawRing_Post(q);
	}
}

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

void DrawFrame(struct rect *r, int n)
{
	struct cmd_r_i *q;

	if (IsXspInDrawStack() != 0) {
		if (DRAW_ENABLED != 0)
			DrawFrame_Impl(r, n);
	} else {
		q = (struct cmd_r_i *)DrawQueue_Alloc(14);
		q->fn = (void *)DrawFrame_QueuedExec;
		q->r = *r;
		q->n = n;
		DrawRing_Post(q);
	}
}

void DrawFrame_QueuedExec(struct cmd_r_i *q)
{
	struct rect *r;
	int n;

	r = &q->r;
	n = q->n;
	if (DRAW_ENABLED != 0)
		DrawFrame_Impl(r, n);
}

void DrawDesignBox(struct rect *r, int a, int b)
{
	struct cmd_r_ii *q;

	if (IsXspInDrawStack() != 0) {
		if (DRAW_ENABLED != 0)
			DrawDesignBox_Impl(r, a, b);
	} else {
		q = (struct cmd_r_ii *)DrawQueue_Alloc(16);
		q->fn = (void *)DrawDesignBox_QueueCallback;
		q->r = *r;
		q->a = a;
		q->b = b;
		DrawRing_Post(q);
	}
}

void DrawDesignBox_QueueCallback(struct cmd_r_ii *q)
{
	struct rect *r;
	int a;
	int b;

	r = &q->r;
	a = q->a;
	b = q->b;
	if (DRAW_ENABLED != 0)
		DrawDesignBox_Impl(r, a, b);
}

void ColorBlit2(struct rect *r, int n)
{
	struct cmd_r_im *q;

	if (IsXspInDrawStack() != 0) {
		COLORBLIT_MODE_ACTIVE = COLORBLIT_MODE;
		if (DRAW_ENABLED != 0)
			ColorBlit2_Impl(r, n);
	} else {
		q = (struct cmd_r_im *)DrawQueue_Alloc(16);
		q->fn = (void *)ColorBlit2_CallbackBlock;
		q->r = *r;
		q->n = n;
		q->mode = COLORBLIT_MODE;
		DrawRing_Post(q);
	}
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

void UpdateScreen(void)
{
	void **q;

	if (IsXspInDrawStack() != 0) {
		Gfx_BlitDirtyRegions();
		if (ram_30450 == 0)
			DRAW_ENABLED = ram_30450;
	} else {
		q = (void **)DrawQueue_Alloc(4);
		*q = (void *)UpdateScreen_CheckDirty;
		DrawRing_Post(q);
	}
}

void UpdateScreen_CheckDirty(void *q)
{
	Gfx_BlitDirtyRegions();
	if (ram_30450 == 0)
		DRAW_ENABLED = ram_30450;
}

struct apt { int prev; int next; unsigned long time; long obj; long target; long event; long param; };
extern struct apt ram_2f844[];
extern unsigned long ram_30444;
extern int ram_30448;

void SetApTimer(unsigned long time, long obj, long target, long event, long param)
{
	unsigned int i;
	int prev;
	int cur;
	struct apt *t;
	struct apt *u;

	for (i = 0; i < 128; i++) {
		t = &ram_2f844[i];
		if (t->obj != -1)
			continue;
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
		while ((u = &ram_2f844[cur])->time <= t->time) {
			prev = cur;
			cur = u->next;
			if (cur == -1)
				break;
		}
		t->prev = prev;
		t->next = cur;
		if (prev != -1)
			ram_2f844[prev].next = i;
		if (cur != -1)
			ram_2f844[cur].prev = i;
		if (cur == ram_30448)
			ram_30448 = i;
		break;
	}
	if (i == 128)
		for (;;)
			;
}
