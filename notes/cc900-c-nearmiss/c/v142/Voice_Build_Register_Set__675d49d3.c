/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_A_2c.c (2026-11-16-47-sub-r2)
   sha256 675d49d3eeeea79e327148ffdc5c5179606a08452f10204af09a37e964ae4c72 (name+funcs); compiled at -Xr */
/* lane_sub helper A, round 2, form c (third spellings): functions of the KN5000 sub-CPU payload v1.42 (v142/subcpu, core/05 and
   core/07).  Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.
   The 71-byte voice records (ram_4308e) and the 287-byte part records (ram_41368) have odd sizes and odd field
   offsets, which no cc900 struct has (int alignment 2), so they are read through char pointers. */

#define B(p, o) (*(unsigned char *)((p) + (o)))
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))

extern unsigned char __near ram_27e6;
extern unsigned int __near ram_27e7;
extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern int __near ram_293e;
extern int ram_451ce;
extern unsigned char ram_451cc[];
extern unsigned char Detune_Scale_Curve[];
extern unsigned char Voice_StealPoolOrder[];
extern unsigned char Voice_Selector_FieldSlot_Table[][3];
extern unsigned char Instrument_OctaveShift_Semitones[];
extern unsigned char Voice_DefaultToneRecord[];
extern unsigned char ram_41368[][287];
extern unsigned char ram_4136e[];
extern unsigned char ram_41381[];
extern unsigned char ram_41382[];
extern unsigned char ram_4138e[];
extern unsigned char ram_413d5[];
extern unsigned char ram_41472[];
extern unsigned char ram_41473[];
extern unsigned char ram_41474[];
extern unsigned char ram_41475[];
extern unsigned char ram_4308e[];
extern unsigned char ram_4308f[];
extern unsigned char ram_43094[];
extern unsigned char ram_4424e[][27];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2127[];
extern unsigned char __near ram_210b[];
extern unsigned char __near ram_112d[];
extern long __near ram_1345;
extern unsigned char ram_4134c;
extern int ram_451d2;
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

struct pkt { unsigned char op; unsigned char key[2]; unsigned char mask[2]; };
extern struct pkt __near ram_2a5e;

void NoteOn_RoutePacket(struct pkt *q);
void Voice_NoteState_Clear(int n);
void Voice_SetLFO_ActiveFlag(int n);
void WaveSel_Rebuild_PartCaches(int n, int a, int b);
void VoiceSlot_FullInit(int n);
void VoiceSlot_AltInit(int n);
void Voice_PortamentoTargets_SetAll(int n);
void Voice_Calc_LevelPair_Silence(unsigned char *v);
void ToneGen_WriteLevelBurst(int n, unsigned char *blk);
void ToneGen_WriteVoiceParams(int n, unsigned char *blk);
void Voice_ComputeVolume_CappedLFO(unsigned char *v);
void Voice_Calc_LevelPair_EGA(unsigned char *v);
void Voice_Calc_LevelPair_EGB(unsigned char *v);
void Voice_Calc_LevelPair_EGC(unsigned char *v);
void WaveSel_StageB_Build_Reg040(unsigned char *v);
void WaveSel_AddRandomEntryOffset(int *p);
void Pitch_Apply_Zone_Trim(unsigned char *v);
void Voice_Pitch_WriteOutputReg_Secondary(unsigned char *v);
void TVF_BuildEmit_Short_Dispatch(unsigned char *v);
void TVF_Emit_Registers_Type2(unsigned char *v);
void Voice_ComputePitchBend2(unsigned char *v);
void Voice_Build_GateCommand_NoPartial(unsigned char *v);
void Voice_Calc_LevelPair_FixedAtk(unsigned char *v);
void Voice_WriteChPanShift2(unsigned char *v, int s);
void Voice_Level_ClearAllOutputRegs(unsigned char *v);
void Voice_ComputePitch_Mono(unsigned char *v);
void Voice_ApplyPortamento2(unsigned char *v);
void Pitch_Apply_Partial_Detune(unsigned char *v);
void Pitch_Emit_Reg400(unsigned char *v);
void Voice_Level_ComputeTriplet(unsigned char *v);
void TVF_Build_Dispatch(unsigned char *v);
void TVF_Emit_Registers(unsigned char *v);
void Voice_StereoLevel_Compute(unsigned char *v);
void Voice_PortaLevel_Compute(unsigned char *v);
void ExtVoice_Build_SlotRegisters(unsigned char *v);
void Voice_SubVoice_ComputeAndTrigger(unsigned char *v);
void Voice2_UpdatePitch(unsigned char *v);
void Level_Build_Reg0C0(unsigned char *v);
void Voice_Build_GateCommand(unsigned char *v);
void Voice_Calc_LevelPair_PatchAtk(unsigned char *v);
void Voice_WriteChPanShift(unsigned char *v, int s);
void Voice_ComputePitch(unsigned char *v);
void Voice_ApplyPortamento(unsigned char *v);

