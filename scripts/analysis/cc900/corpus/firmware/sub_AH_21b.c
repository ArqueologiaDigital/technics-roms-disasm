/* lane_sub helper AH, round 21, form b: form a changed only in these spellings --
   Voice_Allocate_Type2: the patch record as (unsigned char *)(unsigned long)*(...) instead of a temporary r;
   Voice_NoteOn_Type3: the slot's pointers through a struct view, ((struct slotv *)SLOT(..))->a1 / ->a2;
   PartSlot_List / BuildOutputList: t < (unsigned char)0xc0;  SoundingVoiceList: row + k, q declared before out;
   NoteOn_RoutePacket: the 7-bit fields as bitfields of a struct view at q + 1 / q + 3;
   Voice_OpSlot_WriteParams: the packed bits through (int);  VoiceState_FullReset: (row)[offset].
   Form a's notes follow.
   lane_sub helper AH, round 21, form a (KN5000 sub-CPU payload v1.42).  Round 20's open functions (run
   2026-11-18-18-sub-r21a), each from its best round-20 form, changed where its first differences say:
   - every module-local callee is now in a cc900-module line, also those defined in this file or promoted
     (Voice_MakePartHandle, Voice_Allocate_1of4, Voice_Allocate_Type2, Voice_NoteOn_Type3): round 20 had them
     as `call` where the ROM has calr;
   - a row pointer plus an unsigned offset: the row through (unsigned char *)(unsigned long)(...) so V4.23 stops
     folding the offset into the row index (VoiceState_FullReset, Voice_Build_SoundingVoiceList);
   - a byte tested right after its load: assignment inside the test (SoundingVoiceList), a cast on the test
     (PartSlot_List, BuildOutputList);
   - Voice_Manager_PollBank: (int) on the byte index (signed (xrr+rr) addressing);
   - NoteOn_RoutePacket: l1 / l2 kept in memory ((void *)&), one pointer for the broadcast walk and the chain's
     first record (both XIZ in the ROM), the 7-bit fields through % 0x80;
   - Voice_OpSlot_WriteParams: form c's slot pointers, (int) on the clamp operands, the packed bits as an
     unsigned int shift into a byte temporary;
   - Voice_NoteOn_Type1 / _Type2: reload-after-store idiom (a) for the record number.
   The 71-byte record copy of NoteOn_Type1 / _Type2 / _Rhythm still differs only at its count (V4.23 pads the struct).
*/

#define W(p, o) (*(unsigned int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
#define SLOT(part, k) (&((unsigned char *)(unsigned long)(ram_41368 + (int)(part) * 287))[(int)(k) * 37 + 0x6e])

struct v71 { unsigned char b[71]; };
struct slotv { unsigned char *zone; unsigned char *a1; unsigned char *a2; };
struct sel { unsigned v7 : 7; unsigned f : 1; unsigned ch : 5; unsigned r : 3; };

extern unsigned char ram_41368[];
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char ram_41480[];
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

extern unsigned char *ToneDB_Find_SubToneRecord(unsigned char *rec, unsigned char k, unsigned char e);
extern unsigned char *WaveSel_StageA1_FromToneSlot(unsigned char a, unsigned char *p, unsigned char e, unsigned char s);
extern unsigned char Velocity_Select_Split_Zone_Alt(unsigned char a, unsigned char *t);
extern unsigned char *WaveSel_StageA2_FromVelZone(unsigned char z, unsigned char *p);
extern void Voice_Pitch_CopyBase(unsigned char *v);
extern void Voice_Pitch_Compute(unsigned char *v);
extern void Voice_Allocate_Nodes(unsigned char *v);
extern void ToneGen_SilenceChannel(unsigned char ch);
void Voice_Allocate_1of4(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                         unsigned char key, unsigned char vel, unsigned char flag);
unsigned int Voice_MakePartHandle(unsigned char a, unsigned char c);
int Voice_Pitch_ClampRange(int a, int hi, int lo);
unsigned int ToneGen_Read_Register(unsigned int r);
void Voice_Retire_ToFreePool(unsigned char *v);
void Voice_ScanSlots_ReassignSources(unsigned char a);
void Voice_Demote_Decayed(unsigned char *p);
void Voice_AdvanceSlotIterator(unsigned char a);
void ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
unsigned char ExtVoice_Fold_SlotNumber(unsigned char a, unsigned char g);
void OutputBuf_Flush_A(unsigned char **pp, unsigned char *head, unsigned char key, unsigned char all);
void OutputBuf_Flush_B(unsigned char **pp, unsigned char *head, unsigned char key, unsigned char all);
int ClampS16_WA_Short(int a, int hi, int lo);
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);

/* cc900-module: Voice_Pitch_ClampRange ToneGen_Read_Register Voice_Retire_ToFreePool Voice_ScanSlots_ReassignSources */
/* cc900-module: Voice_Demote_Decayed Voice_AdvanceSlotIterator ExtVoice_Alloc_StreamSlot ExtVoice_Fold_SlotNumber */
/* cc900-module: OutputBuf_Flush_A OutputBuf_Flush_B ClampS16_WA_Short Quad_Decode_A_To_L VoiceSlot_UpdateNoteSource */
/* cc900-module: Voice_MakePartHandle Voice_Allocate_1of4 Voice_Allocate_Type2 Voice_NoteOn_Type3 */

