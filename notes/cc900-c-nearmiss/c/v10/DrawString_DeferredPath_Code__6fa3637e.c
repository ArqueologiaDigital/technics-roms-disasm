/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m273a.c (2026-11-18-12-p6-r35)
   sha256 6fa3637e333b6b6b507de0c084754c41e66a8f074d4f63dc29f857986e6eb4b8 (tar-sha256); compiled at -O3 -XS -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void DrawFunc_Return(void *p);
extern int DRAW_ENABLED;
struct dscmd { void (*fn)(struct dscmd *); struct rect r; struct pt p; char *s; long font; int a; int b; };
extern void DrawString_Impl(struct rect *, struct pt *, char *, long, int, int);
void DrawString_DeferredPath_Code(struct dscmd *q)
{
	struct rect *r = &q->r;
	struct pt *p = &q->p;
	long font = q->font;
	int a = q->a;
	int b = q->b;

	if (DRAW_ENABLED != 0)
		DrawString_Impl(r, p, q->s, font, a, b);
	DrawFunc_Return(q->s);
}
