/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m273a.c (2026-11-18-12-p6-r35)
   sha256 67745fa4f984377e224b8676d6fd4313c43623c5bb056a1cb7225a660dbf72ac (tar-sha256); compiled at -Xr */
struct rect { int x0, y0, x1, y1; };
extern int DRAW_ENABLED;
extern void DrawDesignBox_Impl(struct rect *, int, int);
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
