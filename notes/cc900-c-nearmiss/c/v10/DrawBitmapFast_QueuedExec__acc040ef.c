/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m273b.c (2026-11-18-12-p6-r35)
   sha256 acc040ef3de2958bb52b1c846bb6623907e6e98f4e295c697226fda8148f4174 (tar-sha256); compiled at -Xr */
struct pt { int x, y; };
extern int DRAW_ENABLED;
struct bfcmd { void (*fn)(struct bfcmd *); struct pt p; unsigned char *bmp; };
extern void DrawBitmapFast_Impl(struct pt *, unsigned char *);
void DrawBitmapFast_QueuedExec(struct bfcmd *q)
{
	if (DRAW_ENABLED != 0)
		DrawBitmapFast_Impl(&q->p, q->bmp);
}
