/* Phase 6, lane_p6 helper C, round 4, form a: leaf functions of v10 midi/midi_dispatch_handlers.s,
   demo/file_demo_proc.s, boot/system_handlers.s, display/scoop_display.s.  Form b (p6_C_4b.c) has the same names. */

typedef unsigned char *ucp;

struct frec { unsigned int w[6]; };
/* one byte seen as bit fields (bit fields fill a unit from bit 7); used through casts at any offset */
struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct b6 { unsigned char h : 1; unsigned char f : 1; unsigned char r : 6; };
struct l2 { unsigned char h : 6; unsigned char v : 2; };
struct l4 { unsigned char h : 4; unsigned char v : 4; };
struct b10 { unsigned char r : 6; unsigned char b1 : 1; unsigned char b0 : 1; };
struct r8 { unsigned char h : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1;
            unsigned char b3 : 1; unsigned char b2 : 1; unsigned char b1 : 1; unsigned char b0 : 1; };
struct eq2 { unsigned char h : 2; unsigned char f54 : 2; unsigned char b3 : 1; unsigned char b2 : 1; unsigned char l : 2; };
struct a4 { unsigned char b7 : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1;
            unsigned char b3 : 1; unsigned char lo : 3; };
struct a6 { unsigned char b7 : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1; unsigned char lo : 4; };
struct o56 { unsigned char h : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char r : 5; };

/* __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit. */
extern unsigned int ram_25db8[];
extern int ram_25ea8;
extern unsigned int ram_272cc;
extern unsigned int ram_272ce;
extern unsigned int SEQMAIN_WRITE_POS;
extern unsigned int SEQMAIN_READ_POS;
extern unsigned int ram_1e74f;
extern unsigned int ram_1e74b;
extern unsigned int ram_1e751;
extern unsigned int ram_204db;
extern unsigned int ram_204d7;
extern unsigned int ram_204dd;
extern unsigned int ram_1fc9f;
extern unsigned int ram_1fc9b;
extern unsigned int ram_1fca1;
extern unsigned int ram_1ef59;
extern unsigned int ram_1ef55;
extern unsigned int ram_1ef5b;
extern unsigned int ram_1f781;
extern unsigned int ram_1f77d;
extern unsigned char SEQ_SONG_SLOTS[];
extern unsigned char PortConfig_Handler_0_Tbl[];
extern unsigned char __near SQSTEP_DISPLAY_MODE;
extern unsigned char __near STATUS_POPUP_ID;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern ucp __near ram_1114;
extern unsigned char __near ram_ec4;
extern unsigned int __near ram_b7ea;

void VoiceParam_CopyFields_TypeE(unsigned char *s, unsigned char *d)
{
    unsigned char t;
    t = ((struct l7 *)(s + 2))->v;
    ((struct l7 *)(d + 10))->v = t;
    t = ((struct l7 *)(s + 3))->v;
    ((struct l7 *)(d + 11))->v = t;
    t = ((struct l7 *)(s + 4))->v;
    ((struct l7 *)(d + 12))->v = t;
    t = s[5];
    d[2] = t;
    t = ((struct l7 *)(s + 6))->v;
    ((struct l7 *)(d + 5))->v = t;
    ((struct b6 *)(d + 6))->f = ((struct b6 *)(s + 7))->f;
}

void VoiceParam_CopyFields_TypeD(unsigned char *s, unsigned char *d)
{
    unsigned char t;
    t = ((struct l2 *)(s + 2))->v;
    ((struct l2 *)(d + 2))->v = t;
    t = s[3];
    d[4] = t;
    t = ((struct l4 *)(s + 5))->v;
    ((struct l4 *)(d + 6))->v = t;
    ((struct l7 *)(d + 3))->v = s[17];
}

int Seq_CheckSongEnd(void)
{
    return SEQMAIN_WRITE_POS == SEQMAIN_READ_POS ? 0 : -1;
}

int TempoRingBuf_CheckEmpty(void)
{
    return ram_1e74f == ram_1e74b ? 0 : -1;
}

int SeqBuf_NoteEvent_CheckSongEnd(void)
{
    return ram_204db == ram_204d7 ? 0 : -1;
}

int SeqBuf_DspSysEx_CheckSongEnd(void)
{
    return ram_1fc9f == ram_1fc9b ? 0 : -1;
}

int RhythmBuf_CheckEmpty(void)
{
    return ram_1ef59 == ram_1ef55 ? 0 : -1;
}

int SeqBuf_MidiOut_CheckEmpty(void)
{
    return ram_1f781 == ram_1f77d ? 0 : -1;
}

unsigned int TempoRingBuf_BytecodeSnippet2(void) { return ram_1e751; }
unsigned int SeqBuf_NoteEvent_OrphanData(void) { return ram_204dd; }
unsigned int SeqBuf_DspSysEx_OrphanData(void) { return ram_1fca1; }
unsigned int RhythmBuf_BytecodeSnippet(void) { return ram_1ef5b; }

void Vga_WritePortShortDelay(unsigned int r, unsigned char v)
{
    unsigned int d = 0;
    do d++; while (d < 0x80);
    *((unsigned char *)0x170000 + r) = v;
}

unsigned char *Demo_GetPresetBaseForPartAlt(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    p += 768;
    return p;
}

int FileIO_SearchFile(char *a, char *b)
{
    char c;
    while ((c = *a) == *b) {
        if (c == 0) return 0;
        a++;
        b++;
    }
    return (char)(*a - *b);
}