void Voice_Allocate_Type2(unsigned char *p, unsigned char part, unsigned int mask, unsigned char k,
                          unsigned char key, unsigned char vel, unsigned char flag)
{
    unsigned char *sub;
    unsigned char *zone;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char z;
    unsigned char *v;

    sub = ToneDB_Find_SubToneRecord((unsigned char *)(unsigned long)*(unsigned char **)&ram_4136e[part * 0x11f], key, part);
    if (sub[13] & mask) {
        zone = &sub[(int)k * 21 + 16];
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
    unsigned char *v;
    unsigned char *zone;
    unsigned char *a2;
    unsigned char *s;
    unsigned char *a1;

    if (*(unsigned int *)&ram_4136a[part * 0x11f] & mask) {
        a1 = ((struct slotv *)SLOT(part, k))->a1;
        zone = ((struct slotv *)SLOT(part, k))->zone;
        a2 = ((struct slotv *)SLOT(part, k))->a2;
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
    unsigned char u;

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
            u = p[(int)i + 10];
            t = u;
            *(struct v71 *)&ram_4308e[(int)u * 71] = *(struct v71 *)&ram_2942[(int)i * 71];
            ram_4308e[(int)t * 71] = t;
        }
    }
}

void Voice_NoteOn_Type1(unsigned char *p, unsigned char part, unsigned char key, unsigned char vel)
{
    unsigned char t;
    unsigned char i;
    unsigned char u;

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
            u = p[(int)i + 10];
            t = u;
            *(struct v71 *)&ram_4308e[(int)u * 71] = *(struct v71 *)&ram_2942[(int)i * 71];
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
        *(struct v71 *)&ram_4308e[(int)t * 71] = *(struct v71 *)&ram_2942[(int)k * 71];
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
    unsigned char t;

    ram_1128++;
    ram_1128 &= 3;
    m = ram_2936[(int)ram_1128] | ToneGen_Read_Register(ram_1128);
    x = (m ^ ram_292e[(int)ram_1128]) & ram_292e[(int)ram_1128];
    ram_292e[(int)ram_1128] = m;
    t = ram_1128 << 4;
    s = t;
    v = &ram_148d[(int)t * 39];
    for (bit = 1; bit != 0; bit += bit) {
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
        if (t < (unsigned char)0xc0) {
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
    unsigned char h;
    unsigned char i;
    unsigned char t;

    m = ~e;
    g = c & m;
    q = ram_1e4d + (int)a * 27;
    out = ram_27e9;
    for (i = 0; i < 27; i++) {
        t = q[i];
        if (t < (unsigned char)0xc0) {
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
        if ((t = q[b]) < 0xc0) {
            d = Voice_CommandIndexTable[b];
            if ((d & e) == c) {
                if ((s = ram_212a[(int)t * 5]) < 0x40) {
                    t = s;
                    d = Voice_PolyphonyLimits_Table[d & 0x1f];
                    do {
                        *out++ = s;
                        k = d;
                        t = *((unsigned char *)(unsigned long)(ram_24e6 + (int)t * 12) + k);
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

    (void *)&l1;
    (void *)&l2;
    all = ((struct sel *)(q + 3))->v7;
    key = ((struct sel *)(q + 1))->v7;
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
                        v = *l1;
                        for (;;) {
                            OutputBuf_Flush_B(&out, *l1, key, all);
                            if (*l1 == 0) break;
                            if (*l1 == v) break;
                        }
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

    p1 = &(*(unsigned char **)&ram_4136e[part * 0x11f])[(int)s1 * 16 + (int)op * 4];
    p1 += 0x2b;
    w = (unsigned char *)(ram_4424e + s2) + (int)s1 * 9;
    p2 = &((unsigned char *)(unsigned long)(ram_41368 + part * 0x11f))[(int)s1 * 16 + (int)op * 4];
    p2 += 0x27;
    if (s1 != 2 && op == 0 && ram_451a7 != 0xf5) {
        w[1] = ClampS16_WA_Short((int)p1[0] + (int)(char)v[104], 0x7f, 0);
        w[3] = ClampS16_WA_Short((int)p1[1] + (int)(char)v[105], 0x7f, 0);
        w[7] = ClampS16_WA_Short((int)(p1[3] & 0x3f) + (int)(char)v[106], 0x1e, 0);
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
    t = (int)(p1[3] & 0xc0) >> 6;
    w[0] &= 0xfc;
    w[0] |= t;
    w[5] = p1[2] & 0x7f;
}

void VoiceState_FullReset(void)
{
    unsigned char j;
    unsigned char i;

    for (i = 0; i < 0x40; i++)
        for (j = 0; j < 4; j++) {
            ((unsigned char *)(unsigned long)(ram_24e6 + (int)i * 12))[(unsigned int)j + 8] = 0xff;
            ((unsigned char *)(unsigned long)(ram_24e6 + (int)i * 12))[(unsigned int)j] = i;
            ((unsigned char *)(unsigned long)(ram_24e6 + (int)i * 12))[(unsigned int)j + 4] = i;
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
            ((unsigned char *)(unsigned long)(ram_1e4d + (int)i * 27))[(unsigned int)j] = 0xff;
    for (i = 0; i < 0xc0; i++)
        VoiceSlot_UpdateNoteSource(i, 0x1a, Quad_Decode_A_To_L(i));
}
