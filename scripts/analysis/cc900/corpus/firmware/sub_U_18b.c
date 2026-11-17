/* lane_sub helper U, round 18, form b (second spellings).  Same functions as sub_U_18a.c: the functions round 17
   left open whose best attempt is a sub_P_17* file (KN5000 sub-CPU payload v1.42, v142/subcpu, core/05 and
   core/07).  Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.

   Form b, per function:
   - TVF_Calc_Cutoff: the copy of the key-follow depth kept, but set by an initialiser (`int x = d;`).
   - VoiceState_SwapSlot_DE_BC: form a with the member index cast, prev[(unsigned int)c].
   - ToneGen_SilenceChannel: the channel's address taken in a plain expression statement (`&ch;`).
   - TVF_Lookup_Depth_Amount: the high byte shifted in the assignment's expression; `hi |= lo; return hi;`.
   - Voice_Retire_ToFreePool: form a with the two locals declared in the other order and `u[1] < q[0]`.
   - Voice_PortaLevel_Compute: form a with Detune_ScaleSymmetric returning int and the level byte as `c & 0xff`.
   - PitchBend_Scale: `r *= k; r >>= e; return r;`.
   - Voice_ScanSlots_ReassignSources: unsigned char slot byte with no casts, declared before the record pointer
     (round 17's order; tells the type's effect from the declaration order's).
   - WaveSel_StageB_Build_Reg040: the key table's address read as a pointer, then += base; the zone table kept
     as a pointer to unsigned int and cast to the Emit routines' byte pointer at each call.
   - Voice_Clear_HoldBit: the word index `(int)(n >> 4)`.
   - TVF_Emit_Offset_Both: form a with the first OR's other operand read signed.
   - Voice_Freq_WriteLeft: the mode bits through the curve-word local w, `(unsigned int)x | w`.
   Not tried before (pool_A_remaining):
   - VoiceState_SwapSlot_HL_IY: form a with the member index cast, as SwapSlot_DE_BC here.
   - Voice_Slot_CalcArticParams: form a with the nibble written by one assignment. */

/* cc900-module: TVF_Clamp_Cutoff */
/* cc900-module: Voice_Reprioritise */
/* cc900-module: Voice_List_MoveToPool */
/* cc900-module: Voice_List_MoveToPartList */
/* cc900-module: DList_Unlink_SelfLink_Offsets16 */
/* cc900-module: EnvDepth_Cap */
/* cc900-module: Quad_Decode_A_To_L */
/* cc900-module: VoiceSlot_UpdateNoteSource */
/* cc900-module: VoiceState_SwapSlot_DE_BC */
/* cc900-module: WaveSel_KeyTable_Lookup */
/* cc900-module: WaveSel_Emit_ZoneRecord_S4 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S6 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S10 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S12 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S13 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S15 */
/* cc900-module: Detune_ScaleUnsigned */
/* cc900-module: Detune_ScaleSymmetric */
/* cc900-module: Int_ClampSignedToRange */
/* cc900-module: PitchBend_Scale */
/* cc900-module: Voice_SignedClamp */

#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
#define ROW(a) ((struct vrow *)(ram_24e6 + (int)(a) * 12))

struct vrow { unsigned char prev[4]; unsigned char next[4]; unsigned char src[4]; };

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern int __near ram_2940;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451e2;
extern unsigned int ram_451ea;
extern unsigned int ram_45204;
extern unsigned int ram_4520e;
extern unsigned long ToneDB_RelBase;
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned int Voice_FreqWrite_BaseCurve[];
extern char TVF_KeyFollow_Curves[][128];
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
extern char PitchBend_ScaleCoeff_Table[];
extern unsigned char Voice_DepthMirror_Table[];
extern unsigned char ram_44260[];
extern unsigned char ram_41368[];
extern unsigned char ram_413d6[];
extern char ram_41472[];
extern char ram_41473[];
extern char ram_41474[];
extern char ram_41475[];
extern unsigned char __near ram_14af[];
extern unsigned char __near ram_148d[];
extern unsigned char __near ram_132b[];
extern unsigned char __near ram_1481[];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_24e6[];
extern unsigned int __near ram_2936[];

