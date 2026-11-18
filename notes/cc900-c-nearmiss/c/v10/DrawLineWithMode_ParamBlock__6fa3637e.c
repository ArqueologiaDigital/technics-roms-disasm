/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m273a.c (2026-11-18-12-p6-r35)
   sha256 6fa3637e333b6b6b507de0c084754c41e66a8f074d4f63dc29f857986e6eb4b8 (tar-sha256); compiled at -O3 -XS -Xr */
struct pt { int x, y; };
extern int DRAW_ENABLED;
extern unsigned char COLORBLIT_MODE_ACTIVE;
struct lmcmd { void (*fn)(struct lmcmd *); struct pt a; struct pt b; int c; unsigned char mode; };
extern void DrawLineWithMode_Impl(struct pt *, struct pt *, int);
void DrawLineWithMode_ParamBlock(struct lmcmd *q)
{
	struct pt *a = &q->a;
	struct pt *b = &q->b;
	int c = q->c;

	COLORBLIT_MODE_ACTIVE = q->mode;
	if (DRAW_ENABLED != 0)
		DrawLineWithMode_Impl(a, b, c);
}
