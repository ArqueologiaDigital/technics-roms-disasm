/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/drawing_primitives_m0.c (2026-11-18-28-p6-r36)
   sha256 48e752fc37df044022acdc1ee921e9c1aacdd62e25f84226ff092a562a43c042 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pt { int x, y; };
extern int DRAW_ENABLED;
struct rect { int x0, y0, x1, y1; };
extern void DrawFunc_Return(void *p);
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