int TVF_Clamp_Cutoff(int a);
void Voice_Reprioritise(unsigned char *p);
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, int k);
void DList_Unlink_SelfLink_Offsets16(unsigned char *n);
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void VoiceState_SwapSlot_DE_BC(int a, int c);
unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, int k);
void WaveSel_Emit_ZoneRecord_S4(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S6(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S10(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S12(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S13(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S15(unsigned char *v, unsigned char *t, int i);
unsigned int Detune_ScaleUnsigned(unsigned int a);
int Detune_ScaleSymmetric(int a);
int Int_ClampSignedToRange(int a, int hi, int lo);
int PitchBend_Scale(int a, int b, int c);
void Voice_SignedClamp(unsigned char *p, int d, int hi, int lo);

int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s)
{
    int x = d;
    unsigned char *t;
    int k;
    unsigned int w;
    t = P(v, 23);
    if (x != 0) {
        k = TVF_KeyFollow_Curves[(t[54] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        x = x * k >> 5;
        c += x;
    }
    if (s != 0) {
        w = (W(v, 8) & 0x7f00) >> 8;
        if (w > t[59]) w = t[59];
        else if (w < t[58]) w = t[58];
        w -= t[57];
        c += (s * (int)w) >> 5;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}

/* cc900-name: VSwapSlot_DE_BC=VoiceState_SwapSlot_DE_BC */
void VSwapSlot_DE_BC(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = ROW(a)->prev[(unsigned int)c];
    y = ROW(a)->next[(unsigned int)c];
    ROW(y)->prev[(unsigned int)c] = x;
    ROW(x)->next[(unsigned int)c] = y;
    ROW(a)->prev[(unsigned int)c] = a;
    ROW(a)->next[(unsigned int)c] = a;
}

void ToneGen_SilenceChannel(unsigned char ch)
{
    &ch;
    ram_18 &= 0x7f;
    ram_100000 = (unsigned char)(ch + 0xc0);
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= 0x7f;
    ram_100000 = ch;
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0x7e00;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    unsigned int n;
    unsigned int hi;
    unsigned int lo;
    n = a & 0xf;
    if (a & 0x80) {
        hi = (unsigned int)*(unsigned char *)((unsigned long)&TVF_DepthRecords_B[0][1] + (unsigned long)n * 3) << 8;
        lo = TVF_DepthRecords_B[n][0];
        ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_B[0][2] + (unsigned long)n * 3);
    } else {
        hi = (unsigned int)*(unsigned char *)((unsigned long)&TVF_DepthRecords_A[0][1] + (unsigned long)n * 3) << 8;
        lo = TVF_DepthRecords_A[n][0];
        ram_2940 = *(char *)((unsigned long)&TVF_DepthRecords_A[0][2] + (unsigned long)n * 3);
    }
    hi |= lo;
    return hi;
}

void Voice_Retire_ToFreePool(unsigned char *v)
{
    unsigned char *u;
    unsigned char *q;
    if (!(v[34] & 1)) {
        if (P(v, 29)[1] != 0) P(v, 29)[1]--;
        Voice_List_MoveToPool(v, (unsigned char *)(void *)ram_132b, 6);
        Voice_List_MoveToPartList(v, (unsigned char *)(void *)ram_1481, 1);
        DList_Unlink_SelfLink_Offsets16(v);
        v[34] = 1;
        v[37] = 0;
        u = P(v, 29);
        q = u;
        if (u[1] < q[0]) P(v, 29)[1]++;
    }
}

void Voice_PortaLevel_Compute(unsigned char *v)
{
    unsigned char *t;
    unsigned int b;
    unsigned int a;
    int c;
    unsigned char *u;
    u = P(v, 23);
    t = u;
    if (((char *)u)[7] < 0) {
        a = Detune_ScaleUnsigned(~(int)(char)t[7] + 1);
        b = Detune_ScaleSymmetric(~(int)(char)t[8] + 1);
    } else {
        a = Detune_ScaleUnsigned((char)t[7]);
        b = Detune_ScaleSymmetric((char)t[8]);
    }
    a += PitchBend_Scale((char)t[18], v[12], 6);
    a = Int_ClampSignedToRange(a, 0x7f, 0);
    c = 0x7f;
    c += PitchBend_Scale((char)t[72], v[12], 6);
    c = Int_ClampSignedToRange(c, 0x7f, 0);
    ram_451e2 = (a << 8) | (c & 0xff);
    ram_451ea = (b << 8) | (Detune_ScaleSymmetric((char)(t[62] + t[61])) & 0xff);
}

/* cc900-name: PBend_Scale=PitchBend_Scale */
int PBend_Scale(char a, unsigned char b, unsigned char e)
{
    int k;
    int r;
    b &= 0x7f;
    if (a < 0) {
        b = (unsigned int)Voice_DepthMirror_Table[b];
        a = ~a + 1;
    }
    k = a;
    r = PitchBend_ScaleCoeff_Table[b];
    r *= k;
    r >>= e;
    return r;
}

void Voice_ScanSlots_ReassignSources(unsigned char a)
{
    unsigned char *r;
    unsigned char i;
    unsigned char s;
    unsigned char *q;
    int j;
    r = ram_24e6 + (int)a * 12;
    for (i = 0; i < 4; i++) {
        s = r[(int)i + 8];
        if (s < 0xc0) {
            q = &ram_2126[(int)s * 5];
            if (q[4] == a) {
                if (r[i] != a) q[4] = r[i];
                else {
                    q[4] = 0xff;
                    j = s;
                    VoiceSlot_UpdateNoteSource(j, 0x1a, Quad_Decode_A_To_L(s));
                }
            }
            VoiceState_SwapSlot_DE_BC(a, i);
            r[(int)i + 8] = 0xff;
        }
    }
}

void WaveSel_StageB_Build_Reg040(unsigned char *v)
{
    unsigned char *z;
    unsigned char *a1;
    unsigned int *a2;
    unsigned char *p;
    unsigned char k;
    z = P(v, 31);
    a1 = (unsigned char *)(*(unsigned long *)(z + 1) + ToneDB_RelBase);
    a2 = (unsigned int *)(*(unsigned long *)(z + 5) + ToneDB_RelBase);
    p = *(unsigned char **)a1;
    p += ToneDB_RelBase;
    k = a1[(int)WaveSel_KeyTable_Lookup(p, SW(v, 6)) + 4];
    if (z[0] & 0x40) {
        if (z[0] & 0x80) {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S15(v, (unsigned char *)a2, k);
            else WaveSel_Emit_ZoneRecord_S12(v, (unsigned char *)a2, k);
        } else {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S13(v, (unsigned char *)a2, k);
            else WaveSel_Emit_ZoneRecord_S10(v, (unsigned char *)a2, k);
        }
    } else {
        if (z[0] & 0x80) WaveSel_Emit_ZoneRecord_S6(v, (unsigned char *)a2, k);
        else WaveSel_Emit_ZoneRecord_S4(v, (unsigned char *)a2, k);
    }
}

void Voice_Clear_HoldBit(unsigned char n)
{
    ram_14af[(int)n * 39] &= 0x7f;
    ram_2936[(int)(n >> 4)] &= ~((unsigned int)1 << (n & 0xf));
    Voice_Reprioritise(ram_148d + (int)n * 39);
}

void TVF_Emit_Offset_Both(unsigned char *v)
{
    unsigned int d;
    if (W(P(v, 39), 24) & 0x40) {
        if (W(P(v, 39), 24) & 0x80) d = (SW(v, 66) & 0x7f) - (char)P(v, 35)[31];
        else d = (SW(v, 66) & 0x7f) + (char)P(v, 35)[31];
        ram_451d4 = (SW(v, 66) & 0xff80) | (d = TVF_Clamp_Cutoff(d));
        ram_451d6 = (W(v, 68) & 0xff80) | d;
    } else {
        ram_451d4 = SW(v, 66);
        ram_451d6 = SW(v, 68);
    }
}

void Voice_Freq_WriteLeft(unsigned char n)
{
    unsigned int w;
    unsigned char *p;
    unsigned long x;
    p = (unsigned char *)(void *)(ram_44260 + (int)n * 27);
    if (n < 0x40) {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        w = EGEnv_ModeBits_Table[p[0] & 3];
        ram_45204 = (unsigned int)x | w;
    } else {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        w = EGEnv_ModeBits_Table[p[0] & 3];
        ram_4520e = (unsigned int)x | w;
    }
}

/* ---- not tried before (pool_A_remaining) ---- */

void VoiceState_SwapSlot_HL_IY(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char x, y;
    x = ROW(a)->prev[(unsigned int)c];
    y = ROW(a)->next[(unsigned int)c];
    ROW(y)->prev[(unsigned int)c] = x;
    ROW(x)->next[(unsigned int)c] = y;
    y = ROW(e)->next[(unsigned int)c];
    ROW(y)->prev[(unsigned int)c] = a;
    ROW(a)->next[(unsigned int)c] = y;
    ROW(a)->prev[(unsigned int)c] = e;
    ROW(e)->next[(unsigned int)c] = a;
}

void Voice_Slot_CalcArticParams(unsigned char part)
{
    unsigned int i;
    char d1;
    char d2;
    unsigned char *s;
    unsigned int w;
    d1 = ram_41474[part * 0x11f];
    d2 = ram_41475[part * 0x11f];
    s = *(unsigned char **)&ram_413d6[part * 0x11f];
    for (i = 0; i < 4; i++, s += 81) {
        w = *(unsigned int *)((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287) + ((unsigned long)i * 2 + 0x102));
        s[2] = w;
        s[3] = (s[3] & 0xf0) | ((w >> 8) & 0xf);
        if (i < 3) {
            Voice_SignedClamp(s + 39, d1, 0x64, 0);
            Voice_SignedClamp(s + 45, d2, 0x64, 0);
        } else {
            Voice_SignedClamp(s + 23, ram_41472[part * 0x11f], 0x7f, 0);
            Voice_SignedClamp(s + 41, ram_41473[part * 0x11f], 0x64, 0);
            Voice_SignedClamp(s + 43, ram_41473[part * 0x11f], 0x64, 0);
        }
    }
}
