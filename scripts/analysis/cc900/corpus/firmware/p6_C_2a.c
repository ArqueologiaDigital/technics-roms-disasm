/* Phase 6, lane_p6 helper C, round 2, form a: refinements of round 1's misses and the bit-field copiers of
   v10 midi/midi_dispatch_handlers.s, demo/file_demo_proc.s.  Form b (p6_C_2b.c) has the same names. */

typedef unsigned char *ucp;
typedef unsigned char **ucpp;

struct diskinfo { unsigned int w[38]; };
struct frec { unsigned int w[6]; };
struct dirent82 { unsigned int w[41]; };
struct vs { unsigned char pad[8]; unsigned long v8; unsigned long v12; };
struct xfer { unsigned char *start; unsigned char *end; long size; };
/* one byte: bits 5-4 a field */
struct f45 { unsigned char h : 2; unsigned char f : 2; unsigned char l : 4; };
/* a 26-byte part entry: low 7 bits of bytes 0, 1, 3; byte 2 whole */
struct ent { unsigned char h0 : 1; unsigned char v0 : 7; unsigned char h1 : 1; unsigned char v1 : 7;
             unsigned char b2; unsigned char h3 : 1; unsigned char v3 : 7; unsigned char rest[22]; };
/* VoiceParam_CopyFields_TypeE: source and destination records */
struct eS { unsigned char p0[2]; unsigned char h2 : 1; unsigned char v2 : 7; unsigned char h3 : 1; unsigned char v3 : 7;
            unsigned char h4 : 1; unsigned char v4 : 7; unsigned char b5; unsigned char h6 : 1; unsigned char v6 : 7;
            unsigned char h7 : 1; unsigned char f7 : 1; unsigned char r7 : 6; };
struct eD { unsigned char p0[2]; unsigned char b2; unsigned char p3[2]; unsigned char h5 : 1; unsigned char v5 : 7;
            unsigned char h6 : 1; unsigned char f6 : 1; unsigned char r6 : 6; unsigned char p7[3];
            unsigned char h10 : 1; unsigned char v10 : 7; unsigned char h11 : 1; unsigned char v11 : 7;
            unsigned char h12 : 1; unsigned char v12 : 7; };
/* DataBuf_CopyCompressorBlock16 / DataBuf_CopyChorusBlock16: one 16-byte block layout each */
struct cmp16 { unsigned char p0[2]; unsigned char b2; unsigned char h3 : 1; unsigned char r3 : 3; unsigned char v3 : 4;
               unsigned char b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15; };
struct cho16 { unsigned char p0[2]; unsigned char b2; unsigned char h3 : 1; unsigned char v3 : 7; unsigned char b4;
               unsigned char h5 : 1; unsigned char v5 : 7; unsigned char h6 : 1; unsigned char f6 : 1; unsigned char r6 : 6;
               unsigned char h7 : 1; unsigned char v7 : 7; unsigned char b8; unsigned char h9 : 1; unsigned char v9 : 7;
               unsigned char h10 : 1; unsigned char v10 : 7; unsigned char h11 : 1; unsigned char v11 : 7;
               unsigned char h12 : 1; unsigned char v12 : 7; unsigned char h13 : 1; unsigned char v13 : 7;
               unsigned char h14 : 1; unsigned char v14 : 7; unsigned char h15 : 1; unsigned char v15 : 7; };

