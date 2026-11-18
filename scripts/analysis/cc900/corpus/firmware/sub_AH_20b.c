/* lane_sub helper AH, round 20, form b (KN5000 sub-CPU payload v1.42): form a changed only where said.
   Voice_Allocate_1of4: no reload-after-store idiom for the tone record (a2 assigned and read directly);
     zone = sub + (k * 21 + 16) (pointer plus int) in all three Voice_Allocate_*.
   Voice_NoteOn_Type3: a1 declared first.
   Voice_NoteOn_Type1 / _Type2 / _Rhythm: the 71-byte record copy through memcpy (an inline expansion would give
     ldirw + ldi).
   Voice_Manager_PollBank: x = m; x ^= T; x &= T in statements; s assigned directly; bit = bit + bit.
   Voice_Build_PartSlot_List: h declared before i; Voice_BuildOutputList: i before h (which byte of QIZ each gets).
   Voice_Build_SoundingVoiceList: the chain index through an unsigned int local k.
   NoteOn_RoutePacket: OutputBuf_Flush_A / _B's last parameter plain char (as their own C).
   Voice_OpSlot_WriteParams: the packed bits through a byte temporary before w[0] &= 0xfc.
   VoiceState_FullReset: indexes j + 8u; the first argument of VoiceSlot_UpdateNoteSource through an unsigned int.
*/
extern void *memcpy(void *d, const void *s, unsigned int n);

#define W(p, o) (*(unsigned int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
#define SLOT(part, k) (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 37 + 0x6e])

struct v71 { unsigned char b[71]; };

extern unsigned char ram_41368[];
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41480[];
extern unsigned char ram_413d5[];
extern unsigned char ram_4137f[];
extern unsigned char ram_4134b;
extern unsigned int ram_41343;
extern unsigned char ram_4308e[];
extern unsigned char ram_451a7;
extern unsigned char ram_4424e[][27];
extern unsigned char __near ram_2942[];
extern unsigned char __near ram_1128;
extern unsigned int __near ram_2936[];
extern unsigned int __near ram_292e[];
extern unsigned char __near ram_148d[];
extern unsigned char __near ram_134d[];
extern unsigned char __near ram_1351[];
extern unsigned char __near ram_24e6[];
extern unsigned char __near ram_1e4d[];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2127[];
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_2129[];
extern unsigned char __near ram_212a[];
extern unsigned int __near ram_286b[];
extern unsigned int __near ram_27e9[];
extern unsigned char __near ram_28ed[];
extern unsigned char Voice_CommandIndexTable[];
extern unsigned char Voice_PolyphonyLimits_Table[];

extern unsigned char *ToneDB_Find_ToneRecord(unsigned int a, unsigned int b);
extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
extern unsigned char Velocity_Select_Split_Zone_Alt(unsigned char a, unsigned char *t);
extern unsigned char *WaveSel_StageA2_FromVelZone(unsigned char z, unsigned char *p);
extern void Voice_Slot_ComputePitch(unsigned char *v);
extern void Voice_Pitch_CopyBase(unsigned char *v);
extern void Voice_Pitch_Compute(unsigned char *v);
extern void Voice_Allocate_Nodes(unsigned char *v);
extern void ToneGen_SilenceChannel(unsigned char ch);
int Voice_Pitch_ClampRange(int a, int hi, int lo);
unsigned int ToneGen_Read_Register(unsigned int r);
void Voice_Retire_ToFreePool(unsigned char *v);
void Voice_ScanSlots_ReassignSources(unsigned char a);
void Voice_Demote_Decayed(unsigned char *p);
void Voice_AdvanceSlotIterator(unsigned char a);
void ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
unsigned char ExtVoice_Fold_SlotNumber(unsigned char a, unsigned char g);
void OutputBuf_Flush_A(unsigned char **pp, unsigned char *head, unsigned char key, char all);
void OutputBuf_Flush_B(unsigned char **pp, unsigned char *head, unsigned char key, char all);
int ClampS16_WA_Short(int a, int hi, int lo);
unsigned char BitTest_Bit0_L(unsigned char a);
unsigned char BitTest_Mode2_L(unsigned char a);
unsigned char BitTest_Bit0_L_v2(unsigned char a);
unsigned char BitTest_Mode2_L_v2(unsigned char a);
void Instrument_LookupProgram_HiNibble(unsigned char part);
void Instrument_LookupProgram_LoNibble(unsigned char part);
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);

