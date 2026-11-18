/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/drawing_primitives_m273.c (2026-11-18-28-p6-r36)
   sha256 3cd8a79d1347281f0d4750a4952b700028d8d9e18a624b59329febbf03fe1725 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr
   cc900-name: IsXspInDrawStack=IS_XSP_INSIDE_4K_REGION_AT_1C032 */
struct pt { int x, y; };
extern int IsXspInDrawStack(void);
extern unsigned char *DrawQueue_Alloc(unsigned int n);
extern void *DrawRing_Post(void *cmd);
extern int DRAW_ENABLED;
extern void DrawIcons_Impl(struct pt *, long);
extern void DrawIcons_QueuedExec(unsigned char *q);
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