/* __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit. */
extern struct diskinfo FileIO_DiskInfoInit;
extern struct diskinfo ram_25d6c;
extern struct frec FileIO_EmptyFileRecord;
extern struct frec ram_25db8[];
extern struct dirent82 FileIO_DirListEntryTemplate;
extern struct dirent82 ram_25eb2[];
extern unsigned char ram_2723c[];
extern int ram_25ea8;
extern int ram_271ea;
extern int ram_271ec;
extern int ram_271ee;
extern int FILE_LIST_LAST;
extern int ram_272c8;
extern int ram_272ca;
extern char ram_25db6;
extern char ram_25cec[];
extern char ram_27312[][32];
extern long ram_27416;
extern char ram_27412;
extern char ram_27414;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char __near SEQ_TRACK_TABLE[];
extern unsigned char __near ram_d56;
extern unsigned char __near ram_d54;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned int Demo_PartBitMask[];
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd1c;
extern unsigned char __near ram_bd04;
extern unsigned char __near ram_bd10;
extern struct vs __near ram_bcbc;
extern struct vs __near ram_bcdc;
extern ucpp __near PART_RECORD_PTRS;
extern unsigned char SndParam_PresetBanks[];
extern unsigned char *PanelVari_PartRecordPtrs[];
extern unsigned int __near ram_11f5;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near PANEL_GM[];
extern unsigned char __near ram_b7f0;
extern unsigned char SEQ_SONG_SLOTS[];
extern char ram_272d2[];
extern unsigned char __near LIVE_PANEL_BLOCK;
extern unsigned char __near ram_ffbe;
extern unsigned char ram_1e0000;
extern unsigned char MSP_SETTINGS__BASE_ADDR;
extern unsigned char ram_1e8820;
extern unsigned char ram_1e8b00;
extern unsigned char ram_94860;
extern unsigned char ram_95bc0;

int ValidateFileRange(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (((unsigned char *)ram_25eb2)[(i - b) * 82] == 0) return 2;
    return 0;
}

int FileIO_ValidateModeAndRange(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i > ram_272ca) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_2723c[(i - b) * 14] == 0) return 2;
    return 0;
}

int ValidateFileRangeAlt(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 6 && m != 7) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (((unsigned char *)ram_25eb2)[(i - b) * 82] == 0) return 2;
    return 0;
}

unsigned int CheckFileSystemStatus(void)
{
    if (ram_25ea8 < 0 || ram_25ea8 >= 20) return 0;
    return *(unsigned int *)((unsigned char *)ram_25db8 + ram_25ea8 * 12);
}