/* cc900-module: Voice_Pitch_ClampRange ToneGen_Read_Register Voice_Retire_ToFreePool Voice_ScanSlots_ReassignSources */
/* cc900-module: Voice_Demote_Decayed Voice_AdvanceSlotIterator ExtVoice_Alloc_StreamSlot ExtVoice_Fold_SlotNumber */
/* cc900-module: OutputBuf_Flush_A OutputBuf_Flush_B ClampS16_WA_Short BitTest_Bit0_L BitTest_Mode2_L */
/* cc900-module: BitTest_Bit0_L_v2 BitTest_Mode2_L_v2 Instrument_LookupProgram_HiNibble */
/* cc900-module: Instrument_LookupProgram_LoNibble Quad_Decode_A_To_L VoiceSlot_UpdateNoteSource */

void Voice_Allocate_1of4(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                         unsigned char key, unsigned char vel, unsigned char flag)
{
    unsigned char *sub;
    unsigned char *zone;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char z;
    unsigned int w;
    unsigned char *v;

    z = 0;
    a2 = *(unsigned char **)&((unsigned char *)(unsigned long)((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f)
                                                              + ((int)k * 37 + (int)z * 4)))[118];
    w = W(a2, 12);
    sub = ToneDB_Find_SubToneRecord(ToneDB_Find_ToneRecord((unsigned char)w, (unsigned char)(w >> 8)), a2[11], part);
    if ((a2[0] & 2) && (sub[13] & mask)) {
        zone = sub + ((int)k * 21 + 16);
        a1 = WaveSel_StageA1_FromToneSlot(k, zone, key, part);
        z = Velocity_Select_Split_Zone_Alt(vel, a1);
        a2 = WaveSel_StageA2_FromVelZone(z, a1);
        v = &ram_2942[(int)k * 71];
        W(v, 1) = z << 6 | 0x12;
        v[3] = k;
        v[4] = part;
        v[5] = key | 0x80;
        v[12] = vel;
        P(v, 35) = ram_41368 + part * 0x11f;
        P(v, 19) = sub;
        P(v, 23) = zone;
        P(v, 27) = a1;
        P(v, 31) = a2;
        Voice_Slot_ComputePitch(v);
        p[(int)k + 2] = flag | 0x80;
    } else p[(int)k + 2] = 0;
}

void Voice_Allocate_Typed(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                          unsigned char key, unsigned char vel, unsigned char flag, unsigned int tone)
{
    unsigned char *v;
    unsigned char *sub;
    unsigned char *zone;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char z;

    v = ram_2942 + (int)k * 71;
    sub = ToneDB_Find_SubToneRecord(ToneDB_Find_ToneRecord((unsigned char)tone, (unsigned char)(tone >> 8)), key, part);
    if (sub[13] & mask) {
        zone = sub + ((int)k * 21 + 16);
        a1 = WaveSel_StageA1_FromToneSlot(k, zone, key, part);
        z = Velocity_Select_Split_Zone_Alt(vel, a1);
        a2 = WaveSel_StageA2_FromVelZone(z, a1);
        W(v, 1) = z << 6 | 0x12;
        v[3] = k;
        v[4] = part;
        v[5] = key | 0x80;
        v[12] = vel;
        P(v, 35) = &ram_41368[part * 0x11f];
        P(v, 39) = SLOT(part, k);
        P(v, 19) = sub;
        P(v, 23) = zone;
        P(v, 27) = a1;
        P(v, 31) = a2;
        Voice_Pitch_CopyBase(v);
        p[(int)k + 2] = flag | 0x80;
    } else p[(int)k + 2] = 0;
    p[(int)k + 6] = 0;
}

