/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_M_1m273a.c (2026-11-19-13-p6-r41)
   sha256 f40c01f97f71fab2d231354e5451dd9ea490a9cf86d312b41e5ca413bf477718 (tar-sha256); compiled at -O3 -XS -Xr */
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
