/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/drawing_primitives_m273_b.c (2026-11-18-28-p6-r36)
   sha256 7c07b3353e23bec5bb82b73e0b0b6582284d4ca0f3166d146ef6413c0eb4c473 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
extern void DrawString(struct rect *r, struct pt *p, char *s, long font, int a, int b);
void DrawStringLeftJustify(struct rect *r, struct pt *p, char *s, long font, int a, int b)
{
	int h;
	int d;
	struct pt at;

	h = GetCharHeight(font);
	d = GetCharDescent(font);
	at = *p;
	at.x = r->x0 + 4;
	at.y -= (h - d) / 2;
	at.y += GetCenteredDelta(font);
	DrawString(r, &at, s, font, a, b);
}