void Voice_Allocate_Type2(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                          unsigned char key, unsigned char vel, unsigned char flag)
{
    unsigned char *sub;
    unsigned char *zone;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char z;
    unsigned char *v;

    sub = ToneDB_Find_SubToneRecord(*(unsigned char **)&ram_4136e[part * 0x11f], key, part);
    if (sub[13] & mask) {
        zone = sub + ((int)k * 21 + 16);
        a1 = WaveSel_StageA1_FromToneSlot(k, zone, key, part);
        z = Velocity_Select_Split_Zone_Alt(vel, a1);
        a2 = WaveSel_StageA2_FromVelZone(z, a1);
        v = &ram_2942[(int)k * 71];
        W(v, 1) = z << 6 | 0x10;
        v[3] = k;
        v[4] = part;
        v[5] = key | 0x80;
        if (ram_41343 & 2) vel = Voice_Pitch_ClampRange(vel + 0x10, 0x7f, 0);
        v[12] = vel;
        P(v, 35) = ram_41368 + part * 0x11f;
        P(v, 39) = SLOT(part, k);
        P(v, 19) = sub;
        P(v, 23) = zone;
        P(v, 27) = a1;
        P(v, 31) = a2;
        Voice_Pitch_CopyBase(v);
        p[(int)k + 2] = flag | 0x80;
    } else p[(int)k + 2] = 0;
    p[(int)k + 6] = 0;
}

void Voice_NoteOn_Type3(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                        unsigned char key, unsigned char vel, unsigned char flag)
{
    unsigned char *a1;
    unsigned char *v;
    unsigned char *zone;
    unsigned char *a2;
    unsigned char *s;

    if (*(unsigned int *)&ram_4136a[part * 0x11f] & mask) {
        a1 = *(unsigned char **)(SLOT(part, k) + 4);
        zone = *(unsigned char **)SLOT(part, k);
        a2 = *(unsigned char **)(SLOT(part, k) + 8);
        s = SLOT(part, k);
        v = &ram_2942[(int)k * 71];
        W(v, 1) = 8;
        if (vel & 0x80) W(v, 1) |= 0x800;
        v[3] = k;
        v[4] = part;
        v[5] = key | 0x80;
        v[12] = vel & 0x7f;
        P(v, 35) = ram_41368 + part * 0x11f;
        P(v, 19) = *(unsigned char **)&ram_4136e[part * 0x11f];
        P(v, 23) = zone;
        P(v, 27) = a1;
        P(v, 31) = a2;
        P(v, 39) = s;
        Voice_Pitch_Compute(v);
        W(v, 47) = 0;
        W(v, 49) = 0xff;
        v[53] = 0;
        W(v, 54) = 0;
        W(v, 58) = 0;
        W(v, 56) = 0;
        p[(int)k + 2] = flag | 0x80;
    } else p[(int)k + 2] = 0;
    p[(int)k + 6] = 0;
}

void Voice_NoteOn_Type2(unsigned char *p, unsigned char part, unsigned char key, unsigned char vel)
{
    unsigned char t;
    unsigned char i;

    if (*(unsigned int *)&ram_4136a[part * 0x11f] & 0x2000) ram_41480[part * 0x11f] |= 0x80;
    else ram_41480[part * 0x11f] &= ~0x80;
    W(p, 0) = ((unsigned int)part << 8 | key) | 0x80;
    Voice_NoteOn_Type3(p, part, 1, 0, key, vel, 0);
    Voice_NoteOn_Type3(p, part, 2, 1, key, vel, 1);
    Voice_NoteOn_Type3(p, part, 4, 2, key, vel, 1);
    if (vel & 0x80) Voice_NoteOn_Type3(p, part, 0, 3, key, vel, 3);
    else Voice_NoteOn_Type3(p, part, 8, 3, key, vel, 3);
    Voice_Allocate_Nodes(p);
    for (i = 0; i < 4; i++) {
        if (p[(int)i + 10] < 0x40) {
            t = p[(int)i + 10];
            memcpy(&ram_4308e[(int)t * 71], &ram_2942[(int)i * 71], 71);
            ram_4308e[(int)t * 71] = t;
        }
    }
}

