/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/drawing_primitives_m273.c (2026-11-18-28-p6-r36)
   sha256 3cd8a79d1347281f0d4750a4952b700028d8d9e18a624b59329febbf03fe1725 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
struct rect { int x0, y0, x1, y1; };
extern void DrawFrame_Impl(struct rect *, int);
extern void DrawFrame_QueuedExec(unsigned char *q);
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
