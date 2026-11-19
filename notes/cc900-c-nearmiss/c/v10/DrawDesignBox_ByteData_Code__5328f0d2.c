/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_L_1m273a.c (2026-11-19-15-p6-r42)
   sha256 5328f0d2d1a9d1dbc8810ab857321ed3512d2cc9fe4fec68a0cf317646fb7158 (tar-sha256); compiled at -O3 -XS -Xr */
struct pt { int x, y; };
extern int DRAW_ENABLED;
struct ddcmd { void (*fn)(struct ddcmd *); struct pt a; struct pt b; int c; };
extern void DrawDottedLine_Impl(struct pt *, struct pt *, int);
void DrawDesignBox_ByteData_Code(struct ddcmd *q)
{
	struct pt *a = &q->a;
	struct pt *b = &q->b;
	int c = q->c;

	if (DRAW_ENABLED != 0)
		DrawDottedLine_Impl(a, b, c);
}
