/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_K_1m273a.c (2026-11-18-12-p6-r35)
   sha256 6fa3637e333b6b6b507de0c084754c41e66a8f074d4f63dc29f857986e6eb4b8 (tar-sha256); compiled at -O3 -XS -Xr */
struct pt { int x, y; };
extern int DRAW_ENABLED;
struct dfcmd { void (*fn)(struct dfcmd *); struct pt p; int b; int c; };
extern void DrawFrameSP_Impl(struct pt *, int, int);
void DrawFrameSP_QueuedExec(struct dfcmd *q)
{
	struct pt *p = &q->p;
	int b = q->b;
	int c = q->c;

	if (DRAW_ENABLED != 0)
		DrawFrameSP_Impl(p, b, c);
}
