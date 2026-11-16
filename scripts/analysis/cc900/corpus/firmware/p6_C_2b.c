/* Phase 6, lane_p6 helper C, round 2, form b: refinements of round 1's misses and the bit-field copiers of
   v10 midi/midi_dispatch_handlers.s, demo/file_demo_proc.s.  Form a (p6_C_2a.c) has the same names. */

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

/* plain-byte sources for the field copies */
struct eS2 { unsigned char p0[2]; unsigned char b2, b3, b4, b5, b6; unsigned char h7 : 1; unsigned char f7 : 1; unsigned char r7 : 6; };
struct cho16s { unsigned char p0[2]; unsigned char b2, b3, b4, b5; unsigned char h6 : 1; unsigned char f6 : 1; unsigned char r6 : 6;
                unsigned char b7, b8, b9, b10; unsigned char h11 : 1; unsigned char r11 : 7; unsigned char h12 : 1; unsigned char r12 : 7;
                unsigned char h13 : 1; unsigned char r13 : 7; unsigned char h14 : 1; unsigned char r14 : 7; unsigned char h15 : 1; unsigned char r15 : 7; };
struct ents { unsigned char b0, b1, b2, b3; unsigned char rest[22]; };

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
    int b;
    if ((ram_25db6 != 2 && ram_25db6 != 3 && ram_25db6 != 4) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (((unsigned char *)ram_25eb2)[(i - b) * 82] == 0) return 2;
    return 0;
}

int FileIO_ValidateModeAndRange(int i)
{
    int b;
    if ((ram_25db6 != 2 && ram_25db6 != 3 && ram_25db6 != 4) || i < 0 || i > ram_272ca) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_2723c[(i - b) * 14] == 0) return 2;
    return 0;
}

