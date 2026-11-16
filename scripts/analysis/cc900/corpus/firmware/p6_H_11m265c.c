/* lane_p6 helper H, round 11, module 265 (demo/fdemotext_routines.s), form c.
   FDemoText_SendExtVoiceParams: resent unchanged from round 7.
   FDemoText_ByteData_LayoutB: round 10 form a's separate locals (w before node for the ROM's slots), with the
   node pointer's address taken in a statement that computes nothing, to see whether an address-taken local is
   barred from the homes (then h alone takes IZ); font index through a local as in form a. */
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

void FDemoText_ByteData_LayoutB(char *name)
{
    struct fdlay pos;
    int w;
    struct fdnode *node;
    int h;
    int i, d, ext;

    (void)&node;
    i = ram_25b3e << 2;
    h = GetCharHeight(*(long *)((char *)ram_25b40 + i));
    i = ram_25b3e << 2;
    h -= GetCharDescent(*(long *)((char *)ram_25b40 + i));
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

extern void DemoDesc_BuildCompactParams(unsigned char *);
extern void sendCOMM(int, int, unsigned char *);
extern void VoiceEvent_FlushAndReturn(int, int);

void FDemoText_SendExtVoiceParams(unsigned char part)
{
    unsigned char msg[6];
    unsigned char params[10];
    unsigned char *p;
    unsigned char k;

    p = params;
    DemoDesc_BuildCompactParams(p);
    msg[0] = 0xb0;
    msg[1] = part;
    msg[2] = 0x78;
    msg[3] = 0;
    sendCOMM(0, 4, msg);
    msg[0] = 0x88;
    msg[1] = part;
    msg[3] = 0;
    msg[5] = 0;
    for (k = 11; k <= 12; k++) {
        msg[2] = k;
        msg[4] = *p;
        sendCOMM(0, 6, msg);
        p++;
    }
    for (k = 4; k <= 8; k++) {
        msg[2] = k;
        msg[4] = *p;
        sendCOMM(0, 6, msg);
        p++;
    }
    VoiceEvent_FlushAndReturn(0xff, part);
}
