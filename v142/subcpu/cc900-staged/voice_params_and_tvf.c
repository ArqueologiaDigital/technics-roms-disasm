/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern int __near ram_293e;
struct tvf { char pad[66]; int a; int b; };
struct zone { char pad[6]; int base; char pad2[2]; int out; };
struct dl { struct dl *next; struct dl *prev; };

unsigned char BitTest_Bit0_L(unsigned char a)
{
    if (a & 1) return 1;
    return 0;
}

int ClampS16_WA_Short(int a, int hi, int lo)
{
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    return a;
}

void DList_Unlink_SelfLink(struct dl *p)
{
    struct dl *n = p->next;
    struct dl *q = p->prev;
    q->next = n;
    n->prev = q;
    p->next = p;
    p->prev = p;
}

int Int_ClampSignedToRange(int a, int hi, int lo)
{
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    return a;
}

void Pitch_Apply_Zone_Trim(struct zone *p) { p->out = p->base + ram_293e; }

int TVF_Bias_Clamp_Amount(int a)
{
    a += 0x18;
    if (a > 0x78) a = 0x78;
    return a;
}

int TVF_Clamp_Cutoff(int a)
{
    if (a > 0x78) a = 0x78;
    else if (a < 0) a = 0;
    return a;
}

void TVF_Set_Bypass(struct tvf *p) { p->a = 0x17f; p->b = 0x7f7f; }

unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, int k) { return t[(k & 0x7f00) >> 8]; }

extern unsigned char Detune_Scale_Curve[];

unsigned int Detune_ScaleUnsigned(unsigned int a) { a = Detune_Scale_Curve[(unsigned char)a]; return a; }

#define B(p, o) (*(unsigned char *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern unsigned char __near RingBuf_OffsetLo;
extern unsigned int __near MIDI_BacklogCount;
extern unsigned char Voice_StealPoolOrder[];
extern unsigned char Instrument_OctaveShift_Semitones[];
extern unsigned char ram_4136e[];
extern unsigned char ram_4138e[];
extern unsigned char ram_413d5[];
extern unsigned char __near ram_210b[];
extern int ram_451d8;
extern int ram_451dc;
extern int ram_451de;
extern int ram_451e0;
extern int ram_451e2;
extern int ram_451ea;
extern int ram_451ec;
extern int ram_451ee;
extern int ram_451f0;
extern int ram_451f2;
extern int ram_451f4;
extern int ram_451f6;
void Voice_Level_ClearAllOutputRegs(unsigned char *v);
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
    n = ((*(unsigned char **)&ram_4136e[part * 287])[42] & 0xf0) >> 4;
    ram_413d5[part * 287] = Instrument_OctaveShift_Semitones[n];
}

void Instrument_LookupProgram_LoNibble(unsigned char part)
{
    unsigned char n;
    n = (*(unsigned char **)&ram_4136e[part * 287])[42] & 0xf;
    ram_413d5[part * 287] = Instrument_OctaveShift_Semitones[n];
}

void MIDI_Backlog_Publish(unsigned int a) { MIDI_BacklogCount = a; }

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
    if (RingBuf_OffsetLo != 0) {
        if (MIDI_BacklogCount >= 48) { p[3] &= 0x7f; p[4] &= 0x7f; p[5] &= 0x7f; }
        else if (MIDI_BacklogCount >= 32) { p[4] &= 0x7f; p[5] &= 0x7f; }
    } else {
        if (MIDI_BacklogCount >= 80) { p[3] &= 0x7f; p[4] &= 0x7f; p[5] &= 0x7f; }
        else if (MIDI_BacklogCount >= 64) { p[4] &= 0x7f; p[5] &= 0x7f; }
    }
}

void RingBuf_SetOffsetLo(unsigned char a) { RingBuf_OffsetLo = a; }

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
    ram_451ea = 0;
    ram_451e2 = 0;
    ram_451ec = 0;
    ram_451ee = 0;
    ram_451f0 = 0;
    ram_451f2 = 0;
    ram_451f4 = 0;
    ram_451f6 = 0;
    ram_451dc = 0;
    ram_451de = 0;
    if (ram_4138e[B(v, 4) * 287] == 1) SW(v, 43) = 0;
    else if (ram_4138e[B(v, 4) * 287] == 2) SW(v, 43) = 0x7f;
    else SW(v, 43) = *t;
    ram_451d8 = SW(v, 43);
    ram_451e0 = 0;
}

