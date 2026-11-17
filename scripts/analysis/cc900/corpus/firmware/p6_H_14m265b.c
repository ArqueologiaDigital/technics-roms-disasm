/* Form b: as form a, plus a no-code self-assignment of h in LayoutB: if V4.23 counts uses for the IZ home before it
   drops the statement, h (5 uses, which lost to node in rounds 8-13) gets a sixth (6 won in round 4, form b).
   lane_p6 helper H, round 14, module 265 (demo/fdemotext_routines.s), form a.
   Run 128: the int index local was propagated back into the subscript (32-bit exts / sll form at Xr and O3Xr alike).
   The elrd probe that gives the ROM's 16-bit `ld WA,(cell) / sla 2,WA / lda XBC,base / ld XWA,(XBC+WA)` subscripts a
   SIZED array (hna[16]); the tree's tables are unsized here.  So the font and colour tables are declared with their
   size (8 entries each: ram_25b40 runs to ram_25b60, ram_25b62 to ram_25b72; FDemoText_ResetLayoutState fills 8),
   and subscripted with the cells directly.
   FDemoText_ByteData_LayoutB: plain locals, w before node (the ROM's slots w +2, node +4; run 128's form c shows the
   remaining home contest: node still takes XIZ).
   FDemoText_RenderTextLine: round 13's with direct subscripts (run 128: the index locals were loaded before
   DrawString's arguments; everything else up to the font index matched). */
/* cc900-module: FDemoText_CalcTextExtent FDemoText_RenderTextLine FDemoText_UpdateCursorPosition FDemo_LinkedListSearchInsert */

struct fdlay { int x, y; };
struct bih { long size; long width; };
struct fdnode { char name[16]; unsigned char *bm; };
extern struct fdlay ram_25b3a;
extern long ram_25b40[8];
extern int ram_25b3e;
extern int ram_25b72;
extern unsigned char ram_25b74[8];
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern struct fdnode *FDemo_LinkedListSearchInsert(char *);
extern int FDemoText_CalcTextExtent(struct fdlay *);
extern void DrawBitmapFile(struct fdlay *, unsigned char *);
extern void DrawBitmap(struct fdlay *, unsigned char *);

void FDemoText_ByteData_LayoutB(char *name)
{
    struct fdlay pos;
    int w;
    struct fdnode *node;
    int h;
    int d, ext;

    h = GetCharHeight(ram_25b40[ram_25b3e]);
    h -= GetCharDescent(ram_25b40[ram_25b3e]);
    h = h;
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