/* ---- tiny ones ---- */

void RingBuf_SetOffsetLo(unsigned char a) { ram_27e6 = a; }

void MIDI_Backlog_Publish(unsigned int a) { ram_27e7 = a; }

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

void Voice_Slot_LoadPitchOffset_A(unsigned char *v) { SW(v, 13) += SW(P(v, 35), 270); }

void Voice_Slot_LoadPitchOffset_B(unsigned char *v) { SW(v, 13) += SW(P(v, 35), 272); }

unsigned int ToneGen_Read_Register(unsigned int r)
{
    ram_18 &= 0x7f;
    ram_100000 = r;
    return ram_100000;
}

/* ---- doubly linked lists ---- */

struct dl8 { char pad[8]; struct dl8 *next; struct dl8 *prev; };
struct dl16 { char pad[16]; struct dl16 *next; struct dl16 *prev; };
struct dl0 { struct dl0 *next; struct dl0 *prev; };

void DList_Unlink_SelfLink_Offsets8(struct dl8 *p)
{
    struct dl8 *n = p->next;
    struct dl8 *q = p->prev;
    q->next = n;
    n->prev = q;
    p->next = p;
    p->prev = p;
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

/* ---- clamps and small decoders ---- */

int Voice_Clamp_Byte_HL(int a)
{
    if ((unsigned int)a > 0xff) a = 0xff;
    else if (a < 0) a = 0;
    return a;
}

unsigned int Pitch_Saturate_15bit(unsigned int a)
{
    if ((a & 0x8000) != 0) {
        if (a > 0xc000) a = 0;
        else a = 0x7fff;
    }
    return a;
}

unsigned char Quad_Decode_A_To_L(unsigned char a)
{
    return a < 0x40 ? 0 : a < 0x80 ? 4 : a < 0xc0 ? 8 : 0;
}

unsigned char Velocity_Select_Split_Zone(unsigned char a, unsigned char *t)
{
    a &= 0x7f;
    return a > t[0] ? (a > t[1] ? (a > t[2] ? 3 : 2) : 1) : 0;
}

unsigned char Velocity_Select_Split_Zone_Alt(unsigned char a, unsigned char *t)
{
    a &= 0x7f;
    return a > t[0] ? (a > t[1] ? (a > t[2] ? 3 : 2) : 1) : 0;
}

unsigned char VoiceRec_Decode2BitField(unsigned char n)
{
    unsigned char r;
    switch (*(unsigned int *)(ram_4308f + n * 71) & 0xc0) {
    case 0: r = 0; break;
    case 0x40: r = 1; break;
    case 0x80: r = 2; break;
    case 0xc0: r = 3; break;
    }
    return r;
}

unsigned char ExtVoice_Fold_SlotNumber(unsigned char a, unsigned char g)
{
    unsigned char r;
    switch (g & 3) {
    case 0:
    case 1: r = a & 0x3f; break;
    case 2: r = a - 0x40; r &= 0x7f; break;
    case 3: r = a; r &= 0x7f; break;
    }
    return r;
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

void Voice_SignedClamp(unsigned char *p, char d, int hi, int lo)
{
    int v;
    v = *p + d;
    if (v > hi) v = hi;
    if (v < lo) v = lo;
    *p = v;
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

int Pitch_Clamp_Into_Range(int a, unsigned char lo, unsigned char hi)
{
    int v = a;
    if (a & 0x8000) {
        if (v > -0x4000) v = 0;
        else v = 0x7fff;
    }
    if (v < (lo << 8) + 0x80) v = (lo << 8) + 0x80;
    else if (v > (hi << 8) + 0x80) v = (hi << 8) + 0x80;
    return v;
}

int Pitch_Fold_Octaves_Into_Range(int a, unsigned char lo, unsigned char hi)
{
    int v;
    v = a;
    goto t1;
l1:
    if (v > -0x4000) v += 0xc00;
    else v -= 0xc00;
t1:
    if (v & 0x8000) goto l1;
    goto t2;
l2:
    v += 0xc00;
t2:
    if (v < (lo << 8) + 0x80) goto l2;
    goto t3;
l3:
    v -= 0xc00;
t3:
    if (v > (hi << 8) + 0x80) goto l3;
    return v;
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

unsigned int Voice_KeyIndex_Pack3Nibbles(unsigned int a)
{
    return ((a >> 8) & 0xf) * 81 + ((a >> 4) & 0xf) * 9 + (a & 0xf);
}

int Pan_ScaleWithVelocity(unsigned int a, unsigned char b, unsigned char lo, char s, unsigned char hi)
{
    int d;
    a = (a & 0x7f00) >> 8;
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    d = a - b;
    return (s * d) >> 5;
}

int Voice_Colour_ClampUpper(unsigned int a, unsigned char b, unsigned char lo, char s, unsigned char hi)
{
    int d;
    a = (a & 0x7f00) >> 8;
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    d = a - b;
    return (s * d) >> 5;
}

/* ---- note-on packets (NoteOn_RoutePacket) ---- */

#define PKW(q, o) (*(unsigned int *)((unsigned char *)(q) + (o)))

struct pkt *Voice_Query_AllChannels(void)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0;
    PKW(q, 1) = 0;
    PKW(q, 3) = 0x1fff;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_Query_PartVoices(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0;
    PKW(q, 1) = (unsigned int)part << 8;
    PKW(q, 3) = 0xff;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_AllocateForSustain(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0x40;
    PKW(q, 1) = (unsigned int)part << 8;
    PKW(q, 3) = 0x7f;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_Query_PartVoices_Mask7F(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0;
    PKW(q, 1) = (unsigned int)part << 8 | 0x80;
    PKW(q, 3) = 0x7f;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_AllocateForRelease(unsigned char part)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0x80;
    PKW(q, 1) = (unsigned int)part << 8 | 0x80;
    PKW(q, 3) = 0x7f;
    NoteOn_RoutePacket(q);
    return q;
}

struct pkt *Voice_Allocate(unsigned char part, unsigned char key)
{
    struct pkt *q = &ram_2a5e;
    q->op = 0x80;
    PKW(q, 1) = (unsigned int)part << 8 | key | 0x80;
    PKW(q, 3) = 0;
    NoteOn_RoutePacket(q);
    return q;
}

/* ---- wave-select zone records (voice +15 = record pointer, +1 = flags) ---- */

void WaveSel_Emit_ZoneRecord_S4(unsigned char *v, unsigned char *t, unsigned char i)
{
    t = t + (i << 2);
    P(v, 15) = t;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}

void WaveSel_Emit_ZoneRecord_S6(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += i * 6;
    P(v, 15) = t;
    W(v, 1) |= 0x4000;
    ram_451ce = SW(t, 0);
    ram_293e = SW(t, 4);
}

void WaveSel_Emit_ZoneRecord_S10(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += i * 10;
    P(v, 15) = t;
    W(v, 1) |= 0x1000;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}

void WaveSel_Emit_ZoneRecord_S12(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += i * 12;
    P(v, 15) = t;
    W(v, 1) |= 0x5000;
    ram_451ce = SW(t, 0);
    ram_293e = SW(t, 10);
}

void WaveSel_Emit_ZoneRecord_S13(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += i * 13;
    P(v, 15) = t;
    W(v, 1) |= 0x3000;
    ram_451ce = SW(t, 0);
    ram_293e = 0;
}

void WaveSel_Emit_ZoneRecord_S15(unsigned char *v, unsigned char *t, unsigned char i)
{
    t += i * 15;
    P(v, 15) = t;
    W(v, 1) |= 0x7000;
    ram_451ce = SW(t, 0);
    ram_293e = SW(t, 13);
}

/* ---- part records (287 bytes from ram_41368) ---- */

void Voice_PortamentoTarget_SetSlot(unsigned char part, unsigned char slot)
{
    P(&ram_41368[part][slot * 37 + 0x6e], 4) = Voice_DefaultToneRecord;
}

void Voice_UpdateFlagsFromSlot(unsigned char part)
{
    unsigned int *q, *f;
    q = (unsigned int *)(ram_41368[part] + 258);
    f = (unsigned int *)(ram_41368[part] + 2);
    if (q[0] != 0) *f |= 1; else *f &= ~1;
    if (q[1] != 0) *f |= 2; else *f &= ~2;
    if (q[2] != 0) *f |= 4; else *f &= ~4;
    if (q[3] != 0) *f |= 8; else *f &= ~8;
}

void Instrument_LookupProgram_LoNibble(unsigned char part)
{
    unsigned char n;
    n = (*(unsigned char **)&ram_4136e[part * 287])[42] & 0xf;
    ram_413d5[part * 287] = Instrument_OctaveShift_Semitones[n];
}

void Instrument_LookupProgram_HiNibble(unsigned char part)
{
    unsigned char n;
    n = ((*(unsigned char **)&ram_4136e[part * 287])[42] & 0xf0) >> 4;
    ram_413d5[part * 287] = Instrument_OctaveShift_Semitones[n];
}

void Voice_Artic_SetDepthPair_A(unsigned char part, char v)
{
    ram_41472[part * 287] = (v >> 4) << 2;
    ram_41473[part * 287] = ((char)(v << 4) >> 4) + ((char)(v << 4) >> 4);
}

void Voice_Artic_SetDepthPair_B(unsigned char part, char v)
{
    ram_41474[part * 287] = (v >> 4) << 2;
    ram_41475[part * 287] = ((char)(v << 4) >> 4) << 3;
}

void NoteState_ClearRecord(unsigned char i, unsigned char j)
{
    unsigned char *p;
    p = &ram_4424e[j][i * 9];
    p[1] = 0;
    p[2] = 0;
    p[3] = 0;
    p[4] = 0;
    p[0] = 0;
    p[5] = 0;
    p[7] = 0;
}

void VoiceRow_FetchPair_WA_SP(unsigned char a)
{
    unsigned char x, y;
    x = ram_2126[a * 5];
    y = ram_2127[a * 5];
    ram_2126[y * 5] = x;
    ram_2127[x * 5] = y;
    ram_2126[a * 5] = a;
    ram_2127[a * 5] = a;
}

void VoiceRow_FetchPair_DE_WA(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = ram_2126[a * 5];
    y = ram_2127[a * 5];
    ram_2126[y * 5] = x;
    ram_2127[x * 5] = y;
    y = ram_2127[c * 5];
    ram_2126[y * 5] = a;
    ram_2127[a * 5] = y;
    ram_2126[a * 5] = c;
    ram_2127[c * 5] = a;
}

void Voice_Selector_Unpack3Groups(unsigned char *p, unsigned int v, unsigned char e)
{
    p[Voice_Selector_FieldSlot_Table[e][0]] = v & 0xf;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][1]] = v & 0xf;
    v >>= 4;
    p[Voice_Selector_FieldSlot_Table[e][2]] = v & 0xf;
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

unsigned int Voice_Slot_CalcAmpNibble(unsigned char part, unsigned char n, unsigned char e)
{
    unsigned int *q;
    unsigned int lo;
    unsigned int r;
    q = (unsigned int *)(ram_41368[part] + 258);
    if ((*(unsigned int *)&ram_43094[n * 71] >> 8) + 12 >= 36) r = q[e];
    else {
        lo = q[e] & 0xf;
        if (lo < ((q[e] >> 4) & 0xf)) r = q[e] & 0xff0;
        else r = (q[e] & 0xf00) | (lo << 4);
    }
    return r;
}

/* ---- voice register builders ---- */

void Voice_ComputePitchBend2(unsigned char *v)
{
    unsigned char *q;
    int d;
    q = P(v, 19);
    if (B(P(v, 35), 15) != 0 && B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 6: d = 0; break;
        default: d = B(P(v, 35), 15); break;
        }
    } else d = B(P(v, 35), 15);
    if (d != 0) {
        d += B(q, 15) - 0x40;
        if (d < 0) d = 0;
        else if (d > 0x7f) d = 0x7f;
        d <<= 8;
    }
    if (B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 5:
        case 6: d |= 0x7f; break;
        default: d |= B(P(v, 35), 18); break;
        }
    } else d |= B(P(v, 35), 18);
    ram_451d2 = d;
}

void Level_Build_Reg0C0(unsigned char *v)
{
    int d;
    if (B(P(v, 35), 15) != 0 && B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 6: d = 0; break;
        default: d = B(P(v, 35), 15); break;
        }
    } else d = B(P(v, 35), 15);
    if (d != 0) {
        d = d + (B(P(v, 19), 92) - 0x40) + (char)B(P(v, 35), 102);
        if (d < 0) d = 0;
        else if (d > 0x7f) d = 0x7f;
        d <<= 8;
    }
    if (B(P(v, 35), 18) != 0) {
        switch (ram_4134c) {
        case 5:
        case 6: d |= 0x7f; break;
        default: d |= B(P(v, 35), 18); break;
        }
    } else d |= B(P(v, 35), 18);
    ram_451d2 = d;
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

void Voice_ReleaseSingle(unsigned char n)
{
    unsigned char *v;
    v = ram_4308e + n * 71;
    v[5] &= 0x7f;
    if (v[70] != 0) {
        Voice_Calc_LevelPair_Silence(v);
        ToneGen_WriteLevelBurst(n, ram_451cc);
    }
}

void Voice_Init_Type2(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[n * 71];
    WaveSel_StageB_Build_Reg040(v);
    Pitch_Apply_Zone_Trim(v);
    Voice_Pitch_WriteOutputReg_Secondary(v);
    TVF_BuildEmit_Short_Dispatch(v);
    TVF_Emit_Registers_Type2(v);
    Voice_ComputePitchBend2(v);
    Voice_Build_GateCommand_NoPartial(v);
    Voice_Calc_LevelPair_FixedAtk(v);
    Voice_WriteChPanShift2(v, 0);
    Voice_Level_ClearAllOutputRegs(v);
    Voice_ComputePitch_Mono(v);
    Voice_ApplyPortamento2(v);
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

void Voice_Init_Type1(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[n * 71];
    WaveSel_StageB_Build_Reg040(v);
    WaveSel_AddRandomEntryOffset(&ram_451ce);
    Pitch_Apply_Zone_Trim(v);
    Voice_Pitch_WriteOutputReg_Secondary(v);
    TVF_BuildEmit_Short_Dispatch(v);
    TVF_Emit_Registers_Type2(v);
    Voice_ComputePitchBend2(v);
    Voice_Build_GateCommand_NoPartial(v);
    Voice_Calc_LevelPair_FixedAtk(v);
    Voice_WriteChPanShift2(v, 0);
    Voice_Level_ClearAllOutputRegs(v);
    Voice_ComputePitch_Mono(v);
    Voice_Slot_LoadPitchOffset_B(v);
    Voice_ApplyPortamento2(v);
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

void Voice_Build_Register_Set(unsigned char n)
{
    unsigned char *v;
    v = &ram_4308e[n * 71];
    WaveSel_StageB_Build_Reg040(v);
    Pitch_Apply_Partial_Detune(v);
    Pitch_Emit_Reg400(v);
    Voice_Level_ComputeTriplet(v);
    TVF_Build_Dispatch(v);
    TVF_Emit_Registers(v);
    Voice_StereoLevel_Compute(v);
    Voice_PortaLevel_Compute(v);
    ExtVoice_Build_SlotRegisters(v);
    Voice_SubVoice_ComputeAndTrigger(v);
    Voice2_UpdatePitch(v);
    Level_Build_Reg0C0(v);
    Voice_Build_GateCommand(v);
    Voice_Calc_LevelPair_PatchAtk(v);
    Voice_WriteChPanShift(v, 0);
    Voice_ComputePitch(v);
    Voice_ApplyPortamento(v);
    ToneGen_WriteVoiceParams(n, ram_451cc);
}

void Voice_Cut(unsigned char n)
{
    unsigned char *v;
    unsigned char *s;
    unsigned int w;
    v = &ram_4308e[n * 71];
    s = P(v, 35);
    v[5] &= 0x7f;
    w = W(s, 10);
    if (v[3] == 3) W(s, 10) &= ~1;
    if ((W(v, 1) & 0x8000L) || !(W(P(v, 35), 10) & 1)) {
        if (v[3] < 3) Voice_ComputeVolume_CappedLFO(v);
        else Voice_Calc_LevelPair_EGA(v);
        Voice_Calc_LevelPair_EGB(v);
        Voice_Calc_LevelPair_EGC(v);
        ToneGen_WriteLevelBurst(n, ram_451cc);
    }
    W(s, 10) = w;
}

void Voice_PerVoice_PortamentoPitchUpdate(unsigned char n)
{
    Voice_NoteState_Clear(n);
    Voice_SetLFO_ActiveFlag(n);
    WaveSel_Rebuild_PartCaches(n, ram_41381[n * 287], ram_41382[n * 287]);
    switch ((*(unsigned char **)&ram_4136e[n * 287])[16] & 0xc0) {
    case 0:
    case 0xc0:
        VoiceSlot_FullInit(n);
        break;
    case 0x40:
        Voice_PortamentoTargets_SetAll(n);
        VoiceSlot_AltInit(n);
        break;
    case 0x80:
        break;
    }
}