void Voice_NoteOn_Type1(unsigned char *p, unsigned char part, unsigned char key, unsigned char vel)
{
    unsigned char t;
    unsigned char i;

    W(p, 0) = ((unsigned int)part << 8 | key) | 0x80;
    Voice_Allocate_Type2(p, part, 1, 0, key, vel, 0);
    Voice_Allocate_Type2(p, part, 4, 1, key, vel, 1);
    p[4] = 0;
    p[8] = 0;
    p[5] = 0;
    p[9] = 0;
    Voice_Allocate_Nodes(p);
    for (i = 0; i < 2; i++) {
        if (p[(int)i + 10] < 0x40) {
            t = p[(int)i + 10];
            memcpy(&ram_4308e[(int)t * 71], &ram_2942[(int)i * 71], 71);
            ram_4308e[(int)t * 71] = t;
        }
    }
}

void Voice_NoteOn_Rhythm(unsigned char *p, unsigned char part, unsigned char key, unsigned char vel)
{
    unsigned char k;
    unsigned char t;

    W(p, 0) = ((unsigned int)part << 8 | key) | 0x80;
    if (vel != 0) {
        k = 0;
        Voice_Allocate_1of4(p, part, 1, k, key, vel, 3);
        p[6] = 0x40;
        p[3] = 0;
        p[7] = 0;
    } else {
        k = 1;
        vel = 0x50;
        p[2] = 0;
        p[6] = 0;
        Voice_Allocate_1of4(p, part, 4, k, key, vel, 3);
        p[7] = 0;
    }
    p[4] = 0;
    p[8] = 0;
    p[5] = 0;
    p[9] = 0;
    Voice_Allocate_Nodes(p);
    if (p[(int)k + 10] < 0x40) {
        t = p[(int)k + 10];
        memcpy(&ram_4308e[(int)t * 71], &ram_2942[(int)k * 71], 71);
        ram_4308e[(int)t * 71] = t;
    }
}

void Voice_Manager_PollBank(void)
{
    unsigned int x;
    unsigned int bit;
    unsigned char s;
    unsigned int m;
    unsigned char *v;

    ram_1128++;
    ram_1128 &= 3;
    m = ram_2936[ram_1128] | ToneGen_Read_Register(ram_1128);
    x = m;
    x ^= ram_292e[ram_1128];
    x &= ram_292e[ram_1128];
    ram_292e[ram_1128] = m;
    s = ram_1128 << 4;
    v = &ram_148d[(int)s * 39];
    for (bit = 1; bit != 0; bit = bit + bit) {
        if ((x & bit) && !(v[34] & 1)) {
            Voice_Retire_ToFreePool(v);
            ToneGen_SilenceChannel(s);
            Voice_ScanSlots_ReassignSources(s);
        } else if (!(v[34] & 0x81)) {
            v[37] = (ToneGen_Read_Register(s + 0x180) & 0x3fff) >> 5;
            if (v[37] < 0x80 && (v[34] & 4)) Voice_Demote_Decayed(v);
        }
        s++;
        v += 39;
    }
    Voice_AdvanceSlotIterator(ram_1128);
}

unsigned int Voice_MakePartHandle(unsigned char a, unsigned char c)
{
    c &= 0x3f;
    if (a >= 0x40) return (unsigned int)c << 8 | 0xff;
    Voice_ScanSlots_ReassignSources(a);
    return (unsigned int)c << 8 | 0xff;
}

void Voice_Part_Assign(unsigned char a, unsigned char c, unsigned char e, unsigned char s)
{
    Voice_MakePartHandle(c, e);
    ExtVoice_Alloc_StreamSlot(a, c, s);
}

unsigned int *Voice_Build_PartSlot_List(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char *q;
    unsigned char g;
    unsigned char m;
    unsigned int *out;
    unsigned char h;
    unsigned char i;
    unsigned char t;

    m = ~e;
    g = c & m;
    q = ram_24e6 + (int)a * 12;
    out = ram_286b;
    for (i = 0; i < 4; i++) {
        t = q[(int)i + 8];
        if (t < 0xc0) {
            if (((h = Voice_CommandIndexTable[ram_2129[(int)t * 5]]) & m) == g)
                *out++ = (unsigned int)h << 8 | ExtVoice_Fold_SlotNumber(t, i);
        }
    }
    *out = 0xffff;
    return ram_286b;
}

