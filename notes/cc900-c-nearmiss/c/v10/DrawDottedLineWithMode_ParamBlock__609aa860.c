/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_1m273b.c (2026-11-18-12-p6-r35)
   sha256 609aa860dafa55d0054032d8040501bfeacaf6f522408b994773e0ec4fdeb5b1 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-name: DrawDottedLineMode_ParamBlock=DrawDottedLineWithMode_ParamBlock */
struct pt { int x, y; };
struct cmd_pt_pt { void *fn; struct pt a; struct pt b; int m; unsigned char mode; unsigned char pad; };
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE_ACTIVE;
extern void DrawDottedLineWithMode_Impl(struct pt *, struct pt *, int);
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
