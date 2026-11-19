/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m273a.c (2026-11-19-15-p6-r42)
   sha256 5328f0d2d1a9d1dbc8810ab857321ed3512d2cc9fe4fec68a0cf317646fb7158 (tar-sha256); compiled at -O3 -XS -Xr */
struct pt { int x, y; };
extern int DRAW_ENABLED;
struct bfcmd { void (*fn)(struct bfcmd *); struct pt p; long b; };
extern void DrawBitmapFile_Impl(struct pt *, long);
void DrawBitmapFile_QueuedExec(struct bfcmd *q)
{
	struct pt *p = &q->p;
	long b = q->b;

	if (DRAW_ENABLED != 0)
		DrawBitmapFile_Impl(p, b);
}