unsigned char ExtVoice_Fold_SlotNumber(unsigned char a, unsigned char g)
{
    unsigned char r;
    switch (g & 3) {
    case 0:
    case 1: r = a & 0x3f; break;
    case 2: r = (a - 0x40) & 0x7f; break;
    case 3: r = a & 0x7f; break;
    }
    return r;
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

#define W(p, o) (*(unsigned int *)((p) + (o)))
extern unsigned char __tiny ram_18;
extern volatile unsigned int ram_100000;
extern unsigned long __near ram_1040;
extern int ram_451ce;
extern unsigned char Voice_Colour_RowOffset_Table[];
extern unsigned char Voice_Colour_TransferCurves[];
extern unsigned char ram_41481[];
extern unsigned char ram_41485[];
extern unsigned char ram_41486[];
extern unsigned char ram_4308f[];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2127[];

int Pitch_Clamp_Into_Range(int a, unsigned char lo, unsigned char hi)
{
    int v;
    v = a;
    if (a & 0x8000) {
        if (v > -0x4000) v = 0;
        else v = 0x7fff;
    }
    if (v < ((int)lo << 8) + 0x80) v = ((int)lo << 8) + 0x80;
    else if (v > ((int)hi << 8) + 0x80) v = ((int)hi << 8) + 0x80;
    return v;
}

int Pitch_Fold_Octaves_Into_Range(int a, unsigned char lo, unsigned char hi)
{
    int v;
    v = a;
    while (v & 0x8000) {
        if (v > -0x4000) v += 0xc00;
        else v -= 0xc00;
    }
    while (v < ((int)lo << 8) + 0x80) v += 0xc00;
    while (v > ((int)hi << 8) + 0x80) v -= 0xc00;
    return v;
}

unsigned int Pitch_Saturate_15bit(unsigned int a)
{
    if ((int)a & 0x8000) {
        if (a > 0xc000) a = 0;
        else a = 0x7fff;
    }
    return a;
}

unsigned int ToneGen_Read_Register(unsigned int r)
{
    ram_18 &= 0x7f;
    ram_100000 = r;
    return ram_100000;
}

unsigned char VoiceRec_Decode2BitField(unsigned char n)
{
    unsigned char r;
    switch (*(unsigned int *)&ram_4308f[(int)n * 71] & 0xc0) {
    case 0: r = 0; break;
    case 0x40: r = 1; break;
    case 0x80: r = 2; break;
    case 0xc0: r = 3; break;
    }
    return r;
}

void VoiceRow_FetchPair_DE_WA(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = ram_2126[(int)a * 5];
    y = ram_2127[(int)a * 5];
    ram_2126[(int)y * 5] = x;
    ram_2127[(int)x * 5] = y;
    y = ram_2127[(int)c * 5];
    ram_2126[(int)y * 5] = a;
    ram_2127[(int)a * 5] = y;
    ram_2126[(int)a * 5] = c;
    ram_2127[(int)c * 5] = a;
}

void VoiceRow_FetchPair_WA_SP(unsigned char a)
{
    unsigned char x, y;
    x = ram_2126[(int)a * 5];
    y = ram_2127[(int)a * 5];
    ram_2126[(int)y * 5] = x;
    ram_2127[(int)x * 5] = y;
    ram_2126[(int)a * 5] = a;
    ram_2127[(int)a * 5] = a;
}

unsigned int Voice_Colour_LookupIndex(unsigned int a, unsigned char b)
{
    b = (b & 0xe0) >> 5;
    return Voice_Colour_TransferCurves[((int)b << 8) + Voice_Colour_RowOffset_Table[a]];
}

void Voice_Env_UpdateVelocityCounters(unsigned char a)
{
    unsigned long d;
    d = ram_1040 - *(unsigned long *)&ram_41481[a * 287];
    if (d != 0) {
        if (d < 0x19) {
            switch (++*(ram_41485 + a * 287)) {
            case 0: ram_41486[a * 287] = 0; break;
            case 1: ram_41486[a * 287] = 0x10; break;
            default: ram_41486[a * 287] = 0x20; break;
            }
        } else {
            ram_41485[a * 287] = 0;
            ram_41486[a * 287] = 0;
        }
    }
    *(unsigned long *)&ram_41481[a * 287] = ram_1040;
}

void WaveSel_Emit_ZoneRecord_S10(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += (int)i * 10;
    P(v, 15) = t;
    W(v, 1) |= 0x1000;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}

void WaveSel_Emit_ZoneRecord_S12(unsigned char *v, unsigned char *t, unsigned char i)
{
    int x;
    t += (int)i * 12;
    P(v, 15) = t;
    W(v, 1) |= 0x5000;
    ram_451ce = SW(t, 0);
    x = SW(t, 10);
    ram_293e = x;
}

void WaveSel_Emit_ZoneRecord_S13(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += (int)i * 13;
    P(v, 15) = t;
    W(v, 1) |= 0x3000;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}

void WaveSel_Emit_ZoneRecord_S15(unsigned char *v, unsigned char *t, unsigned char i)
{
    int x;
    t += (int)i * 15;
    P(v, 15) = t;
    W(v, 1) |= 0x7000;
    ram_451ce = SW(t, 0);
    x = SW(t, 13);
    ram_293e = x;
}

void WaveSel_Emit_ZoneRecord_S4(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += (int)i * 4;
    P(v, 15) = t;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}

void WaveSel_Emit_ZoneRecord_S6(unsigned char *v, unsigned char *t, unsigned char i)
{
    int x;
    t += (int)i * 6;
    P(v, 15) = t;
    W(v, 1) |= 0x4000;
    ram_451ce = SW(t, 0);
    x = SW(t, 4);
    ram_293e = x;
}

extern unsigned char ram_4424e[][27];
void Pitch_Apply_Partial_Detune(unsigned char *v);

void NoteState_ClearRecord(unsigned char i, unsigned char j)
{
    unsigned char *p;
    p = (unsigned char *)(ram_4424e + j) + (int)i * 9;
    p[1] = 0;
    p[2] = 0;
    p[3] = 0;
    p[4] = 0;
    p[0] = 0;
    p[5] = 0;
    p[7] = 0;
}

void Pitch_Apply_Partial_Detune(unsigned char *v)
{
    int d;
    d = SW(v, 6) + ram_293e;
    d += (int)(char)B(P(v, 23), 5) * 2;
    d += (char)B(P(v, 39), 33);
    d += SW(P(v, 35), 20);
    SW(v, 10) = d;
    if ((W(P(v, 35), 10) & 4) && (B(P(v, 19), 16) & 0x20)) W(v, 1) |= 0x400;
    else W(v, 1) &= ~0x400;
}
