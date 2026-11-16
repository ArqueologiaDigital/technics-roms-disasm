/* Phase 6, lane_p6 helper C, round 3, form a: refinements of rounds 1-2 and new leaf functions of v10
   midi/midi_dispatch_handlers.s, demo/file_demo_proc.s, boot/system_handlers.s.  Form b (p6_C_3b.c) has the same names. */

typedef unsigned char *ucp;
typedef unsigned char **ucpp;

struct diskinfo { unsigned int w[38]; };
struct frec { unsigned int w[6]; };
struct dirent82 { unsigned int w[41]; };
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
struct xfer { unsigned char *start; unsigned char *end; long size; };
/* one byte seen as bit fields (bit fields fill a unit from bit 7); used through casts at odd offsets */
struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct b6 { unsigned char h : 1; unsigned char f : 1; unsigned char r : 6; };
struct l2 { unsigned char h : 6; unsigned char v : 2; };
struct l4 { unsigned char h : 4; unsigned char v : 4; };

/* __near: the ROM reaches the cell with a 16-bit absolute operand; __tiny: 8-bit; plain: 24-bit. */
extern struct diskinfo FileIO_DiskInfoInit;
extern struct diskinfo ram_25d6c;
extern struct frec FileIO_EmptyFileRecord;
extern unsigned int ram_25db8[];
extern struct dirent82 FileIO_DirListEntryTemplate;
extern unsigned char ram_25eb2[];
extern int ram_25ea8;
extern int ram_271ea;
extern int ram_271ec;
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern int ram_272c8;
extern int ram_272ca;
extern char ram_25db6;
extern unsigned int __near INTERCPU_XFER_COUNT;
extern ucp __near INTERCPU_XFER_PTR;
extern unsigned char INTER_CPU_COMM_LATCHES;
extern ucpp __near PART_RECORD_PTRS;
extern unsigned char SndParam_PresetBanks[];
extern unsigned char *PanelVari_PartRecordPtrs[];
extern unsigned char __near LIVE_PANEL_BLOCK;
extern unsigned char __near ram_ffbe;
extern unsigned char MSP_SETTINGS__BASE_ADDR;
extern unsigned char ram_1e8820;
extern unsigned char ram_1e8b00;
extern unsigned char ram_94860;
extern unsigned char ram_95bc0;
extern unsigned char RHYTHM_PATTERN_BUF_A;
extern unsigned int ram_3ec4e;
extern unsigned int ram_25b8e;
extern unsigned char *ram_25b8a;
extern unsigned char __tiny P7;
extern unsigned int SEQMAIN_WRITE_POS;
extern unsigned int SEQMAIN_READ_POS;

int ValidateFileRange(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_25eb2[(i - b) * 82] == 0) return 2;
    return 0;
}

int ValidateFileRangeAlt(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 6 && m != 7) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_25eb2[(i - b) * 82] == 0) return 2;
    return 0;
}

unsigned int CheckFileSystemStatus(void)
{
    if (ram_25ea8 < 0 || ram_25ea8 >= 20) return 0;
    return ram_25db8[ram_25ea8 * 6];
}

int DataBuf_CheckFormatPair(char *p)
{
    char e;
    char c = p[4];
    char d;
    p += 5;
    if (c == 'M') {
        e = *p;
        if (e == '4') return 1;
    }
    d = *p;
    if (c == 'M' && d == '6') return 2;
    if (c == 'N' && d == 'N') return 3;
    return -1;
}

void FileIO_InitRecordTable(void)
{
    struct frec *p = (struct frec *)ram_25db8, *e = (struct frec *)ram_25db8 + 20;
    struct dirent82 *q = (struct dirent82 *)ram_25eb2, *f = (struct dirent82 *)ram_25eb2 + 60;
    ram_25d6c = FileIO_DiskInfoInit;
    do { *p = FileIO_EmptyFileRecord; p++; } while (p < e);
    do { *q = FileIO_DirListEntryTemplate; q++; } while (q < f);
    ram_25ea8 = 0;
    ram_271ea = 0;
    ram_271ec = 0;
    ram_271ee = 0;
    FILE_LIST_LAST = 0;
    ram_272c8 = 0;
    ram_272ca = 0;
}

