/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_3m273a.c (2026-11-18-28-p6-r36)
   sha256 29e0522972afa8c0c1e59b09a3ca6d74e13a4dfb7e65a5e5f705089e6866a92e (tar-sha256); compiled at -O3 -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void ConvertStrings(char *src, char *dst);
extern int CalcTotalWidth(char *, long);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
void DrawStringRightJustify(struct rect *r, struct pt *p, char *s, long font, int a, int b)
{
	int w;
	int h;
	int d;
	struct pt at;
	char buf[256];

	ConvertStrings(s, buf);
	w = CalcTotalWidth(buf, font);
	h = GetCharHeight(font);
	d = GetCharDescent(font);
	at = *p;
	at.x = r->x1 - 4 - w;
	at.y -= (h - d) / 2;
	at.y += GetCenteredDelta(font);
	DrawString(r, &at, buf, font, a, b);
}