unsigned int *Voice_BuildOutputList(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char *q;
    unsigned char g;
    unsigned char m;
    unsigned int *out;
    unsigned char i;
    unsigned char h;
    unsigned char t;

    m = ~e;
    g = c & m;
    q = ram_1e4d + (int)a * 27;
    out = ram_27e9;
    for (i = 0; i < 27; i++) {
        t = q[i];
        if (t < 0xc0) {
            if (((h = Voice_CommandIndexTable[i]) & m) == g)
                *out++ = (unsigned int)h << 8 | ExtVoice_Fold_SlotNumber(t, Voice_PolyphonyLimits_Table[h & 0x1f]);
        }
    }
    *out = 0xffff;
    return ram_27e9;
}

unsigned char *Voice_Build_SoundingVoiceList(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char *q;
    unsigned char *out;
    unsigned char b;
    unsigned char t;
    unsigned char d;
    unsigned char s;
    unsigned int k;

    e = ~e;
    c &= e;
    q = &ram_1e4d[(int)a * 27];
    out = ram_28ed;
    for (b = 0; b < 27; b++) {
        t = q[b];
        if (t < 0xc0) {
            d = Voice_CommandIndexTable[b];
            if ((d & e) == c) {
                s = ram_212a[(int)t * 5];
                if (s < 0x40) {
                    t = s;
                    d = Voice_PolyphonyLimits_Table[d & 0x1f];
                    do {
                        *out++ = s;
                        k = d;
                        t = *(ram_24e6 + (int)t * 12 + k);
                    } while (t != s);
                }
            }
        }
    }
    *out = 0xff;
    return ram_28ed;
}

void NoteOn_RoutePacket(unsigned char *q)
{
    unsigned char **l1;
    unsigned char **l2;
    unsigned char key;
    unsigned char all;
    unsigned char *out;
    unsigned char *v;
    unsigned char i;
    unsigned char ch;
    unsigned char *first;

    all = W(q, 3) & 0x7f;
    key = W(q, 1) & 0x7f;
    out = q + 5;
    if (W(q, 3) & 0x1f00) {
        v = ram_148d;
        for (i = 0; i < 0x40; i++) {
            if (!(v[34] & 1)) *out++ = v[36];
            v += 39;
        }
        *out = 0xff;
    } else {
        ch = (W(q, 1) & 0x1f00) >> 8;
        l1 = (unsigned char **)(ram_134d + (int)ch * 12);
        l2 = (unsigned char **)(ram_1351 + (int)ch * 12);
        if (ch < 0x1a) {
            if (q[0] & 0x80) {
                if (W(q, 3) & 0x7f) {
                    if (*l1 != 0) {
                        first = *l1;
                        do {
                            OutputBuf_Flush_B(&out, *l1, key, all);
                        } while (*l1 != 0 && *l1 != first);
                    }
                    *out = 0xff;
                } else OutputBuf_Flush_B(&out, *l1, key, all);
            } else if (q[0] & 0x40) {
                OutputBuf_Flush_A(&out, *l2, key, all);
            } else if (W(q, 3) & 0x80) {
                OutputBuf_Flush_A(&out, *l1, key, all);
                OutputBuf_Flush_A(&out, *l2, key, all);
            } else if (W(q, 1) & 0x80) {
                OutputBuf_Flush_A(&out, *l1, key, all);
            } else {
                OutputBuf_Flush_A(&out, *l2, key, all);
            }
        } else *out = 0xff;
    }
}

