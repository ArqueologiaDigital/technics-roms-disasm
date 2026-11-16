/* lane_p6 helper H, round 13, module 265 (demo/fdemotext_routines.s), form b: FDemoText_ByteData_LayoutB with the
   font index through an int local as in form a, but width and node pointer as separate locals whose addresses are
   taken in no-code statements (helper F, run 118: that keeps a value out of the homes, so h alone takes IZ).
   Address-taken locals get their slots in reverse declaration order, so pos, node, w is declared to give the ROM's
   w +2, node +4, pos +8. */
/* cc900-module: FDemoText_CalcTextExtent FDemoText_RenderTextLine FDemoText_UpdateCursorPosition FDemo_LinkedListSearchInsert */

struct fdlay { int x, y; };
struct bih { long size; long width; };
struct fdnode { char name[16]; unsigned char *bm; };
extern struct fdlay ram_25b3a;
extern long ram_25b40[];
extern int ram_25b3e;
extern int ram_25b72;
extern unsigned char ram_25b74[];
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern struct fdnode *FDemo_LinkedListSearchInsert(char *);
extern int FDemoText_CalcTextExtent(struct fdlay *);
extern void DrawBitmapFile(struct fdlay *, unsigned char *);
extern void DrawBitmap(struct fdlay *, unsigned char *);

void FDemoText_ByteData_LayoutB(char *name)
{
    struct fdlay pos;
    struct fdnode *node;
    int w;
    int h;
    int i, d, ext;

    (void)&node;
    (void)&w;
    i = ram_25b3e;
    h = GetCharHeight(ram_25b40[i]);
    i = ram_25b3e;
    h -= GetCharDescent(ram_25b40[i]);
    d = ram_25b3a.y - h;
    if (d < 0) {
        d = -d;
        ram_25b3a.y += (d + 3) / 4 * 4;
    }
    node = FDemo_LinkedListSearchInsert(name);
    if (node != 0)
        w = (int)((struct bih *)(node->bm + 14))->width;
    else
        w = 24;
    pos = ram_25b3a;
    pos.y -= h;
    ext = FDemoText_CalcTextExtent(&pos);
    switch (*((unsigned char *)ram_25b74 + ram_25b72)) {
    case 0:
        pos.x = ext / 2 + pos.x - w / 2;
        break;
    case 1:
        break;
    case 2:
        pos.x = pos.x + ext - w;
        break;
    }
    if (node != 0)
        DrawBitmapFile(&pos, node->bm);
    else
        DrawBitmap(&pos, 0);
    ram_25b3a.x = pos.x + w;
}

/* FDemoText_RenderTextLine: as form a. */
struct rect { int x0, y0, x1, y1; };
extern int ram_25b60;
extern int ram_25b62[];
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
    int h, len, n, d, i, j;

    clip = FDemoText_ScreenClipRect;
    i = ram_25b3e;
    h = GetCharHeight(ram_25b40[i]);
    i = ram_25b3e;
    h -= GetCharDescent(ram_25b40[i]);
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
    i = ram_25b3e;
    n = WordwrapStrings(buf, ram_25b40[i], ext);
    if (n != len) {
        wrapped = 1;
        end = buf + n - 1;
        if (n != 0)
            *end = 0;
    } else
        wrapped = 0;
    i = ram_25b3e;
    width = CalcTotalWidth(line, ram_25b40[i]);
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
        i = ram_25b3e;
        j = ram_25b60;
        DrawString((struct rect *)&clip.x0, (struct fdlay *)&pos.x, buf, ram_25b40[i], ram_25b62[j], 0xf7);
    }
    ram_25b3a.x = pos.x + width;
    if (wrapped != 0 && FDemoText_UpdateCursorPosition() != 0)
        FDemoText_RenderTextLine(end + 1);
    Free(buf);
}
