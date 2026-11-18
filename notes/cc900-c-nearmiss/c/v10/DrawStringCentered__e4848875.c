/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_I_2m273b.c (2026-11-18-28-p6-r36)
   sha256 e48488755f4f1826736dee4a80233cd2c5b900efea5876bc54593d34510f54b8 (tar-sha256); compiled at -O3 -Xr */
struct pt { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern void ConvertStrings(char *src, char *dst);
extern int CalcTotalWidth(char *s, long font);
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int GetCenteredDelta(long);
extern void DrawString(struct rect *, struct pt *, char *, long, int, int);
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
