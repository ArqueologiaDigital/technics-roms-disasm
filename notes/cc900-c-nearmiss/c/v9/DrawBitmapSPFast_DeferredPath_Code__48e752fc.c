/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/drawing_primitives_m0.c (2026-11-18-28-p6-r36)
   sha256 48e752fc37df044022acdc1ee921e9c1aacdd62e25f84226ff092a562a43c042 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr
   cc900-name: DrawBmpSPFast_DeferredCode=DrawBitmapSPFast_DeferredPath_Code */
struct pt { int x, y; };
extern int DRAW_ENABLED;
struct cmd_pt_lii { void *fn; struct pt p; long b; int c; int d; };
extern void DrawBitmapSPFast_Impl(struct pt *, long, int, int);
void DrawBmpSPFast_DeferredCode(struct cmd_pt_lii *q)
{
	struct pt *p;
	long b;
	int c;
	int d;

	p = &q->p;
	b = q->b;
	c = q->c;
	d = q->d;
	if (DRAW_ENABLED != 0)
		DrawBitmapSPFast_Impl(p, b, c, d);
}
