/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_7m265a.c (2026-11-16-100-p6-r19)
   sha256 6635aad8f8b5d142e3e884cb9d5361fb7eb6c0b1768f4c1e677eb539c459c83f (tar-sha256); compiled at -O3 -Xr */
struct fdlay { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern struct fdlay ram_25b3a;
extern long ram_25b40[];
extern int ram_25b3e;
extern int ram_25b60;
extern int ram_25b62[];
extern int ram_25b72;
extern unsigned char ram_25b74[];
#define CUR_FONT (*(long *)((char *)ram_25b40 + ram_25b3e * 4))
#define CUR_COLOR (*(int *)((char *)ram_25b62 + ram_25b60 * 2))
#define CUR_ALIGN (*((unsigned char *)ram_25b74 + ram_25b72))
extern struct rect FDemoText_ScreenClipRect;
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int __cdecl Strlen(char *);
extern unsigned char *__cdecl Malloc(unsigned int);
extern char *__cdecl Strcpy(char *, char *);
extern void __cdecl Free(void *);
extern int FDemoText_CalcTextExtent(struct fdlay *);
extern int WordwrapStrings(char *, long, int);
extern int CalcTotalWidth(char *, long);
extern void DrawString(struct rect *, struct fdlay *, char *, long, int, int);
extern int FDemoText_UpdateCursorPosition(void);
void FDemoText_RenderTextLine(char *s)
{
    struct rect clip;
    struct fdlay pos;
    char *buf;
    int ext;
    int width;
    char *line;
    char *end;
    int wrapped;
    int h, len, n, d;

    clip = FDemoText_ScreenClipRect;
    h = GetCharHeight(CUR_FONT);
    h -= GetCharDescent(CUR_FONT);
    d = ram_25b3a.y - h;
    if (d < 0) {
        d = -d;
        ram_25b3a.y += (d + 3) / 4 * 4;
    }
    pos = ram_25b3a;
    pos.y -= h;
    len = Strlen(s);
    buf = (char *)Malloc(len + 1);
    Strcpy(buf, s);
    line = buf;
    ext = FDemoText_CalcTextExtent(&pos);
    n = WordwrapStrings(buf, CUR_FONT, ext);
    if (n != len) {
        wrapped = 1;
        end = buf + n - 1;
        if (n != 0)
            *end = 0;
    } else
        wrapped = 0;
    width = CalcTotalWidth(line, CUR_FONT);
    if (n != 0) {
        switch (CUR_ALIGN) {
        case 0:
            pos.x = ext / 2 + pos.x - width / 2;
            break;
        case 1:
            break;
        case 2:
            pos.x = pos.x + ext - width;
            break;
        }
        DrawString(&clip, &pos, buf, CUR_FONT, CUR_COLOR, 0xf7);
    }
    ram_25b3a.x = pos.x + width;
    if (wrapped != 0 && FDemoText_UpdateCursorPosition() != 0)
        FDemoText_RenderTextLine(end + 1);
    Free(buf);
}