int ValidateFileRangeAlt(int i)
{
    int b;
    if ((ram_25db6 != 6 && ram_25db6 != 7) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (((unsigned char *)ram_25eb2)[(i - b) * 82] == 0) return 2;
    return 0;
}

unsigned int CheckFileSystemStatus(void)
{
    if (ram_25ea8 < 0 || ram_25ea8 >= 20) return 0;
    return ((unsigned int *)ram_25db8)[ram_25ea8 * 6];
}

int DataBuf_CheckFormatPair(char *p)
{
    char c = p[4];
    char d, e;
    p += 5;
    if (c == 'M' && (e = *p) == '4') return 1;
    d = *p;
    if (c == 'M' && d == '6') return 2;
    if (c == 'N' && d == 'N') return 3;
    return -1;
}

unsigned char *Demo_GetPresetBaseForPart(unsigned char i)
{
    unsigned char *p;
    p = ((long *)0x9c4000)[i] != 0 ? (unsigned char *)0x69800 : SEQ_SONG_SLOTS;
    return p + 2048;
}

unsigned int Voice_GetPresetFieldWord(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    p += 30;
    return *(unsigned int *)p;
}

void Demo_ScanActivePartChannels(void)
{
    unsigned char i;
    i = 0;
    do {
        if (SEQ_TRACK_ASSIGN[i] == 16) {
            if ((Demo_PartBitMask[i] & SEQ_TRACK_MASK) != 0 && (SEQ_TRACK_TABLE[(int)i * 3] & 0x80) != 0) {
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
    struct frec *p, *e;
    struct dirent82 *q, *f;
    ram_25d6c = FileIO_DiskInfoInit;
    p = ram_25db8;
    e = &ram_25db8[20];
    do { *p = FileIO_EmptyFileRecord; p++; } while (p < e);
    q = ram_25eb2;
    f = &ram_25eb2[60];
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
    unsigned char n;
    unsigned char *d;
    unsigned char **e;
    unsigned char **p;
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
    v = (char)((s[0] - '0') * 10 + c - '0');
    if (v < 1 || v > 20) return -1;
    return v - 1;
}

unsigned char Part_LookupTableEntry(unsigned char p, unsigned char i)
{
    unsigned char *r = PART_RECORD_PTRS[p];
    if ((long)r != -1) return r[i];
    return 0;
}

void SndParam_ApplyModeSpecific(void)
{
    unsigned char m = ram_b7f0;
    unsigned char *p;
    unsigned char c;
    if (m == 2) return;
    p = PANEL_GM + 3;
    if (m == 0) *p &= 0xf8;
    else if (m == 1) {
        c = *p & 0xf8;
        *p = c;
        *p = c | 4;
    }
}

unsigned char *SndParam_GetBlockPointer(unsigned char a)
{
    int k;
    if (a < 0x19) {
        k = a;
        return SndParam_PresetBanks + k * 0xea;
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
    c = *q & ~1;
    *q = c;
    *q = c | ((ram_11f5 >> 8) & 1);
}

void MidiSeq_UpdateVolumeScale(void)
{
    struct vs *q;
    unsigned long v;
    unsigned char *p;
    p = &ram_bd1c;
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
    int last, i;
    char n, k;
    char *s;
    char *d;
    d = ram_25cec;
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
        if ((d[i] = s[i]) == '\\') last = i;
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
    n = 0;
    d = ram_272d2;
    while ((c = *s) != '\\' && n < 31) {
        *d++ = c;
        n++;
        s++;
    }
    *d = '\\';
}

void MidiPkt_SetXferBlock_LivePanel(struct xfer *x)
{
    long n;
    unsigned char *p = &LIVE_PANEL_BLOCK;
    x->start = p;
    n = &ram_ffbe - p + 2;
    x->end = n + p;
    x->size = n;
}

void MidiPkt_SetXferTotal_Panel(struct xfer *x)
{
    unsigned char *p = &LIVE_PANEL_BLOCK;
    long d, n;
    x->start = p;
    d = &ram_ffbe - p;
    n = d + 0x12cb2;
    x->end = x->start + n;
    x->size = n;
}

void MidiPkt_SetXferBlock_AccompAreaHeader(struct xfer *x)
{
    long n;
    unsigned char *p = &MSP_SETTINGS__BASE_ADDR;
    x->start = p;
    n = &ram_1e8820 - p;
    x->end = n + p;
    x->size = n;
}

void MidiPkt_SetXferBlock_AccompBankTables(struct xfer *x)
{
    long n;
    unsigned char *p = &ram_1e8820;
    x->start = p;
    n = &ram_1e8b00 - p;
    x->end = n + p;
    x->size = n;
}

/* cc900-name: MidiPkt_SetXferBlk_StyleImgTbl=MidiPkt_SetXferBlock_StyleImageTables */
void MidiPkt_SetXferBlk_StyleImgTbl(struct xfer *x)
{
    unsigned char *p = &ram_94860;
    long n;
    x->start = p;
    n = &ram_95bc0 - p;
    x->end = p + n;
    x->size = n;
}

void MidiPkt_SetXferBlock_SoundRamData(struct xfer *x)
{
    unsigned char *p = &ram_1e0000;
    p += 16;
    x->start = p;
    x->size = 0x729a;
    x->end = x->start + 0x729a;
}

void VoiceParam_CopyFields_TypeE(struct eS2 *s, struct eD *d)
{
    d->v10 = s->b2;
    d->v11 = s->b3;
    d->v12 = s->b4;
    d->b2 = s->b5;
    d->v5 = s->b6;
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

void DataBuf_CopyChorusBlock16(struct cho16s *s, struct cho16 *d)
{
    d->b2 = s->b2;
    d->v3 = s->b3;
    d->b4 = s->b4 & 0x7f;
    d->v5 = s->b5;
    d->f6 = s->f6;
    d->v7 = s->b7;
    d->b8 = s->b8;
    d->v9 = s->b9;
    d->h10 = s->h11;
    d->v10 = s->r11;
    d->h11 = s->h12;
    d->v11 = s->r12;
    d->h12 = s->h13;
    d->v12 = s->r13;
    d->h13 = s->h14;
    d->v13 = s->r14;
    d->h14 = s->h15;
    d->v14 = s->r15;
}

void FileData_CopyLivePartFieldsToMemory(unsigned char *s, unsigned char *d)
{
    struct ents *p, *e;
    struct ent *q;
    ((struct f45 *)(d + 705))->f = ((struct f45 *)(s + 737))->f;
    p = (struct ents *)(s + 62);
    q = (struct ent *)(d + 30);
    e = p + 16;
    do {
        q->v0 = p->b0;
        q->v3 = p->b3;
        q->v1 = p->b1;
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
        q->v0 = p->v0 & 0x7f;
        q->v3 = p->v3 & 0x7f;
        q->v1 = p->v1 & 0x7f;
        q->b2 = p->b2;
        q++;
        p++;
    } while (p < e);
    ((struct ent *)(d + 1047))->v0 = *(s + 1047);
}
