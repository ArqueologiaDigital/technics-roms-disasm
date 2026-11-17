/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_13m265b.c (2026-11-16-128-p6-r27)
   sha256 08f7d69588db5c3256c811087e393cbb324d080a87aecef06095474575f114df (tar-sha256); compiled at -O3 -Xr */
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
