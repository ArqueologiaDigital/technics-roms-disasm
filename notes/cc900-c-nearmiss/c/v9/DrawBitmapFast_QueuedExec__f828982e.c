/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/drawing_primitives_m0_xr.c (2026-11-18-28-p6-r36)
   sha256 f828982eb48156698c12515b2d04f2bd4eea3641c473bc22e492b8400c15bad9 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -Xr */
extern int DRAW_ENABLED;
struct pt { int x, y; };
struct bfcmd { void (*fn)(struct bfcmd *); struct pt p; unsigned char *bmp; };
extern void DrawBitmapFast_Impl(struct pt *, unsigned char *);
void DrawBitmapFast_QueuedExec(struct bfcmd *q)
{
	struct pt *p = &q->p;
	unsigned char *bmp = q->bmp;

	if (DRAW_ENABLED != 0)
		DrawBitmapFast_Impl(p, bmp);
}