void Voice_OpSlot_WriteParams(unsigned char part, unsigned char *v, unsigned char op, unsigned char s1, unsigned char s2)
{
    unsigned char *p1;
    unsigned char *p2;
    unsigned char *w;
    unsigned char t;

    p1 =*(unsigned char **)&ram_4136e[part * 0x11f] + ((int)s1 * 16 + (int)op * 4);
    p1 += 0x2b;
    w = (unsigned char *)(ram_4424e + s2) + (int)s1 * 9;
    p2 = ram_41368 + part * 0x11f + ((int)s1 * 16 + (int)op * 4);
    p2 += 0x27;
    if (s1 != 2 && op == 0 && ram_451a7 != 0xf5) {
        w[1] = ClampS16_WA_Short(p1[0] + (char)v[104], 0x7f, 0);
        w[3] = ClampS16_WA_Short(p1[1] + (char)v[105], 0x7f, 0);
        w[7] = ClampS16_WA_Short((p1[3] & 0x3f) + (char)v[106], 0x1e, 0);
    } else {
        w[1] = p1[0];
        w[3] = p1[1];
        w[7] = p1[3] & 0x3f;
    }
    if (p2[0] & 2) {
        w[2] = p2[3];
        w[7] = 0;
    } else w[2] = 0x80;
    if (p2[0] & 8) {
        w[4] = p2[2];
        w[7] = 0;
    } else w[4] = 0x80;
    if (p1[2] & 0x80) w[0] |= 0x20;
    else w[0] &= ~0x20;
    t = (p1[3] & 0xc0) >> 6;
    w[0] &= 0xfc;
    w[0] |= t;
    w[5] = p1[2] & 0x7f;
}

void Voice_Env_ApplyVelocity_Type0(unsigned char a, unsigned char c)
{
    unsigned char r;

    ram_413d5[a * 0x11f] = 0;
    switch (a) {
    case 0:
    case 1:
        switch (c) {
        case 0:
            if (ram_4134b & 8) r = 0;
            else r = BitTest_Bit0_L(ram_4134b);
            break;
        case 1:
            if (ram_4134b & 8) r = 0;
            else r = BitTest_Mode2_L(ram_4134b);
            break;
        case 2:
            if (ram_4137f[a * 0x11f] & 8) r = 0;
            else r = BitTest_Bit0_L_v2(ram_4137f[a * 0x11f]);
            break;
        case 3:
            if (ram_4137f[a * 0x11f] & 8) r = 0;
            else r = BitTest_Mode2_L_v2(ram_4137f[a * 0x11f]);
            break;
        default:
            r = 0;
            break;
        }
        if (r != 0) Instrument_LookupProgram_HiNibble(a);
        break;
    case 2:
        switch (c) {
        case 0:
            if (ram_4134b & 0x10) r = 0;
            else r = BitTest_Bit0_L(ram_4134b);
            break;
        case 1:
            if (ram_4134b & 0x10) r = 0;
            else r = BitTest_Mode2_L(ram_4134b);
            break;
        case 2:
            if (ram_4137f[a * 0x11f] & 0x10) r = 0;
            else r = BitTest_Bit0_L_v2(ram_4137f[a * 0x11f]);
            break;
        case 3:
            if (ram_4137f[a * 0x11f] & 0x10) r = 0;
            else r = BitTest_Mode2_L_v2(ram_4137f[a * 0x11f]);
            break;
        default:
            r = 0;
            break;
        }
        if (r != 0) Instrument_LookupProgram_LoNibble(a);
        break;
    }
}

void VoiceState_FullReset(void)
{
    unsigned char i;
    unsigned char j;
    unsigned int n;

    for (i = 0; i < 0x40; i++)
        for (j = 0; j < 4; j++) {
            *(ram_24e6 + (int)i * 12 + (j + 8u)) = 0xff;
            *(ram_24e6 + (int)i * 12 + (j + 0u)) = i;
            *(ram_24e6 + (int)i * 12 + (j + 4u)) = i;
        }
    for (i = 0; i < 0xc0; i++) {
        ram_2126[(int)i * 5] = i;
        ram_2127[(int)i * 5] = i;
        ram_2128[(int)i * 5] = 0;
        ram_2129[(int)i * 5] = 0;
        ram_212a[(int)i * 5] = 0xff;
    }
    for (i = 0; i < 27; i++)
        for (j = 0; j < 27; j++)
            *(ram_1e4d + (int)i * 27 + (j + 0u)) = 0xff;
    for (i = 0; i < 0xc0; i++) {
        n = i;
        VoiceSlot_UpdateNoteSource(n, 0x1a, Quad_Decode_A_To_L(i));
    }
}
