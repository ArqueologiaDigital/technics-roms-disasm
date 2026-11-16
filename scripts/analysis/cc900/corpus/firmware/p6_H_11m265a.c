/* lane_p6 helper H, round 11, module 265 (demo/fdemotext_routines.s), form a.
   FDemoText_SendExtVoiceParams: resent unchanged from round 7 (its listing was right; the translator gap
   `inc 1,QIZH` is fixed in a pending merge).
   FDemoText_ByteData_LayoutB from round 10 form a (the O3Xr listing matched the ROM everywhere but the homes): the
   width and the node pointer are now members of one local struct, so neither is a register candidate and h alone
   takes IZ (the ROM's 16-bit save); the struct lands at +2 (w) / +4 (node) below pos, declared first.  The font
   index is computed into a local first (the ROM's WA index, XBC base). */
/* cc900-module: FDemoText_CalcTextExtent FDemo_LinkedListSearchInsert */

struct fdlay { int x, y; };
struct bih { long size; long width; };
struct fdnode { char name[16]; unsigned char *bm; };
struct fdbm { int w; struct fdnode *node; };
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
    struct fdbm b;
    int h;
    int i, d, ext;

    i = ram_25b3e << 2;
    h = GetCharHeight(*(long *)((char *)ram_25b40 + i));
    i = ram_25b3e << 2;
    h -= GetCharDescent(*(long *)((char *)ram_25b40 + i));
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
