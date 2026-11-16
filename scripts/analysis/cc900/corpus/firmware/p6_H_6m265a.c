/* lane_p6 helper H, round 6, module 265 (demo/fdemotext_routines.s), form a: FDemoText_ByteData_LayoutB refined
   from run 87 (r15 form b): the width local declared before the node pointer (stack slots), signed int indexes
   read as `(char *)base + i * size` (the ROM's sla + (xbc+wa)), and the y difference negated in place. */
/* cc900-module: FDemoText_CalcTextExtent FDemo_LinkedListSearchInsert */

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
#define CUR_FONT (*(long *)((char *)ram_25b40 + ram_25b3e * 4))

void FDemoText_ByteData_LayoutB(char *name)
{
    struct fdlay pos;
    int w;
    struct fdnode *node;
    int h, d, ext;

    h = GetCharHeight(CUR_FONT);
    h -= GetCharDescent(CUR_FONT);
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
