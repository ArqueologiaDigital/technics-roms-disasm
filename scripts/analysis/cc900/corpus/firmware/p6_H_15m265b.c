/* lane_p6 helper H, round 15, module 265 (demo/fdemotext_routines.s), form b: FDemoText_ByteData_LayoutB as round 14
   form a, with node declared BEFORE w, as in round 4 form b (the only form where h won IZ at -O3 -Xr).  If h wins
   here, declaration order decides the home contest; the slots then come out node +2 / w +6 (the ROM has w +2 /
   node +4), which a later round has to square. */
/* cc900-module: FDemoText_CalcTextExtent FDemo_LinkedListSearchInsert */

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
    struct fdnode *node;
    int w;
    int h;
    int d, ext;

    h = GetCharHeight(ram_25b40[ram_25b3e]);
    h -= GetCharDescent(ram_25b40[ram_25b3e]);
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
