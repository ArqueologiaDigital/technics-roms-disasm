/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function at -Xr (notes/cc900-c-subcpu-2026-11-16/);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   cc900-options: -Xr */
extern int __near ram_293e;

struct tvf { char pad[66]; int a; int b; };
struct zone { char pad[6]; int base; char pad2[2]; int out; };
struct dl { struct dl *next; struct dl *prev; };

void DList_Unlink_SelfLink(struct dl *p)
{
    struct dl *n = p->next;
    struct dl *q = p->prev;
    q->next = n;
    n->prev = q;
    p->next = p;
    p->prev = p;
}

unsigned char BitTest_Bit0_L(unsigned char a)
{
    if (a & 1) return 1;
    return 0;
}

unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, int k) { return t[(k & 0x7f00) >> 8]; }

int Int_ClampSignedToRange(int a, int hi, int lo)
{
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    return a;
}

int TVF_Clamp_Cutoff(int a)
{
    if (a > 0x78) a = 0x78;
    else if (a < 0) a = 0;
    return a;
}

int TVF_Bias_Clamp_Amount(int a)
{
    a += 0x18;
    if (a > 0x78) a = 0x78;
    return a;
}

void TVF_Set_Bypass(struct tvf *p) { p->a = 0x17f; p->b = 0x7f7f; }

int ClampS16_WA_Short(int a, int hi, int lo)
{
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    return a;
}

void Pitch_Apply_Zone_Trim(struct zone *p) { p->out = p->base + ram_293e; }

extern unsigned char Detune_Scale_Curve[];

unsigned int Detune_ScaleUnsigned(unsigned int a) { a = Detune_Scale_Curve[(unsigned char)a]; return a; }

#define B(p, o) (*(unsigned char *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char __near ram_27e6;
extern unsigned int __near ram_27e7;
extern unsigned char Voice_StealPoolOrder[];
extern unsigned char Instrument_OctaveShift_Semitones[];
extern unsigned char ram_41322[];
extern unsigned char ram_41342[];
extern unsigned char ram_41389[];
extern unsigned char __near ram_210b[];
extern int ram_4518c;
extern int ram_45190;
extern int ram_45192;
extern int ram_45194;
extern int ram_45196;
extern int ram_4519e;
extern int ram_451a0;
extern int ram_451a2;
extern int ram_451a4;
extern int ram_451a6;
extern int ram_451a8;
extern int ram_451aa;
void WaveSel_Rebuild_PartCaches(int n, int a, int b);
void ToneGen_WriteLevelBurst(int n, unsigned char *blk);
void ToneGen_WriteVoiceParams(int n, unsigned char *blk);
void Voice_WriteChPanShift2(unsigned char *v, int s);
void Voice_WriteChPanShift(unsigned char *v, int s);
struct dl8 { char pad[8]; struct dl8 *next; struct dl8 *prev; };
struct dl16 { char pad[16]; struct dl16 *next; struct dl16 *prev; };
struct dl0 { struct dl0 *next; struct dl0 *prev; };

unsigned char BitTest_Bit0_L_v2(unsigned char a)
{
    if (a & 1) return 1;
    return 0;
}

unsigned char BitTest_Mode2_L(unsigned char a)
{
    if (a & 2) return 0;
    if (a & 1) return 1;
    return 0;
}

unsigned char BitTest_Mode2_L_v2(unsigned char a)
{
    if (a & 2) return 0;
    if (a & 1) return 1;
    return 0;
}

void DList_InsertAfter_Offsets0(struct dl0 *p, struct dl0 *q)
{
    struct dl0 *n, *r;
    n = p->next;
    r = p->prev;
    r->next = n;
    n->prev = r;
    r = q->prev;
    r->next = p;
    q->prev = p;
    p->next = q;
    p->prev = r;
}

void DList_InsertAfter_Offsets8(struct dl8 *p, struct dl8 *q)
{
    struct dl8 *n, *r;
    n = p->next;
    r = p->prev;
    r->next = n;
    n->prev = r;
    r = q->prev;
    r->next = p;
    q->prev = p;
    p->next = q;
    p->prev = r;
}

void DList_Relink_Adjacent_Offsets16(struct dl16 *p, struct dl16 *q)
{
    struct dl16 *n, *r;
    n = p->next;
    r = p->prev;
    r->next = n;
    n->prev = r;
    r = q->prev;
    r->next = p;
    q->prev = p;
    p->next = q;
    p->prev = r;
}

void DList_Unlink_SelfLink_Offsets16(struct dl16 *p)
{
    struct dl16 *n = p->next;
    struct dl16 *q = p->prev;
    q->next = n;
    n->prev = q;
    p->next = p;
    p->prev = p;
}

void DList_Unlink_SelfLink_Offsets8(struct dl8 *p)
{
    struct dl8 *n = p->next;
    struct dl8 *q = p->prev;
    q->next = n;
    n->prev = q;
    p->next = p;
    p->prev = p;
}

