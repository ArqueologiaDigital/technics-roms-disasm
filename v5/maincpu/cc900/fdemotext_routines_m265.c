/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void sendCOMM(int, int, unsigned char *);
struct dmsg { unsigned char st, part, type, b3, b4, b5, b6, b7; };
extern struct dmsg ram_20c33;
extern unsigned char __near PART_SELECT;
extern unsigned char __near ACTIVE_TITLE;
extern void DemoMenu_BuildItemWorkspace(int, int);

void FDemoText_SendResetMessage(unsigned char c)
{
	unsigned char b[6];

	b[0] = 0x82;
	b[1] = c;
	b[2] = 2;
	b[3] = 2;
	b[4] = 1;
	b[5] = 0xea;
	sendCOMM(0, 6, b);
	b[2] = 0x82;
	b[3] = 2;
	sendCOMM(0, 6, b);
	b[0] = 0x83;
	b[2] = 2;
	b[3] = 2;
	sendCOMM(0, 6, b);
	b[2] = 0x82;
	b[3] = 2;
	sendCOMM(0, 6, b);
}

void FDemoText_ParseControlMessage(void)
{
    unsigned char s, t;
    int ch;

    if (ram_20c33.part != PART_SELECT)
        return;
    if (ACTIVE_TITLE != 234)
        return;
    s = ram_20c33.st;
    if (s != 0x83) {
        if (s != 0x82)
            return;
        t = ram_20c33.type;
        ch = ram_20c33.b7 & 0xf;
        switch (t) {
        case 2:
            DemoMenu_BuildItemWorkspace(6, ch);
            DemoMenu_BuildItemWorkspace(2, (ram_20c33.b6 >> 4) & 0xf);
            DemoMenu_BuildItemWorkspace(0, ram_20c33.b6 & 0xf);
            break;
        case 0x82:
            DemoMenu_BuildItemWorkspace(8, ch);
            DemoMenu_BuildItemWorkspace(5, (ram_20c33.b6 >> 4) & 0xf);
            DemoMenu_BuildItemWorkspace(3, ram_20c33.b6 & 0xf);
            break;
        }
    }
    switch (ram_20c33.type) {
    case 2:
        DemoMenu_BuildItemWorkspace(7, ram_20c33.b7 & 0xf);
        DemoMenu_BuildItemWorkspace(4, (ram_20c33.b6 >> 4) & 0xf);
        DemoMenu_BuildItemWorkspace(1, ram_20c33.b6 & 0xf);
        break;
    case 0x82:
        DemoMenu_BuildItemWorkspace(10, ram_20c33.b6 & 1);
        DemoMenu_BuildItemWorkspace(9, (ram_20c33.b6 >> 1) & 1);
        break;
    }
}

/* cc900-module: FDemoText_CheckVoiceState FDemoText_LookupTableEntry */
extern unsigned char *FDemoText_LookupTableEntry(unsigned int);
extern unsigned char FDemoText_CheckVoiceState(unsigned int);
extern void AddswbWr(unsigned int, unsigned int, unsigned int, unsigned int);
extern void FDemoText_UpdateChannelVoice(unsigned char ch);

void FDemoText_UpdateChannelVoice(unsigned char ch)
{
	unsigned char *e, *e2;
	unsigned char s;
	unsigned int w;

	e = FDemoText_LookupTableEntry(ch);
	e += 5;
	s = FDemoText_CheckVoiceState(ch);
	w = ch;
	if (s != 1) {
		*e = 0;
		AddswbWr(w, 5, 0, 0x7f);
		return;
	}
	if (*e != 0) return;
	*e = 0x50;
	AddswbWr(w, 5, 0x50, 0x7f);
	e2 = e + 2;
	if (*e2 == 0) return;
	*e2 = 0;
	AddswbWr(ch, 7, 0, 0x7f);
}

/* cc900-module: FDemoText_CalcTextExtent FDemo_LinkedListSearchInsert */
extern void DemoDesc_BuildCompactParams(unsigned char *);
extern void VoiceEvent_FlushAndReturn(int, int);
extern void FDemoText_SendExtVoiceParams(unsigned char part);

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

/* cc900-module: FDemoText_RenderTextLine FDemoText_UpdateCursorPosition */
struct fdlay { int x, y; };
extern struct fdlay ram_25b3a;
extern long ram_25b40[8];
extern int ram_25b3e;
extern int ram_25b72;
extern unsigned char ram_25b74[8];
extern int GetCharHeight(long);
extern int GetCharDescent(long);
extern int FDemoText_CalcTextExtent(struct fdlay *);
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
extern void FDemoText_RenderTextLine(char *s);

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
