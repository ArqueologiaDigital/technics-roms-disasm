/* lane_p6 helper H, round 7, module 265 (demo/fdemotext_routines.s), form b: as form a, but plain array
   indexing with the signed int index cells, the y adjustment as one expression on the difference, and the
   reply-status choice in ScanMIDIChannels as a switch with the default first. */
/* cc900-module: FDemoText_CalcTextExtent FDemoText_UpdateCursorPosition */

struct fdlay { int x, y; };
struct rect { int x0, y0, x1, y1; };
extern struct fdlay ram_25b3a;
extern long ram_25b40[];
extern int ram_25b3e;
extern int ram_25b60;
extern int ram_25b62[];
extern int ram_25b72;
extern unsigned char ram_25b74[];
#define CUR_FONT ram_25b40[ram_25b3e]
#define CUR_COLOR ram_25b62[ram_25b60]
#define CUR_ALIGN ram_25b74[ram_25b72]
extern struct rect FDemoText_ScreenClipRect;
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int __cdecl Strlen(char *);
extern unsigned char *__cdecl Malloc(unsigned int);
extern char *__cdecl Strcpy(char *, char *);
extern void __cdecl Free(void *);
extern int FDemoText_CalcTextExtent(struct fdlay *);
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
    int h, len, n;

    clip = FDemoText_ScreenClipRect;
    h = GetCharHeight(CUR_FONT);
    h -= GetCharDescent(CUR_FONT);
    if (ram_25b3a.y - h < 0)
        ram_25b3a.y += (-(ram_25b3a.y - h) + 3) / 4 * 4;
    pos = ram_25b3a;
    pos.y -= h;
    len = Strlen(s);
    buf = (char *)Malloc(len + 1);
    Strcpy(buf, s);
    line = buf;
    ext = FDemoText_CalcTextExtent(&pos);
    n = WordwrapStrings(buf, CUR_FONT, ext);
    if (n != len) {
        wrapped = 1;
        end = buf + n - 1;
        if (n != 0)
            *end = 0;
    } else
        wrapped = 0;
    width = CalcTotalWidth(line, CUR_FONT);
    if (n != 0) {
        switch (CUR_ALIGN) {
        case 0:
            pos.x = ext / 2 + pos.x - width / 2;
            break;
        case 1:
            break;
        case 2:
            pos.x = pos.x + ext - width;
            break;
        }
        DrawString(&clip, &pos, buf, CUR_FONT, CUR_COLOR, 0xf7);
    }
    ram_25b3a.x = pos.x + width;
    if (wrapped != 0 && FDemoText_UpdateCursorPosition() != 0)
        FDemoText_RenderTextLine(end + 1);
    Free(buf);
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

extern int SeqBuf_NoteEvent_CheckSongEnd(void);
extern void SeqBuf_NoteEvent_CopyPointers(void);
extern int Seq_RingBuf_ReadSmall(void);
extern unsigned char ram_247f4[];
extern unsigned char ram_247f0;
extern unsigned char FDemoText_VoiceActiveBit[];

void FDemoText_ScanMIDIChannels(void)
{
    unsigned char msg[6];
    unsigned char resp[16];
    unsigned char ch;
    unsigned int timeout;
    unsigned char st;
    unsigned char v;
    unsigned int n;
    int c;
    unsigned char *p;

    msg[0] = 0x80;
    msg[1] = 0;
    msg[2] = 0x17;
    msg[3] = 2;
    msg[4] = 1;
    msg[5] = 0xea;
    sendCOMM(0, 6, msg);
    msg[1] = 1;
    sendCOMM(0, 6, msg);
    msg[1] = 2;
    sendCOMM(0, 6, msg);
    timeout = 0;
    while (SeqBuf_NoteEvent_CheckSongEnd() == 0) {
        if (++timeout > 10000)
            break;
    }
    SeqBuf_NoteEvent_CopyPointers();
    for (ch = 0; ch <= 2; ch++) {
        st = 0xff;
        while (timeout < 10000) {
            timeout++;
            while ((c = Seq_RingBuf_ReadSmall()) >= 0) {
                n = 1;
                resp[0] = c;
                while (n < 6 && (c = Seq_RingBuf_ReadSmall()) >= 0) {
                    resp[n] = c;
                    n++;
                }
                if (resp[0] == 0x80)
                    resp[3] = 2;
                while (n < (unsigned char)(resp[3] + 6) && (c = Seq_RingBuf_ReadSmall()) >= 0) {
                    resp[n] = c;
                    if (n >= 16)
                        break;
                    n++;
                }
                if ((unsigned char)(resp[3] + 6) == n && resp[5] == 0xea) {
                    v = resp[7];
                    switch (v) {
                    default:
                        st = 0;
                        break;
                    case 0xf:
                    case 0x35:
                        st = 1;
                        break;
                    }
                    ram_247f4[ch] = v;
                }
                if (st != 0xff)
                    break;
            }
            if (st != 0xff)
                break;
        }
        p = &FDemoText_VoiceActiveBit[ch];
        if (st == 1)
            ram_247f0 |= *p;
        else
            ram_247f0 &= ~*p;
    }
}
