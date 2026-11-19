/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_P_3m273a.c (2026-11-19-6-p6-r39)
   sha256 5b246f39cc3e8516f6b0645f5b10e195a54e6ba6d3afeb6fc6a84a376898177e (tar-sha256); compiled at -O3 -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void ConvertStrings(char *src, char *dst);
extern int CalcTotalWidth(char *s, long font);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);
extern void DrawString();
void DrawStringCentered(struct rect *clip, struct pt *pos, char *s, long font, int fg, int bg)
{
    struct pt pt;
    char buf[256];
    int h;
    int w;
    int d;

    ConvertStrings(s, buf);
    w = CalcTotalWidth(buf, font);
    h = GetCharHeight(font);
    d = GetCharDescent(font);
    pt = *pos;
    pt.x -= w / 2;
    pt.y -= (h - d) / 2;
    pt.y += GetCenteredDelta(font);
    DrawString(clip, &pt, buf, font, fg, bg);
}
