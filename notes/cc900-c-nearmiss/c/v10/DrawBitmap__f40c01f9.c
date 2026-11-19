/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of firmware/p6_M_1m273a.c (2026-11-19-13-p6-r41)
   sha256 f40c01f97f71fab2d231354e5451dd9ea490a9cf86d312b41e5ca413bf477718 (tar-sha256); compiled at -O3 -Xr */
/* Phase 6, lane_p6 helper M, round 1, module 273, form a.
   DrawBitmap and its queued executor DrawBitmap_QueuedExec (ui/drawing_primitives.s): the draw-queue family, exact
   twins of the built DrawBitmapFast (-O3 -Xr) and DrawBitmapFast_QueuedExec (-Xr) with DrawBitmap_Impl. */
/* cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
/* cc900-module: ColorBlit2 DrawBitmap_Impl DrawQueue_Alloc DrawRing_Post IS_XSP_INSIDE_4K_REGION_AT_1C032 */   /* scripts/analysis/cc900/module_calls.py v10 */

struct pt { int x, y; };
extern int IsDrawTask(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
struct bmcmd { void (*fn)(struct bmcmd *); struct pt p; unsigned char *bmp; };
extern void DrawBitmap_Impl(struct pt *, unsigned char *);
extern void DrawBitmap_QueuedExec(struct bmcmd *q);
extern void DrawBitmap(struct pt *p, unsigned char *bmp);

void DrawBitmap(struct pt *p, unsigned char *bmp)
{
	struct bmcmd *q;

	if (IsDrawTask() != 0) {
		if (DRAW_ENABLED != 0)
			DrawBitmap_Impl(p, bmp);
	} else {
		q = (struct bmcmd *)DrawQueue_Alloc(sizeof(struct bmcmd));
		q->fn = DrawBitmap_QueuedExec;
		q->p = *p;
		q->bmp = bmp;
		DrawRing_Post(q);
	}
}

void DrawBitmap_QueuedExec(struct bmcmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;

	if (DRAW_ENABLED != 0)
		DrawBitmap_Impl(p, bmp);
}

/* display/graphics_text_vga.s: the colour-blit ops.  A cell position pos (40 cells per row) and a size in cells
   become a pixel rectangle (x * 8, row) passed to ColorBlit2 with the background colour.  The op records are byte
   streams (a long at +7), so they are read through casts.  The ROM's remainder is V4.23's QDE / QBC after div. */
struct rect { int x0, y0, x1, y1; };
struct cent { unsigned int pos; unsigned int w; int h; };
struct csrc { int code; unsigned int pos; unsigned int w; int h; };
struct rop { int code; struct rect r; };
extern unsigned int GFX_BG_COLOR;
extern void ColorBlit2(struct rect *r, int n);
extern void ColorBlit_ComputeRectAndBlit(struct csrc *s);
extern void ColorBlit_ByteData(struct rop *p);
extern void ColorBlit_Variant_ByteData(unsigned char *p);
extern void SeGfx_BoundOp08_ColorBlit(unsigned char *p);

void ColorBlit_ComputeRectAndBlit(struct csrc *s)
{
	struct rect r;

	r.y0 = s->pos / 40;
	r.x0 = (s->pos % 40) * 8;
	r.y1 = r.y0 + s->h;
	r.x1 = r.x0 + s->w * 8;
	ColorBlit2(&r, GFX_BG_COLOR);
}

void ColorBlit_ByteData(struct rop *p)
{
	struct rect r;

	r.x0 = p->r.x0;
	r.y0 = p->r.y0;
	r.x1 = p->r.x1;
	r.y1 = p->r.y1;
	ColorBlit2(&r, GFX_BG_COLOR);
}

void ColorBlit_Variant_ByteData(unsigned char *p)
{
	struct rect r;
	unsigned char v;
	struct cent *e;

	v = *(unsigned char *)*(unsigned int *)(p + 2) & p[4];
	v >>= p[5] & 15;
	e = &(*(struct cent **)(p + 7))[v];
	r.y0 = e->pos / 40;
	r.x0 = (e->pos % 40) * 8;
	r.y1 = r.y0 + e->h;
	r.x1 = r.x0 + e->w * 8;
	ColorBlit2(&r, GFX_BG_COLOR);
}

void SeGfx_BoundOp08_ColorBlit(unsigned char *p)
{
	struct rect r;
	unsigned char v;
	struct rect *e;

	v = *(unsigned char *)*(unsigned int *)(p + 2) & p[4];
	v >>= p[5] & 15;
	e = &(*(struct rect **)(p + 7))[v];
	r.x0 = e->x0;
	r.y0 = e->y0;
	r.x1 = e->x1;
	r.y1 = e->y1;
	ColorBlit2(&r, GFX_BG_COLOR);
}