int Detune_ScaleSymmetric(int a)
{
    if (a < 0) {
        a = ~a + 1;
        if (a > 0x32) a = 0x32;
        a = Detune_Scale_Curve[(unsigned char)a];
        a = ~a + 1;
    } else {
        if (a > 0x32) a = 0x32;
        a = Detune_Scale_Curve[(unsigned char)a];
    }
    return a;
}

unsigned char ExtVoice_Lookup_SlotFallback(int g)
{
    unsigned char *p;
    unsigned char r;
    p = ram_210b;
    switch (g & 3) {
    case 0: r = p[0]; break;
    case 1: r = p[4]; break;
    case 2: r = p[8]; if (r > 0xc0) r = p[4]; break;
    case 3: r = p[8]; break;
    }
    return r;
}

void Instrument_LookupProgram_HiNibble(unsigned char part)
{
    unsigned char n;
    n = ((*(unsigned char **)&ram_41322[part * 287])[42] & 0xf0) >> 4;
    ram_41389[part * 287] = Instrument_OctaveShift_Semitones[n];
}

void Instrument_LookupProgram_LoNibble(unsigned char part)
{
    unsigned char n;
    n = (*(unsigned char **)&ram_41322[part * 287])[42] & 0xf;
    ram_41389[part * 287] = Instrument_OctaveShift_Semitones[n];
}

void MIDI_Backlog_Publish(unsigned int a) { ram_27e7 = a; }

unsigned char Quad_Decode_A_To_L(unsigned char a)
{
    unsigned char r;
    if (a < 0x40) r = 0;
    else if (a < 0x80) r = 4;
    else if (a < 0xc0) r = 8;
    else r = 0;
    return r;
}

void RingBuf_CheckOffset_ClearFlags(unsigned char *p)
{
    if (ram_27e6 != 0) {
        if (ram_27e7 >= 48) { p[3] &= 0x7f; p[4] &= 0x7f; p[5] &= 0x7f; }
        else if (ram_27e7 >= 32) { p[4] &= 0x7f; p[5] &= 0x7f; }
    } else {
        if (ram_27e7 >= 80) { p[3] &= 0x7f; p[4] &= 0x7f; p[5] &= 0x7f; }
        else if (ram_27e7 >= 64) { p[4] &= 0x7f; p[5] &= 0x7f; }
    }
}

void RingBuf_SetOffsetLo(unsigned char a) { ram_27e6 = a; }

unsigned char Velocity_Select_Split_Zone(unsigned char a, unsigned char *t)
{
    unsigned char r;
    a &= 0x7f;
    if (a > t[0]) {
        if (a > t[1]) {
            if (a > t[2]) r = 3;
            else r = 2;
        } else r = 1;
    } else r = 0;
    return r;
}

unsigned char Velocity_Select_Split_Zone_Alt(unsigned char a, unsigned char *t)
{
    unsigned char r;
    a &= 0x7f;
    if (a > t[0]) {
        if (a > t[1]) {
            if (a > t[2]) r = 3;
            else r = 2;
        } else r = 1;
    } else r = 0;
    return r;
}

int Voice_Clamp_Byte_HL(int a)
{
    if ((unsigned int)a > 0xff) a = 0xff;
    else if (a < 0) a = 0;
    return a;
}

void *Voice_FindStealCandidate(unsigned char *p)
{
    void **q;
    unsigned char *s;
    q = (void **)(p + 2);
    for (s = Voice_StealPoolOrder; *s != 0xff; s++)
        if (q[*s] != 0) return q[*s];
    return 0;
}

void Voice_Level_ClearAllOutputRegs(unsigned char *v)
{
    unsigned char *t = P(v, 23);
    ram_4519e = 0;
    ram_45196 = 0;
    ram_451a0 = 0;
    ram_451a2 = 0;
    ram_451a4 = 0;
    ram_451a6 = 0;
    ram_451a8 = 0;
    ram_451aa = 0;
    ram_45190 = 0;
    ram_45192 = 0;
    if (ram_41342[B(v, 4) * 287] == 1) SW(v, 43) = 0;
    else if (ram_41342[B(v, 4) * 287] == 2) SW(v, 43) = 0x7f;
    else SW(v, 43) = *t;
    ram_4518c = SW(v, 43);
    ram_45194 = 0;
}

extern unsigned char __near ram_112d[];
extern long __near ram_1345;

void *Voice_Find_Candidate(unsigned char **p, unsigned char *s)
{
    void **q2;
    void **q1;
    unsigned char k;
    if (ram_1345 != 0) return (void *)ram_1345;
    q2 = (void **)ram_112d;
    q2 = (void **)((unsigned char *)q2 + 482);
    q1 = (void **)(*p + 2);
    for (; *s != 0xff; s++) {
        if (*s & 0x80) {
            k = *s & 0x7f;
            if (q2[k] != 0) return q2[k];
        } else {
            if (q1[*s] != 0) return q1[*s];
        }
    }
    return 0;
}
