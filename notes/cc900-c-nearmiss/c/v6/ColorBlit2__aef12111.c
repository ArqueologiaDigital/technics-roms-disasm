/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/ui_window_procs_m273.c (2026-11-18-28-p6-r36)
   sha256 aef1211117a3ec94925755b0307806a542d2fb02afda4d6ae73d44578cd99b3d (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE;
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern void ColorBlit2_Impl(struct rect *, int);
extern void ColorBlit2_CallbackBlock(unsigned char *q);
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
