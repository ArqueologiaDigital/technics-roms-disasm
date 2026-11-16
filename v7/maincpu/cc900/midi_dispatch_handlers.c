/* Functions of midi/midi_dispatch_handlers.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

struct mq { unsigned int count; unsigned char *rd; unsigned char *p6; unsigned char *wr; unsigned char buf[2]; };
struct tmpl16 { unsigned int w[8]; };
struct xfer { unsigned char *start; unsigned char *end; long size; };
typedef struct mq *mqp;
extern unsigned char __near ram_bc7c;
extern unsigned char __near ram_bc80;
extern unsigned char __near ram_bc64;
extern unsigned char __near ram_bc66;
extern unsigned char __near ram_bc68;
extern unsigned char __near ram_bc6a;
extern unsigned char __near ram_bc6c;
extern unsigned char __near ram_bc6e;
extern unsigned char __near ram_bc70;
extern unsigned char __near ram_bc72;
extern unsigned char __near ram_bc74;
extern unsigned char __near ram_bc76;
extern unsigned char __near ram_bc78;
extern unsigned char __near ram_bc7a;
extern mqp __near ram_bbc0;
extern mqp __near MIDISEQ_ACTIVE_BLOCK_PTR;
extern unsigned int __near ram_11f5;
extern unsigned char __near PANEL_STYLE[];
extern unsigned char SEQ_SONG_SLOTS[];
extern struct tmpl16 ArpQueue_InitTemplate;
extern unsigned char __near SEQ_SONG_RECORD;
extern unsigned char ram_1e0000, MSP_SETTINGS__BASE_ADDR, ram_1e8820, ram_1e8b00;
extern unsigned char ram_94860, ram_95bc0, ram_1ed350;
extern unsigned char __near ram_bbcc[];
extern unsigned char __near ram_bbc8[];
extern unsigned char __near PANEL_PART_RT1;
extern unsigned char PANEL_RECALL_BACKUP[];

void ArpQueue_Enqueue(unsigned char *s, unsigned int n)
{
    struct mq *q;
    unsigned char **w;
    if (n--) {
        q = ram_bbc0;
        w = &q->wr;
        do {
            *(*w)++ = *s++;
            q->count++;
        } while (n--);
    }
    *ram_bbc0->wr = 0xff;
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

int DataBuf_CheckSubFormat(unsigned char *p)
{
    unsigned char *q = p + 6;
    unsigned char a = p[5];
    if (a == 1 && *q == 6) return 1;
    if (a == 1 && *q == 7) return 2;
    if (a == 1 && *q == 3) return 3;
    return -1;
}

void MidiChan_ClearStorageFields(void)
{
    unsigned char *p = ram_bbcc;
    p[0] = 0xff;
    p[1] = 0xff;
    p[2] = 0xff;
    p = ram_bbc8;
    p[0] = 0xff;
    p[1] = 0xff;
    p[2] = 0xff;
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

void MidiPkt_SetXferBlock_CurrentSong(struct xfer *x)
{
    x->end = (x->start = &SEQ_SONG_RECORD) + 0x800;
    x->size = 0x800;
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

void MidiPkt_SetXferBlock_SoundRamId(struct xfer *x)
{
    x->start = &ram_1e0000;
    x->size = 16;
    x->end = x->start + 16;
}

void MidiPkt_SetXferTotal_SoundRam(struct xfer *x)
{
    x->start = &ram_1e0000;
    x->size = 0x72aa;
    x->end = x->start + 0x72aa;
}

void MidiSeq_CheckSyncDirty(void)
{
    unsigned char *p = &ram_bc80;
    if (ram_bc7c & 0x40) {
        if (ram_bc64 == ram_bc66 && ram_bc68 == ram_bc6a && ram_bc6c == ram_bc6e) return;
    } else {
        if (ram_bc70 == ram_bc72 && ram_bc74 == ram_bc76 && ram_bc78 == ram_bc7a) return;
    }
    *p |= 0x40;
}

void Part_ProcessEntry_Data(unsigned char *s, unsigned int n, unsigned char *d)
{
    if (n--) do *d++ = *s++; while (n--);
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

void TGReg_ClearTerminator(void)
{
    PANEL_RECALL_BACKUP[(long)&PANEL_PART_RT1 - 0xf9b4] = 0xff;
}

void VoiceQueue_Append(unsigned char c)
{
    *MIDISEQ_ACTIVE_BLOCK_PTR->wr++ = c;
    *MIDISEQ_ACTIVE_BLOCK_PTR->wr = 0xff;
    if (c == 0xf0) MIDISEQ_ACTIVE_BLOCK_PTR->count = 1;
    else MIDISEQ_ACTIVE_BLOCK_PTR->count++;
}

struct cmp16 { unsigned char p0[2]; unsigned char b2; unsigned char h3 : 1; unsigned char r3 : 3; unsigned char v3 : 4;
               unsigned char b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15; };
extern unsigned char __near PANEL_GM[];
extern unsigned char __near ram_b754;
extern unsigned char __near LIVE_PANEL_BLOCK;
extern unsigned char __near ram_ffbe;
extern unsigned char ram_1e0000;

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

void MidiPkt_SetXferBlock_SoundRamData(struct xfer *x)
{
    x->start = (unsigned char *)((long)&ram_1e0000 + 16);
    x->size = 0x729a;
    x->end = x->start + 0x729a;
}

void SndParam_ApplyModeSpecific(void)
{
    unsigned char m = ram_b754;
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

/* cc900-name: Param_SignExt_H3_Helper=Param_SignExtendReturn_Helper3_Helper */
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

