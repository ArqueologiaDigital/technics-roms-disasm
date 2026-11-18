/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/ui_window_procs_m273.c (2026-11-18-28-p6-r36)
   sha256 aef1211117a3ec94925755b0307806a542d2fb02afda4d6ae73d44578cd99b3d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsDrawTask=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE;
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern int IsDrawTask(void);
struct cbcmd { void (*fn)(struct cbcmd *); struct rect r; int c; unsigned char mode; };
extern void ColorBlit_Impl(struct rect *, int);
extern void ColorBlit_CallbackBlock(struct cbcmd *);
extern void ColorBlit_CallbackBlock(struct cbcmd *q);
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