void VoiceData_ZeroFillAll(void)
{
    unsigned char **p = PanelVari_PartRecordPtrs, **e = PanelVari_PartRecordPtrs + 16;
    unsigned char *d;
    unsigned char n;
    do {
        d = *p;
        n = d[-1];
        if (n--) do *d++ = 0; while (n--);
        p++;
    } while (p < e);
}

unsigned char Part_LookupTableEntry(unsigned char p, unsigned char i)
{
    if (PART_RECORD_PTRS[p] != (unsigned char *)0xffffffff) return PART_RECORD_PTRS[p][i];
    return 0;
}

unsigned char *SndParam_GetBlockPointer(unsigned char a)
{
    unsigned char *b;
    int k;
    if (a < 0x19) {
        k = a;
        b = SndParam_PresetBanks;
        return b + k * 0xea;
    }
    switch (a) {
    case 0x1b: return (unsigned char *)0x3d3010;
    case 0x1c: return (unsigned char *)0x3d3110;
    case 0x1d: return (unsigned char *)0x3d3210;
    }
    return 0;
}

void MidiPkt_SetXferTotal_Panel(struct xfer *x)
{
    long d, n;
    unsigned char *e;
    x->start = &LIVE_PANEL_BLOCK;
    d = &ram_ffbe - &LIVE_PANEL_BLOCK;
    n = d + 0x12cb2;
    e = n + x->start;
    x->end = e;
    x->size = n;
}

void MidiPkt_SetXferBlock_AccompAreaHeader(struct xfer *x)
{
    long n;
    unsigned char *p = &MSP_SETTINGS__BASE_ADDR;
    unsigned char *e;
    x->start = p;
    n = &ram_1e8820 - p;
    e = n + p;
    x->end = e;
    x->size = n;
}

void MidiPkt_SetXferBlock_AccompBankTables(struct xfer *x)
{
    long n;
    unsigned char *p = &ram_1e8820;
    unsigned char *e;
    x->start = p;
    n = &ram_1e8b00 - p;
    e = n + p;
    x->end = e;
    x->size = n;
}

/* cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *x)
{
    long n;
    unsigned char *p = &ram_94860;
    x->start = p;
    n = &ram_95bc0 - p;
    p += n;
    x->end = p;
    x->size = n;
}

/* cc900-name: MidiPkt_SetXferBlk_StyleImgHdr=MidiPkt_SetXferBlock_StyleImageHeader */
void MidiPkt_SetXferBlk_StyleImgHdr(struct xfer *x)
{
    long n;
    unsigned char *p = &RHYTHM_PATTERN_BUF_A;
    x->start = p;
    n = &ram_94860 - p;
    p += n;
    x->end = p;
    x->size = n;
}

void VoiceParam_CopyFields_TypeE(unsigned char *s, unsigned char *d)
{
    unsigned char t;
    t = s[2];
    ((struct l7 *)(d + 10))->v = t;
    t = s[3];
    ((struct l7 *)(d + 11))->v = t;
    t = s[4];
    ((struct l7 *)(d + 12))->v = t;
    t = s[5];
    d[2] = t;
    t = s[6];
    ((struct l7 *)(d + 5))->v = t;
    ((struct b6 *)(d + 6))->f = ((struct b6 *)(s + 7))->f;
}

void VoiceParam_CopyFields_TypeD(unsigned char *s, unsigned char *d)
{
    unsigned char t;
    t = s[2];
    ((struct l2 *)(d + 2))->v = t;
    t = s[3];
    d[4] = t;
    t = s[5];
    ((struct l4 *)(d + 6))->v = t;
    ((struct l7 *)(d + 3))->v = s[17] & 0x7f;
}