unsigned char Param_SignExt_H3_Helper(unsigned char *p, unsigned int n)
{
    unsigned char s = 0;
    p++;
    n--;
    while (n--) s += *p++;
    return -s & 0x7f;
}

struct l7 { unsigned char h : 1; unsigned char v : 7; };
struct b6 { unsigned char h : 1; unsigned char f : 1; unsigned char r : 6; };
struct l4 { unsigned char h : 4; unsigned char v : 4; };
struct b10 { unsigned char r : 6; unsigned char b1 : 1; unsigned char b0 : 1; };
struct r8 { unsigned char h : 1; unsigned char b6 : 1; unsigned char b5 : 1; unsigned char b4 : 1;
            unsigned char b3 : 1; unsigned char b2 : 1; unsigned char b1 : 1; unsigned char b0 : 1; };
struct eq2 { unsigned char h : 2; unsigned char f54 : 2; unsigned char b3 : 1; unsigned char b2 : 1; unsigned char l : 2; };
extern unsigned int __near ram_b74e;

void DataBuf_CopyEQBlock7(unsigned char *s, unsigned char *d)
{
    ((struct eq2 *)(d + 2))->f54 = ((struct eq2 *)(s + 2))->f54;
    ((struct eq2 *)(d + 2))->b3 = ((struct eq2 *)(s + 2))->b3;
    ((struct eq2 *)(d + 2))->b2 = ((struct eq2 *)(s + 2))->b2;
    ((struct eq2 *)(d + 2))->l = ((struct eq2 *)(s + 2))->l;
    ((struct l7 *)(d + 3))->v = ((struct l7 *)(s + 3))->v;
    d[4] = s[4];
    ((struct l4 *)(d + 6))->v = ((struct l4 *)(s + 6))->v;
    if (ram_b74e == 2) d[5] = s[5];
}

void DataBuf_CopyReverbBlock6(unsigned char *s, unsigned char *d)
{
    ((struct r8 *)(d + 2))->b1 = ((struct r8 *)(s + 2))->b1;
    ((struct r8 *)(d + 2))->b0 = ((struct r8 *)(s + 2))->b0;
    ((struct r8 *)(d + 3))->b1 = ((struct r8 *)(s + 3))->b1;
    ((struct r8 *)(d + 4))->b6 = ((struct r8 *)(s + 4))->b6;
    ((struct r8 *)(d + 4))->b5 = ((struct r8 *)(s + 4))->b5;
    ((struct r8 *)(d + 4))->b4 = ((struct r8 *)(s + 4))->b4;
    ((struct r8 *)(d + 4))->b3 = ((struct r8 *)(s + 4))->b3;
    ((struct r8 *)(d + 4))->b2 = ((struct r8 *)(s + 4))->b2;
    ((struct r8 *)(d + 4))->b1 = ((struct r8 *)(s + 4))->b1;
    ((struct r8 *)(d + 4))->b0 = ((struct r8 *)(s + 4))->b0;
    ((struct r8 *)(d + 5))->b1 = ((struct r8 *)(s + 5))->b1;
    ((struct r8 *)(d + 5))->b0 = ((struct r8 *)(s + 5))->b0;
}

void VoiceParam_CopyBitfields_TypeC(unsigned char *s, unsigned char *d)
{
    ((struct b10 *)(d + 2))->b0 = ((struct b10 *)(s + 2))->b0;
    ((struct b10 *)(d + 2))->b1 = ((struct b10 *)(s + 2))->b1;
    ((struct b10 *)(d + 3))->b1 = ((struct b10 *)(s + 3))->b1;
    ((struct b10 *)(d + 5))->b0 = ((struct b10 *)(s + 7))->b0;
    ((struct b10 *)(d + 5))->b1 = ((struct b10 *)(s + 7))->b1;
}
