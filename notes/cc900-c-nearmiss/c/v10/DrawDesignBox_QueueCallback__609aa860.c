/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m273b.c (2026-11-18-12-p6-r35)
   sha256 609aa860dafa55d0054032d8040501bfeacaf6f522408b994773e0ec4fdeb5b1 (tar-sha256); compiled at -O3 -XS -Xr */
struct rect { int x0, y0, x1, y1; };
struct cmd_r_ii { void *fn; struct rect r; int a; int b; };
extern int DRAW_ENABLED;
extern void DrawDesignBox_Impl(struct rect *, int, int);
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