int DataBuf_CheckFormatPair(char *p)
{
    char c = p[4];
    char d, e;
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

unsigned char *Demo_GetPresetBaseForPart(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    p += 2048;
    return p;
}

unsigned int Voice_GetPresetFieldWord(unsigned char i)
{
    unsigned char *p;
    unsigned int *w;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    w = (unsigned int *)(p + 30);
    return *w;
}

void Demo_ScanActivePartChannels(void)
{
    unsigned char i;
    int k;
    i = 0;
    do {
        if (SEQ_TRACK_ASSIGN[i] == 16) {
            k = i;
            if ((Demo_PartBitMask[k] & SEQ_TRACK_MASK) != 0 && (SEQ_TRACK_TABLE[k * 3] & 0x80) != 0) {
                ram_d56 = i + 1;
                ram_d54 |= 1;
                SEQ_EDIT_FLAGS |= 4;
                break;
            }
            i = 15;
        }
    } while (++i < 16);
    if (i == 16) {
        ram_d54 &= ~1;
        SEQ_EDIT_FLAGS &= ~4;
    }
}

void FileIO_InitRecordTable(void)
{
    struct frec *e, *p;
    struct dirent82 *f, *q;
    ram_25d6c = FileIO_DiskInfoInit;
    p = ram_25db8;
    e = p + 20;
    do { *p = FileIO_EmptyFileRecord; p++; } while (p < e);
    q = ram_25eb2;
    f = q + 60;
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
    unsigned char **e, **p;
    unsigned char *d;
    unsigned char n;
    p = PanelVari_PartRecordPtrs;
    e = p + 16;
    do {
        d = *p;
        n = d[-1];
        if (n--) do *d++ = 0; while (n--);
        p++;
    } while (p < e);
}

int ParseTwoDigitFileNum(char *s)
{
    char c;
    int v;
    if (s[0] < '0' || s[0] > '2') return -1;
    c = s[1];
    if (c < '0' || c > '9') return -1;
    v = (char)(s[0] * 10 + c - 0x10);
    if (v < 1 || v > 20) return -1;
    return v - 1;
}

unsigned char Part_LookupTableEntry(unsigned char p, unsigned char i)
{
    unsigned char **t = PART_RECORD_PTRS;
    unsigned char *r = t[p];
    if (r != (unsigned char *)0xffffffff) return r[i];
    return 0;
}

void SndParam_ApplyModeSpecific(void)
{
    unsigned char m = ram_b7f0;
    unsigned char *p;
    unsigned char c;
    if (m == 2) return;
    p = PANEL_GM + 3;
    switch (m) {
    case 1:
        c = *p;
        c &= 0xf8;
        *p = c;
        c |= 4;
        *p = c;
        break;
    case 0:
        *p &= 0xf8;
        break;
    }
}

unsigned char *SndParam_GetBlockPointer(unsigned char a)
{
    int k;
    if (a < 0x19) {
        k = a;
        return &SndParam_PresetBanks[k * 0xea];
    }
    switch (a) {
    case 0x1b: return (unsigned char *)0x3d3010;
    case 0x1c: return (unsigned char *)0x3d3110;
    case 0x1d: return (unsigned char *)0x3d3210;
    }
    return 0;
}

void SoundParam_ApplyBit15Toggle(void)
{
    unsigned char *p;
    unsigned char *q;
    unsigned char c;
    if (!(ram_11f5 & 0x8000)) return;
    p = PANEL_STYLE;
    p[8] = ram_11f5;
    q = p + 9;
    c = *q;
    c &= ~1;
    *q = c;
    c |= (ram_11f5 >> 8) & 1;
    *q = c;
}

void MidiSeq_UpdateVolumeScale(void)
{
    unsigned long v;
    struct vs *q;
    unsigned char *p = &ram_bd1c;
    if (*p & 0x80) return;
    if (ram_bd18 & 0x40) {
        q = &ram_bcbc;
        v = q->v8 >> 5;
        q->v12 = v;
        ram_bd04 = 160;
    } else {
        q = &ram_bcdc;
        v = q->v8 >> 5;
        q->v12 = v;
        ram_bd10 = 160;
    }
    if (v != 0) *p |= 0x80;
}

void FileIO_ExtractBasename(void)
{
    char *d = ram_25cec;
    char *s;
    char n, k;
    int last, i;
    *d = 0;
    if (ram_27416 < 0) return;
    n = ram_27412;
    if (n <= 0) return;
    k = ram_27414;
    if (k >= n) return;
    s = ram_27312[k];
    last = -1;
    i = 0;
    if (*s != 0) do {
        char c = s[i];
        d[i] = c;
        if (c == '\\') last = i;
        i++;
    } while (s[i] != 0);
    if (last > 0) d[last + 1] = 0;
    else *d = 0;
}

void FileIO_FindPathSeparator(char *s)
{
    char c;
    int n;
    char *d;
    char *t = s;
    n = 0;
    d = ram_272d2;
    while ((c = *t) != '\\' && n < 31) {
        *d++ = c;
        n++;
        t++;
    }
    *d = '\\';
}

void MidiPkt_SetXferBlock_LivePanel(struct xfer *x)
{
    unsigned char *p = &LIVE_PANEL_BLOCK;
    unsigned char *e;
    long n;
    x->start = p;
    n = &ram_ffbe - p + 2;
    e = n + p;
    x->end = e;
    x->size = n;
}

void MidiPkt_SetXferTotal_Panel(struct xfer *x)
{
    unsigned char *p = &LIVE_PANEL_BLOCK;
    long d, n;
    x->start = p;
    d = &ram_ffbe - p;
    n = d + 0x12cb2;
    x->end = n + x->start;
    x->size = n;
}

void MidiPkt_SetXferBlock_AccompAreaHeader(struct xfer *x)
{
    unsigned char *p = &MSP_SETTINGS__BASE_ADDR;
    unsigned char *e;
    long n;
    x->start = p;
    n = &ram_1e8820 - p;
    e = n + p;
    x->end = e;
    x->size = n;
}

void MidiPkt_SetXferBlock_AccompBankTables(struct xfer *x)
{
    unsigned char *p = &ram_1e8820;
    unsigned char *e;
    long n;
    x->start = p;
    n = &ram_1e8b00 - p;
    e = n + p;
    x->end = e;
    x->size = n;
}

/* cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *x)
{
    unsigned char *p = &ram_94860;
    long n;
    x->start = p;
    n = &ram_95bc0 - p;
    p += n;
    x->end = p;
    x->size = n;
}

void MidiPkt_SetXferBlock_SoundRamData(struct xfer *x)
{
    x->start = (unsigned char *)((long)&ram_1e0000 + 16);
    x->size = 0x729a;
    x->end = x->start + 0x729a;
}

void VoiceParam_CopyFields_TypeE(struct eS *s, struct eD *d)
{
    d->v10 = s->v2;
    d->v11 = s->v3;
    d->v12 = s->v4;
    d->b2 = s->b5;
    d->v5 = s->v6;
    d->f6 = s->f7;
}

void DataBuf_CopyCompressorBlock16(struct cmp16 *s, struct cmp16 *d)
{
    d->b2 = s->b2;
    d->h3 = s->h3;
    d->v3 = s->v3;
    d->b4 = s->b4;
    d->b5 = s->b5;
    d->b6 = s->b6;
    d->b7 = s->b7;
    d->b8 = s->b8;
    d->b9 = s->b9;
    d->b10 = s->b10;
    d->b11 = s->b11;
    d->b12 = s->b12;
    d->b13 = s->b13;
    d->b14 = s->b14;
    d->b15 = s->b15;
}

void DataBuf_CopyChorusBlock16(struct cho16 *s, struct cho16 *d)
{
    d->b2 = s->b2;
    d->v3 = s->v3;
    d->b4 = s->b4 & 0x7f;
    d->v5 = s->v5;
    d->f6 = s->f6;
    d->v7 = s->v7;
    d->b8 = s->b8;
    d->v9 = s->v9;
    d->h10 = s->h11;
    d->v10 = s->v11;
    d->h11 = s->h12;
    d->v11 = s->v12;
    d->h12 = s->h13;
    d->v12 = s->v13;
    d->h13 = s->h14;
    d->v13 = s->v14;
    d->h14 = s->h15;
    d->v14 = s->v15;
}

void FileData_CopyLivePartFieldsToMemory(unsigned char *s, unsigned char *d)
{
    struct ent *p, *q, *e;
    ((struct f45 *)(d + 705))->f = ((struct f45 *)(s + 737))->f;
    p = (struct ent *)(s + 62);
    q = (struct ent *)(d + 30);
    e = p + 16;
    do {
        q->v0 = p->v0;
        q->v3 = p->v3;
        q->v1 = p->v1;
        q->b2 = p->b2;
        q++;
        p++;
    } while (p < e);
}

void DataBuf_TransferSlotBitfields(unsigned char *s, unsigned char *d)
{
    struct ent *p, *q, *e;
    ((struct f45 *)(d + 737))->f = ((struct f45 *)(s + 737))->f;
    p = (struct ent *)(s + 62);
    q = (struct ent *)(d + 62);
    e = p + 16;
    do {
        q->v0 = p->v0;
        q->v3 = p->v3;
        q->v1 = p->v1;
        q->b2 = p->b2;
        q++;
        p++;
    } while (p < e);
    ((struct ent *)(d + 1047))->v0 = ((struct ent *)(s + 1047))->v0;
}
