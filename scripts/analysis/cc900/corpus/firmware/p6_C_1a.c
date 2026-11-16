/* Phase 6, lane_p6 helper C, round 1, form a: leaf functions of v10 midi/midi_dispatch_handlers.s,
   boot/system_handlers.s, display/scoop_display.s and demo/file_demo_proc.s, each under its firmware name.
   Guesses for V4.23; form b (p6_C_1b.c) has the same names with other types / shapes. */

struct diskinfo { unsigned int w[38]; };
struct frec { unsigned int flags; unsigned int w[5]; };
struct dirent82 { unsigned char name; unsigned char rest[81]; };
struct rec14 { unsigned char used; unsigned char rest[13]; };
struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
struct tmpl16 { unsigned int w[8]; };
struct vs { unsigned char pad[8]; unsigned long v8; unsigned long v12; };
struct xfer { unsigned char *start; unsigned char *end; long size; };

typedef unsigned char *ucp;
typedef unsigned char **ucpp;
typedef struct mq *mqp;

/* __near: the ROM reaches the cell with a 16-bit absolute operand; plain: 24-bit. */
extern struct diskinfo FileIO_DiskInfoInit, ram_25d6c;
extern struct frec FileIO_EmptyFileRecord, ram_25db8[];
extern struct dirent82 FileIO_DirListEntryTemplate, ram_25eb2[];
extern struct rec14 ram_2723c[];
extern unsigned char ram_25ec0[];
extern int ram_25ea8, ram_271ea, ram_271ec, ram_271ee, FILE_LIST_LAST, ram_272c8, ram_272ca;
extern char ram_25db6;
extern char ram_25cec[], ram_27312[][32];
extern long ram_27416;
extern char ram_27412, ram_27414;
extern unsigned char __near SEQ_TRACK_ASSIGN[];
extern unsigned char __near SEQ_TRACK_TABLE[];
extern unsigned char __near ram_d56;
extern unsigned char __near ram_d54;
extern unsigned char __near SEQ_EDIT_FLAGS;
extern unsigned int Demo_PartBitMask[];
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near ram_bd18;
extern unsigned char __near ram_bd1c;
extern unsigned char __near ram_bd00;
extern unsigned char __near ram_bd02;
extern unsigned char __near ram_bd04;
extern unsigned char __near ram_bd06;
extern unsigned char __near ram_bd08;
extern unsigned char __near ram_bd0a;
extern unsigned char __near ram_bd0c;
extern unsigned char __near ram_bd0e;
extern unsigned char __near ram_bd10;
extern unsigned char __near ram_bd12;
extern unsigned char __near ram_bd14;
extern unsigned char __near ram_bd16;
extern struct vs __near ram_bcbc;
extern struct vs __near ram_bcdc;
extern unsigned int __near INTERCPU_XFER_COUNT;
extern ucp __near INTERCPU_XFER_PTR;
extern unsigned char INTER_CPU_COMM_LATCHES;
extern ucpp __near PART_RECORD_PTRS;
extern unsigned char SndParam_PresetBanks[];
extern mqp __near ram_bc5c;
extern mqp __near MIDISEQ_ACTIVE_BLOCK_PTR;
extern unsigned char *PanelVari_PartRecordPtrs[];
extern unsigned int __near ram_11f5;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char __near PANEL_GM[];
extern unsigned char __near ram_b7f0;
extern unsigned char ram_272d0;
extern unsigned char SEQ_SONG_SLOTS[];
extern char ram_272d2[];
extern struct tmpl16 ArpQueue_InitTemplate;
extern unsigned char __near LIVE_PANEL_BLOCK;
extern unsigned char __near ram_ffbe;
extern unsigned char __near SEQ_SONG_RECORD;
extern unsigned char ram_1e0000, MSP_SETTINGS__BASE_ADDR, ram_1e8820, ram_1e8b00;
extern unsigned char ram_94860, ram_95bc0, ram_1ed350;
extern unsigned char __near ram_bc68[];
extern unsigned char __near ram_bc64[];
extern unsigned char __near PANEL_PART_RT1;
extern unsigned char PANEL_RECALL_BACKUP[];

