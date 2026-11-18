/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m273a.c (2026-11-18-12-p6-r35)
   sha256 67745fa4f984377e224b8676d6fd4313c43623c5bb056a1cb7225a660dbf72ac (tar-sha256); compiled at -Xr
   cc900-name: DrawBmpSPFast_DeferredCode=DrawBitmapSPFast_DeferredPath_Code */
struct pt { int x, y; };
extern int DRAW_ENABLED;
extern void DrawBitmapSPFast_Impl(struct pt *, long, int, int);
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
