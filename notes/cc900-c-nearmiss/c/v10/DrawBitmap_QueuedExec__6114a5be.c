/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/drawing_primitives_m0.c (2026-11-19-15-p6-r42)
   sha256 6114a5be0f9bc520b86232cfc03e3ae585cddb2413b707f24a1f4404cf7038fe (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
struct pt { int x, y; };
extern int DRAW_ENABLED;
struct bmcmd { void (*fn)(struct bmcmd *); struct pt p; unsigned char *bmp; };
extern void DrawBitmap_Impl(struct pt *, unsigned char *);
void DrawBitmap_QueuedExec(struct bmcmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;

	if (DRAW_ENABLED != 0)
		DrawBitmap_Impl(p, bmp);
}
