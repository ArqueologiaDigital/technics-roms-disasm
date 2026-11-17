/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_14m265b.c (2026-11-17-2-p6-r29)
   sha256 41a9f97a08d4565480bffdcf1e37a80243388e0ccffaef692c3f5da070e1544d (tar-sha256); compiled at -O3 -Xr */
struct fdlay { int x, y; };
extern struct fdlay ram_25b3a;
extern long ram_25b40[8];
extern int ram_25b3e;
extern int ram_25b72;
extern unsigned char ram_25b74[8];
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int FDemoText_CalcTextExtent(struct fdlay *);
struct rect { int x0, y0, x1, y1; };
extern int ram_25b60;
extern int ram_25b62[8];
extern struct rect FDemoText_ScreenClipRect;
extern int __cdecl Strlen(char *);
extern unsigned char *__cdecl Malloc(unsigned int);
extern char *__cdecl Strcpy(char *, char *);
extern void __cdecl Free(void *);
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
    h = GetCharHeight(ram_25b40[ram_25b3e]);
    h -= GetCharDescent(ram_25b40[ram_25b3e]);
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
    n = WordwrapStrings(buf, ram_25b40[ram_25b3e], ext);
    if (n != len) {
        wrapped = 1;
        end = buf + n - 1;
        if (n != 0)
            *end = 0;
    } else
        wrapped = 0;
    width = CalcTotalWidth(line, ram_25b40[ram_25b3e]);
    if (n != 0) {
        switch (*((unsigned char *)ram_25b74 + ram_25b72)) {
        case 0:
            pos.x = ext / 2 + pos.x - width / 2;
            break;
        case 1:
            break;
        case 2:
            pos.x = pos.x + ext - width;
            break;
        }
        DrawString((struct rect *)&clip.x0, (struct fdlay *)&pos.x, buf, ram_25b40[ram_25b3e],
                   ram_25b62[ram_25b60], 0xf7);
    }
    ram_25b3a.x = pos.x + width;
    if (wrapped != 0 && FDemoText_UpdateCursorPosition() != 0)
        FDemoText_RenderTextLine(end + 1);
    Free(buf);
}
