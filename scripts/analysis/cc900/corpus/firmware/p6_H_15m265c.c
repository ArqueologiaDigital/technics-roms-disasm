/* Form c: no dead store; h instead gets its first value in its declaration (an initialised local may be counted or
   ordered differently in the home contest).
   lane_p6 helper H, round 15, module 265 (demo/fdemotext_routines.s), form a: FDemoText_ByteData_LayoutB from round 14
   form a (sized tables, direct subscripts: the font index now matches; RenderTextLine matched with the same
   spelling).  Left: the node pointer still wins XIZ against h (run 2026-11-17-2: push XIZ; the ROM saves only IZ
   and keeps node at +4).  In rounds 4-14 h won only once (round 4 form b, 6 uses of h, node declared before w).
   Here: a dead `node = 0;` at the top lengthens node's live range from the start of the function (V4.23's home
   priority looks like uses / range; the store itself is dead and should be dropped at -O3). */
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
    int w;
    struct fdnode *node;
    int h = GetCharHeight(ram_25b40[ram_25b3e]);
    int d, ext;

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