void DataBuf_CopyChorusBlock16(unsigned char *s, unsigned char *d)
{
    unsigned char t;
    struct l7 *q;
    t = s[2];
    d[2] = t;
    t = s[3];
    ((struct l7 *)(d + 3))->v = t;
    t = s[4] & 0x7f;
    d[4] = t;
    t = s[5];
    ((struct l7 *)(d + 5))->v = t;
    ((struct b6 *)(d + 6))->f = ((struct b6 *)(s + 6))->f;
    t = s[7];
    ((struct l7 *)(d + 7))->v = t;
    t = s[8];
    d[8] = t;
    t = s[9];
    ((struct l7 *)(d + 9))->v = t;
    q = (struct l7 *)(d + 10);
    q->h = ((struct l7 *)(s + 11))->h;
    q->v = s[11];
    q = (struct l7 *)(d + 11);
    q->h = ((struct l7 *)(s + 12))->h;
    q->v = s[12];
    q = (struct l7 *)(d + 12);
    q->h = ((struct l7 *)(s + 13))->h;
    q->v = s[13];
    q = (struct l7 *)(d + 13);
    q->h = ((struct l7 *)(s + 14))->h;
    q->v = s[14];
    q = (struct l7 *)(d + 14);
    q->h = ((struct l7 *)(s + 15))->h;
    q->v = s[15];
}

void Audio_DMA_Transfer(void)
{
    unsigned long i, n;
    unsigned char d;
    n = INTERCPU_XFER_COUNT;
    if (INTERCPU_XFER_COUNT == 0) n = 0x10000;
    for (i = 0; i < n; i++) {
        INTER_CPU_COMM_LATCHES = *INTERCPU_XFER_PTR++;
        d = 0;
        do d++; while (d < 3);
    }
}

unsigned char MidiChan_DequeueVoiceEntry(struct mq *q)
{
    unsigned char c = 0xff;
    unsigned char **pp = &q->rd;
    unsigned char *r = *pp;
    if (*r != 0xff) {
        c = *r++;
        *pp = r;
    }
    return c;
}

unsigned char MIDI_PackNibbleParam(struct mq *q)
{
    unsigned char **pp = &q->p6;
    unsigned char r;
    r = *(*pp)++ << 4;
    r |= *(*pp)++ & 0xf;
    return r;
}

int FileIO_Search_SkipEntry(char *a, char *b, int n)
{
    char c;
    while (n != 0 && *a == *b) {
        if (*a == 0) return 0;
        a++;
        b++;
        n--;
    }
    c = 0;
    if (n != 0) c = *a - *b;
    return c;
}

int RecordChain_ReadNextByte(void)
{
    unsigned char *blk;
    unsigned int pos;
    int c;
    if (ram_3ec4e == 0xffff) return -1;
    blk = ram_25b8a + ((ram_3ec4e << 8) - 0x100);
    pos = ram_25b8e;
    c = (blk + 5)[pos];
    pos++;
    ram_25b8e = pos;
    if (pos > 0xfa) {
        ram_3ec4e = *(unsigned int *)(blk + 3);
        ram_25b8e = 0;
    }
    return c;
}

long TableDataROM_IdentifyChip(void)
{
    volatile long *p = (volatile long *)0x800000;
    do ; while (!(P7 & 0x20));
    p[0x5555] = 0x00aa00aaL;
    p[0x2aaa] = 0x00550055L;
    p[0x5555] = 0x00f000f0L;
    return p[0x1919];
}

int Seq_CheckSongEnd(void)
{
    if (SEQMAIN_WRITE_POS == SEQMAIN_READ_POS) return 0;
    return -1;
}

void Vga_WritePortShortDelay(unsigned int r, unsigned char v)
{
    unsigned int d = 0;
    do d++; while (d < 0x80);
    *(unsigned char *)(r + 0x170000L) = v;
}

void FileIO_CopyString(char *d, char *s)
{
    if (*s != 0) do *d++ = *s++; while (*s != 0);
    *d = 0;
}

/* cc900-name: Param_SignExt_H3_Helper=Param_SignExtendReturn_Helper3_Helper */
unsigned char Param_SignExt_H3_Helper(unsigned char *p, unsigned int n)
{
    unsigned char s = 0;
    p++;
    n--;
    while (n--) s += *p++;
    return -s & 0x7f;
}
