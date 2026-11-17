/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_H_14m265c.c (2026-11-17-2-p6-r29)
   sha256 2c70ce3bacfe3e75d9e9de335d5c0366c710ebe58fecf076326fc88ede30d07b (tar-sha256); compiled at -O3 -Xr */
struct fdlay { int x, y; };
struct bih { long size; long width; };
struct fdnode { char name[16]; unsigned char *bm; };
struct fdbm { int w; struct fdnode *node; };
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
    struct fdbm b;
    int h;
    int i, d, ext;

    i = ram_25b3e;
    h = GetCharHeight(ram_25b40[i]);
    i = ram_25b3e;
    h -= GetCharDescent(ram_25b40[i]);
    d = ram_25b3a.y - h;
    if (d < 0) {
        d = -d;
        ram_25b3a.y += (d + 3) / 4 * 4;
    }
    b.node = FDemo_LinkedListSearchInsert(name);
    if (b.node != 0)
        b.w = (int)((struct bih *)(b.node->bm + 14))->width;
    else
        b.w = 24;
    pos = ram_25b3a;
    pos.y -= h;
    ext = FDemoText_CalcTextExtent(&pos);
    switch (*((unsigned char *)ram_25b74 + ram_25b72)) {
    case 0:
        pos.x = ext / 2 + pos.x - b.w / 2;
        break;
    case 1:
        break;
    case 2:
        pos.x = pos.x + ext - b.w;
        break;
    }
    if (b.node != 0)
        DrawBitmapFile(&pos, b.node->bm);
    else
        DrawBitmap(&pos, 0);
    ram_25b3a.x = pos.x + b.w;
}
