/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/drawing_primitives_m273.c (2026-11-18-28-p6-r36)
   sha256 3cd8a79d1347281f0d4750a4952b700028d8d9e18a624b59329febbf03fe1725 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: DrawBmpSPFast_DeferredCode=DrawBitmapSPFast_DeferredPath_Code
   cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern void DrawBitmapSPFast_Impl(struct pt *, long, int, int);
extern void DrawBmpSPFast_DeferredCode(unsigned char *q);
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