unsigned int FileIO_GetRecordFlags(unsigned int i)
{
    if (i >= 20) return 0;
    return ((struct frec *)ram_25db8)[i].w[0];
}

void SqStep_SetPopupIdForDisplayMode(void)
{
    STATUS_POPUP_ID = PortConfig_Handler_0_Tbl[SQSTEP_DISPLAY_MODE & 3];
}

void Demo_WaitForDisplayBit(void)
{
    long n = 0xffffff;
    if (!(PLAY_TRANSPORT_STATE & 4)) return;
    do {
        if (--n == 0) return;
    } while (PLAY_TRANSPORT_STATE & 4);
}

void OscScope_Handler_2_Helper(void)
{
    struct o56 *p = (struct o56 *)(ram_1114 + (unsigned char)(ram_ec4 << 2));
    p->b5 = 0;
    p->b6 = 1;
}

unsigned char FileIO_CheckRecordValid(unsigned char a)
{
    unsigned int m;
    if (ram_25ea8 < 0 || ram_25ea8 >= 20 || a >= 10) return 0;
    m = 1;
    m <<= a;
    return (ram_25db8[ram_25ea8 * 6] & m) == m;
}

unsigned char FileIO_CheckRecordByFile(unsigned int i, unsigned char b)
{
    unsigned int m;
    if (i >= 20 || b >= 10) return 0;
    m = 1;
    m <<= b;
    return (((struct frec *)ram_25db8)[i].w[0] & m) == m;
}

unsigned char FileIO_WriteRecordName_Done(unsigned char a)
{
    unsigned int m;
    if (ram_25ea8 < 0 || ram_25ea8 >= 20 || a >= 10) return 0;
    m = 1;
    m <<= a;
    return (ram_272cc & m) == m;
}

unsigned char FileIO_FormatName_Return(unsigned char a)
{
    unsigned int m;
    if (ram_25ea8 < 0 || ram_25ea8 >= 20 || a >= 10) return 0;
    m = 1;
    m <<= a;
    return (ram_272ce & m) == m;
}

void VoiceParam_CopyBitfields_TypeC(unsigned char *s, unsigned char *d)
{
    struct b10 *pd = (struct b10 *)(d + 2);
    struct b10 *ps = (struct b10 *)(s + 2);
    pd->b0 = ps->b0;
    pd->b1 = ps->b1;
    ((struct b10 *)(d + 3))->b1 = ((struct b10 *)(s + 3))->b1;
    pd = (struct b10 *)(d + 5);
    ps = (struct b10 *)(s + 7);
    pd->b0 = ps->b0;
    pd->b1 = ps->b1;
}

void DataBuf_CopyEQBlock7(unsigned char *s, unsigned char *d)
{
    struct eq2 *pd = (struct eq2 *)(d + 2);
    struct eq2 *ps = (struct eq2 *)(s + 2);
    pd->f54 = ps->f54;
    pd->b3 = ps->b3;
    pd->b2 = ps->b2;
    pd->l = ps->l;
    ((struct l7 *)(d + 3))->v = ((struct l7 *)(s + 3))->v;
    d[4] = s[4];
    ((struct l4 *)(d + 6))->v = ((struct l4 *)(s + 6))->v;
    if (ram_b7ea != 2) return;
    d[5] = s[5];
}

void DataBuf_CopyReverbBlock6(unsigned char *s, unsigned char *d)
{
    struct r8 *pd = (struct r8 *)(d + 2);
    struct r8 *ps = (struct r8 *)(s + 2);
    pd->b1 = ps->b1;
    pd->b0 = ps->b0;
    ((struct r8 *)(d + 3))->b1 = ((struct r8 *)(s + 3))->b1;
    pd = (struct r8 *)(d + 4);
    ps = (struct r8 *)(s + 4);
    pd->b6 = ps->b6;
    pd->b5 = ps->b5;
    pd->b4 = ps->b4;
    pd->b3 = ps->b3;
    pd->b2 = ps->b2;
    pd->b1 = ps->b1;
    pd->b0 = ps->b0;
    pd = (struct r8 *)(d + 5);
    ps = (struct r8 *)(s + 5);
    pd->b1 = ps->b1;
    pd->b0 = ps->b0;
}

void VoiceParam_CopyBitfields_TypeA(unsigned char *s, unsigned char *d)
{
    struct a6 *s6;
    struct a4 *s4, *d6;
    struct l7 *q;
    d[2] = s[2];
    s6 = (struct a6 *)(s + 6);
    ((struct l7 *)(d + 3))->v = s6->lo;
    ((struct l7 *)(d + 5))->v = ((struct l7 *)(s + 3))->v;
    d6 = (struct a4 *)(d + 6);
    s4 = (struct a4 *)(s + 4);
    d6->b7 = s4->b7;
    d6->b6 = s4->b6;
    d6->b3 = s4->b3;
    d6->lo = s4->lo;
    q = (struct l7 *)(d + 7);
    if (s4->b5) q->v = 0x50;
    else q->v = 0;
    q = (struct l7 *)(d + 9);
    if (((struct l7 *)(s + 5))->h) q->v = 0x5a;
    else q->v = 0;
    ((struct a6 *)(d + 14))->b5 = ((struct a6 *)(s + 9))->b5;
    q = (struct l7 *)(d + 16);
    {
        struct l7 *r = (struct l7 *)(s + 8);
        q->v = r->v;
        q->h = r->h;
    }
    d[17] = s[11];
    ((struct a6 *)(d + 15))->b6 = s6->b6;
    ((struct a6 *)(d + 15))->b5 = s6->b5;
}
