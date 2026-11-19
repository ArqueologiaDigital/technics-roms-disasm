/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_3m273b.c (2026-11-19-6-p6-r39)
   sha256 c8b4b29f87568edbf76f10d1dab7e78f54b09c9f7250d59c1e1d65851334f8c5 (tar-sha256); compiled at -O3 -XS -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void ConvertStrings(char *src, char *dst);
extern int CalcTotalWidth(char *s, long font);
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
    s = buf;
    DrawString(r, &at, s, font, a, b);
}