void FileIO_InitRecordTable(void)
{
    struct frec *p, *e;
    struct dirent82 *q, *f;
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
    if (s[0] != 0) do {
        if ((d[i] = s[i]) == '\\') last = i;
        i++;
    } while (s[i] != 0);
    if (last > 0) d[last + 1] = 0;
    else *d = 0;
}

void Demo_ScanActivePartChannels(void)
{
    unsigned char i;
    i = 0;
    do {
        if (SEQ_TRACK_ASSIGN[i] == 16) {
            if ((Demo_PartBitMask[i] & SEQ_TRACK_MASK) != 0 && (SEQ_TRACK_TABLE[i * 3] & 0x80) != 0) {
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

int ValidateFileRange(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_25eb2[i - b].name == 0) return 2;
    return 0;
}

int FileIO_ValidateModeAndRange(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i > ram_272ca) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_2723c[i - b].used == 0) return 2;
    return 0;
}

int ValidateFileRangeAlt(int i)
{
    char m = ram_25db6;
    int b;
    if ((m != 6 && m != 7) || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_25eb2[i - b].name == 0) return 2;
    return 0;
}

int ValidateFileRangeType5(int i)
{
    int b;
    if (ram_25db6 != 5 || i < 0 || i > ram_271ec) return -1;
    b = ram_271ee;
    if (i < b || i > FILE_LIST_LAST) return 1;
    if (ram_25ec0[(i - b) * 82] == 0) return 2;
    return 0;
}

int ValidateFileSelectionIndex(int i)
{
    char m = ram_25db6;
    if ((m != 2 && m != 3 && m != 4) || i < 0 || i >= 20) return -1;
    return 0;
}

void MidiSeq_CheckSyncDirty(void)
{
    unsigned char *p = &ram_bd1c;
    if (ram_bd18 & 0x40) {
        if (ram_bd00 == ram_bd02 && ram_bd04 == ram_bd06 && ram_bd08 == ram_bd0a) return;
    } else {
        if (ram_bd0c == ram_bd0e && ram_bd10 == ram_bd12 && ram_bd14 == ram_bd16) return;
    }
    *p |= 0x40;
}

void MidiSeq_UpdateVolumeScale(void)
{
    unsigned char *p = &ram_bd1c;
    struct vs *q;
    unsigned long v;
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

void Audio_DMA_Transfer(void)
{
    unsigned int c = INTERCPU_XFER_COUNT;
    unsigned long n = c;
    unsigned long i;
    unsigned char d;
    if (c == 0) n = 0x10000;
    i = 0;
    if (n > 0) do {
        INTER_CPU_COMM_LATCHES = *INTERCPU_XFER_PTR++;
        d = 0;
        do d++; while (d < 3);
        i++;
    } while (i < n);
}

unsigned char MidiChan_DequeueVoiceEntry(struct mq *q)
{
    unsigned char **pp = &q->rd;
    unsigned char c = 0xff;
    if (**pp != 0xff) c = *(*pp)++;
    return c;
}

void MidiChan_NibbleLookup_Data(struct mq *q, unsigned char *s, unsigned int n)
{
    unsigned char **w;
    if (n--) {
        w = &q->wr;
        do *(*w)++ = *s++; while (n--);
    }
    *q->wr = 0xff;
}

void ArpQueue_Enqueue(unsigned char *s, unsigned int n)
{
    struct mq *q;
    unsigned char **w;
    if (n--) {
        q = ram_bc5c;
        w = &q->wr;
        do {
            *(*w)++ = *s++;
            q->count++;
        } while (n--);
    }
    *ram_bc5c->wr = 0xff;
}

void VoiceQueue_Append(unsigned char c)
{
    *MIDISEQ_ACTIVE_BLOCK_PTR->wr++ = c;
    *MIDISEQ_ACTIVE_BLOCK_PTR->wr = 0xff;
    if (c == 0xf0) MIDISEQ_ACTIVE_BLOCK_PTR->count = 1;
    else MIDISEQ_ACTIVE_BLOCK_PTR->count++;
}

unsigned char MIDI_PackNibbleParam(struct mq *q)
{
    unsigned char **pp = &q->p6;
    unsigned char h = *(*pp)++ << 4;
    return h | (*(*pp)++ & 0xf);
}

void ArpQueue_InitBuffer(struct mq *q, struct tmpl16 *t)
{
    unsigned char *b;
    q->count = 0;
    b = q->buf;
    q->rd = b;
    q->p6 = b;
    q->wr = b;
    *b = 0xff;
    *t = ArpQueue_InitTemplate;
}

unsigned char Part_LookupTableEntry(unsigned char p, unsigned char i)
{
    unsigned char *r = PART_RECORD_PTRS[p];
    if (r == (unsigned char *)0xffffffff) return 0;
    return r[i];
}

void Part_ProcessEntry_Data(unsigned char *s, unsigned int n, unsigned char *d)
{
    if (n--) do *d++ = *s++; while (n--);
}

unsigned char *SndParam_GetBlockPointer(unsigned char a)
{
    if (a < 0x19) return SndParam_PresetBanks + a * 0xea;
    switch (a) {
    default: return 0;
    case 0x1b: return (unsigned char *)0x3d3010;
    case 0x1c: return (unsigned char *)0x3d3110;
    case 0x1d: return (unsigned char *)0x3d3210;
    }
}

int ParseTwoDigitFileNum(char *s)
{
    char c, v;
    if (s[0] < '0' || s[0] > '2') return -1;
    c = s[1];
    if (c < '0' || c > '9') return -1;
    v = (s[0] - '0') * 10 + (c - '0');
    if (v < 1 || v > 20) return -1;
    return v - 1;
}

int DataBuf_CheckFormatPair(char *p)
{
    char c = p[4];
    p += 5;
    if (c == 'M' && p[0] == '4') return 1;
    if (c == 'M' && p[0] == '6') return 2;
    if (c == 'N' && p[0] == 'N') return 3;
    return -1;
}

int DataBuf_CheckSubFormat(unsigned char *p)
{
    unsigned char *q = p + 6;
    unsigned char a = p[5];
    if (a == 1 && *q == 6) return 1;
    if (a == 1 && *q == 7) return 2;
    if (a == 1 && *q == 3) return 3;
    return -1;
}

int FileIO_Search_SkipEntry(char *a, char *b, int n)
{
    char *p = a;
    char c;
    while (n != 0 && *b == *p) {
        if (*p == 0) return 0;
        p++;
        b++;
        n--;
    }
    c = 0;
    if (n != 0) c = *p - *b;
    return c;
}

void VoiceData_ZeroFillAll(void)
{
    unsigned char **p = PanelVari_PartRecordPtrs;
    unsigned char **e = p + 16;
    unsigned char *d;
    unsigned char n;
    do {
        d = *p;
        n = d[-1];
        if (n--) do *d++ = 0; while (n--);
        p++;
    } while (p < e);
}

void SoundParam_ApplyBit15Toggle(void)
{
    unsigned char *p;
    unsigned char *q;
    if (!(ram_11f5 & 0x8000)) return;
    p = PANEL_STYLE;
    p[8] = ram_11f5;
    q = p + 9;
    *q &= ~1;
    *q |= (ram_11f5 >> 8) & 1;
}

unsigned char FileIO_GetRecordAttr_Check(void)
{
    int i = ram_25ea8;
    if (i < 0 || i >= 20) return 0;
    return ram_272d0;
}

unsigned int CheckFileSystemStatus(void)
{
    int i = ram_25ea8;
    if (i < 0 || i >= 20) return 0;
    return ram_25db8[i].flags;
}

void SndParam_ApplyModeSpecific(void)
{
    unsigned char m = ram_b7f0;
    unsigned char *p;
    if (m == 2) return;
    p = PANEL_GM + 3;
    switch (m) {
    case 1:
        *p &= 0xf8;
        *p |= 4;
        break;
    case 0:
        *p &= 0xf8;
        break;
    }
}

void FileIO_GetRecordType_Extended(unsigned char *s)
{
    if (*s == 0) return;
    do {
        if (*s == 0x7e) *s = 0x5f;
        else if (*s < 0x20) *s = 0x20;
        s++;
    } while (*s != 0);
}

unsigned int Voice_GetPresetFieldWord(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    return *(unsigned int *)(p + 30);
}

unsigned char *Demo_GetPresetBaseForPartExt(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    return p + 208;
}

unsigned char *Demo_GetPresetBaseForPart(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    return p + 2048;
}

unsigned char *Voice_GetPresetFieldAddr(unsigned char i)
{
    unsigned char *p;
    if (((long *)0x9c4000)[i] != 0) p = (unsigned char *)0x69800;
    else p = SEQ_SONG_SLOTS;
    return p + 32;
}

void FileIO_FindPathSeparator(char *s)
{
    char *d = ram_272d2;
    int n = 0;
    char c;
    while ((c = *s) != '\\' && n < 31) {
        *d++ = c;
        n++;
        s++;
    }
    *d = '\\';
}

void FileIO_BuildFilePath(char *d, char *s)
{
    if (*d != 0) do d++; while (*d != 0);
    if (*s != 0) do *d++ = *s++; while (*s != 0);
    *d = 0;
}

long *TableData_ROM_Verify(long *p, long *end)
{
    if (*p == -1) do {
        p += 16;
        if (p == end) return 0;
    } while (*p == -1);
    return p;
}

void MidiChan_ClearStorageFields(void)
{
    unsigned char *p = ram_bc68;
    p[0] = 0xff;
    p[1] = 0xff;
    p[2] = 0xff;
    p = ram_bc64;
    p[0] = 0xff;
    p[1] = 0xff;
    p[2] = 0xff;
}

void TGReg_ClearTerminator(void)
{
    PANEL_RECALL_BACKUP[(long)&PANEL_PART_RT1 - 0xf9b4] = 0xff;
}

void MidiPkt_SetXferTotal_Panel(struct xfer *x)
{
    long n;
    x->start = &LIVE_PANEL_BLOCK;
    n = &ram_ffbe - &LIVE_PANEL_BLOCK + 0x12cb2;
    x->end = x->start + n;
    x->size = n;
}

void MidiPkt_SetXferBlock_LivePanel(struct xfer *x)
{
    unsigned char *p = &LIVE_PANEL_BLOCK;
    long n;
    x->start = p;
    n = &ram_ffbe - p + 2;
    x->end = p + n;
    x->size = n;
}

void MidiPkt_SetXferBlock_SoundRamData(struct xfer *x)
{
    x->start = &ram_1e0000 + 16;
    x->size = 0x729a;
    x->end = x->start + 0x729a;
}

void MidiPkt_SetXferTotal_SoundRam(struct xfer *x)
{
    x->start = &ram_1e0000;
    x->size = 0x72aa;
    x->end = x->start + 0x72aa;
}

void MidiPkt_SetXferBlock_SoundRamId(struct xfer *x)
{
    x->start = &ram_1e0000;
    x->size = 16;
    x->end = x->start + 16;
}

void MidiPkt_SetXferBlock_AccompAreaHeader(struct xfer *x)
{
    unsigned char *p = &MSP_SETTINGS__BASE_ADDR;
    long n;
    x->start = p;
    n = &ram_1e8820 - p;
    x->end = p + n;
    x->size = n;
}

void MidiPkt_SetXferBlock_AccompBankTables(struct xfer *x)
{
    unsigned char *p = &ram_1e8820;
    long n;
    x->start = p;
    n = &ram_1e8b00 - p;
    x->end = p + n;
    x->size = n;
}

void MidiPkt_SetXferBlock_StyleImageTables(struct xfer *x)
{
    unsigned char *p = &ram_94860;
    long n;
    x->start = p;
    n = &ram_95bc0 - p;
    x->end = p + n;
    x->size = n;
}

void MidiPkt_SetXferBlock_PanelMemories(struct xfer *x)
{
    x->end = (x->start = &ram_1ed350) + 0x12cb0;
    x->size = 0x12cb0;
}

void MidiPkt_SetXferBlock_SongSlots(struct xfer *x)
{
    x->end = (x->start = SEQ_SONG_SLOTS) + 0x5000;
    x->size = 0x5000;
}

void MidiPkt_SetXferBlock_CurrentSong(struct xfer *x)
{
    x->end = (x->start = &SEQ_SONG_RECORD) + 0x800;
    x->size = 0x800;
}
