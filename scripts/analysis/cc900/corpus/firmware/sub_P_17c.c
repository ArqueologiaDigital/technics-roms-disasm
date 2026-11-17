/* lane_sub helper P, round 17, form c (third spellings): functions of the KN5000 sub-CPU payload v1.42
   (v142/subcpu, core/05 and core/07) left in pool_A_remaining.  Same functions as sub_P_17a.c.
   Names are the tree's labels; ram_<hex> is a RAM cell (sub-CPU address) the tree has not named.

   Form c, per function:
   - TVF_Build_Dispatch: int; case 5 is the last statement with no break, the function falls off its end.
   - TVF_Emit_Offset_Reg100: the conditional's arms unsigned (no casts), converted once as the argument.
   - TVF_Emit_Offset_Both: d unsigned, the field read signed; the clamp's result assigned inside the first OR.
   - TVF_Calc_Cutoff: k and w each declared in their own inner block.
   - Voice_Clear_HoldBit: `(unsigned int)1` shifted; the index shifted as an unsigned int.
   - Voice_Retire_ToFreePool: the list heads through a register pointer local; last test through the local.
   - EGEnv_Compute_A / _B: no temporary, `(r = (unsigned int)x) | table word`.
   - PitchBend_Scale: `r = table[b] * k` in one statement.
   - Voice_PortamentoTarget_SetSlot: byte-pointer local cast to the slot struct for the store.
   - Voice_Slot_ComputePitch: first three terms in one expression, the rest += ; zone word `p = p + ...`.
   - TVF_Lookup_Depth_Amount: hi and lo ints.
   - ToneGen_SilenceChannel: the channel kept in a two-byte array local.
   - VoiceState_SwapSlot_DE_BC: two-dimensional rows with (int) / (unsigned int) index casts.
   - Voice_PortamentoTargets_SetAll: the stored value cast to int.
   - Voice_ScanSlots_ReassignSources: plain char slot byte, no j local (the slot passed as (unsigned char)s).
   - Voice_AdvanceSlotIterator: the factor 0x30 through a byte local assigned in a statement.
   - Voice_Selector_ComputeMixWeights: the three result pointers cast to (void *) parameters.
   - WaveSel_StageB_Build_Reg040: round 11's form, only the key-table address cast to a pointer before the add.
   - Voice_Freq_WriteLeft: no temporaries.
   - OutputBuf_Flush_B: the emit loop written with a label and goto.
   - Voice_PortaLevel_Compute: form a with the locals declared in the opposite order.
   - Voice_PitchBend: both cases through a patch-pointer local. */

/* cc900-module: TVF_Set_Bypass */
/* cc900-module: TVF_Build_Full */
/* cc900-module: Voice_PitchPack_Mode2 */
/* cc900-module: Voice_PitchPack_Mode3 */
/* cc900-module: Voice_PitchPack_Mode4_Single */
/* cc900-module: Voice_PitchPack_Mode5_Dual */
/* cc900-module: TVF_Clamp_Cutoff */
/* cc900-module: Voice_Reprioritise */
/* cc900-module: Voice_List_MoveToPool */
/* cc900-module: Voice_List_MoveToPartList */
/* cc900-module: DList_Unlink_SelfLink_Offsets16 */
/* cc900-module: EnvDepth_Cap */
/* cc900-module: Quad_Decode_A_To_L */
/* cc900-module: VoiceSlot_UpdateNoteSource */
/* cc900-module: VoiceState_SwapSlot_DE_BC */
/* cc900-module: Voice_Selector_FindBestSlot */
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
/* cc900-module: AudioChannel_Dispatch */

/* cc900-data: TVF_Build_Dispatch 1 = TVF_Build_CaseOffsets */

#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))

struct pslot { unsigned char *src; unsigned char *tone; };

extern unsigned char __tiny ram_18;
extern unsigned int ram_100000;
extern unsigned int ram_100002;
extern int __near ram_2940;
extern int ram_41349;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_451e2;
extern unsigned int ram_451ea;
extern unsigned int ram_45204;
extern unsigned int ram_4520e;
extern unsigned long ToneDB_RelBase;
extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_BaseCurve_B[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned int Voice_FreqWrite_BaseCurve[];
extern unsigned int Voice_Part_Trim_Table_A[];
extern unsigned int Voice_Part_Trim_Table_B[];
extern unsigned int Voice_Part_Trim_Base[];
extern unsigned int Voice_Part_Trim_Addend_1[];
extern unsigned int Voice_Part_Trim_Addend_2[];
extern char TVF_KeyFollow_Curves[][128];
extern unsigned char TVF_DepthRecords_A[][3];
extern unsigned char TVF_DepthRecords_B[][3];
extern char PitchBend_ScaleCoeff_Table[];
extern unsigned char Voice_DepthMirror_Table[];
extern unsigned char Voice_DefaultToneRecord[];
extern unsigned char ram_41368[];
extern unsigned char ram_4136e[];
extern unsigned char ram_4146a[];
extern unsigned char ram_41476[];
extern unsigned char ram_41478[];
extern unsigned char ram_4147a[];
extern unsigned char ram_4424e[];
extern unsigned char ram_44257[];
extern unsigned char ram_44260[];
extern unsigned char __near ram_14af[];
extern unsigned char __near ram_148d[];
extern unsigned char __near ram_132b[];
extern unsigned char __near ram_1481[];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_2128[];
extern unsigned char __near ram_212a[];
extern unsigned char __near ram_24e6[][12];
extern unsigned int __near ram_2936[];

int TVF_Set_Bypass(unsigned char *v);
int TVF_Build_Full(unsigned char *v);
int Voice_PitchPack_Mode2(unsigned char *v);
int Voice_PitchPack_Mode3(unsigned char *v);
int Voice_PitchPack_Mode4_Single(unsigned char *v);
void Voice_PitchPack_Mode5_Dual(unsigned char *v);
int TVF_Clamp_Cutoff(int a);
void Voice_Reprioritise(unsigned char *p);
void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, int k);
void DList_Unlink_SelfLink_Offsets16(unsigned char *n);
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
unsigned int Pitch_Saturate_15bit(unsigned int a);
int Pitch_Fold_Octaves_Into_Range(int a, int lo, int hi);
unsigned char Quad_Decode_A_To_L(int a);
void VoiceSlot_UpdateNoteSource(int a, int c, int e);
void VoiceState_SwapSlot_DE_BC(int a, int c);
void Voice_Selector_FindBestSlot(unsigned char *w, void *cnt, void *idx, void *val);
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
int AudioChannel_Dispatch(int a, unsigned int b, unsigned char *d);

/* ---- near misses ---- */

int TVF_Build_Dispatch(unsigned char *v)
{
    switch (P(v, 23)[54] & 7) {
    default:
    case 0:
        return TVF_Set_Bypass(v);
    case 1:
        return TVF_Build_Full(v);
    case 2:
        return Voice_PitchPack_Mode2(v);
    case 3:
        return Voice_PitchPack_Mode3(v);
    case 4:
        return Voice_PitchPack_Mode4_Single(v);
    case 5:
        Voice_PitchPack_Mode5_Dual(v);
    }
}

void TVF_Emit_Offset_Reg100(unsigned char *v)
{
    if (W(P(v, 39), 24) & 0x40)
        ram_451d4 = (SW(v, 66) & 0xff80) | TVF_Clamp_Cutoff((W(P(v, 39), 24) & 0x80) ?
                                                             (W(v, 66) & 0x7f) - (char)P(v, 35)[31] :
                                                             (W(v, 66) & 0x7f) + (char)P(v, 35)[31]);
    else ram_451d4 = SW(v, 66);
    ram_451d6 = SW(v, 68);
}

void TVF_Emit_Offset_Both(unsigned char *v)
{
    unsigned int d;
    if (W(P(v, 39), 24) & 0x40) {
        if (W(P(v, 39), 24) & 0x80) d = (SW(v, 66) & 0x7f) - (char)P(v, 35)[31];
        else d = (SW(v, 66) & 0x7f) + (char)P(v, 35)[31];
        ram_451d4 = (SW(v, 66) & 0xff80) | (int)(d = TVF_Clamp_Cutoff(d));
        ram_451d6 = (W(v, 68) & 0xff80) | d;
    } else {
        ram_451d4 = SW(v, 66);
        ram_451d6 = SW(v, 68);
    }
}

int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s)
{
    unsigned char *t;
    int x;
    x = d;
    t = P(v, 23);
    if (x != 0) {
        int k;
        k = TVF_KeyFollow_Curves[(t[54] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        x = x * k >> 5;
        c += x;
    }
    if (s != 0) {
        unsigned int w;
        w = (W(v, 8) & 0x7f00) >> 8;
        if (w > t[59]) w = t[59];
        else if (w < t[58]) w = t[58];
        w -= t[57];
        c += (s * (int)w) >> 5;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}

void Voice_Clear_HoldBit(unsigned char n)
{
    ram_14af[(int)n * 39] &= 0x7f;
    ram_2936[(int)((unsigned int)n >> 4)] &= ~((unsigned int)1 << (n & 0xf));
    Voice_Reprioritise(ram_148d + (int)n * 39);
}

void Voice_Retire_ToFreePool(unsigned char *v)
{
    register unsigned char *q;
    if (!(v[34] & 1)) {
        if (P(v, 29)[1] != 0) P(v, 29)[1]--;
        q = ram_132b;
        Voice_List_MoveToPool(v, q, 6);
        q = ram_1481;
        Voice_List_MoveToPartList(v, q, 1);
        DList_Unlink_SelfLink_Offsets16(v);
        v[34] = 1;
        v[37] = 0;
        q = P(v, 29);
        if (q[1] < q[0]) P(v, 29)[1]++;
    }
}

unsigned int EGEnv_Compute_A(unsigned char n)
{
    unsigned int w;
    unsigned int r;
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = ram_4424e + (int)n * 27;
    p = u;
    w = EGEnv_BaseCurve_A[u[1]];
    x = w;
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (r = (unsigned int)x) | EGEnv_ModeBits_Table[p[0] & 3];
}

unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned int w;
    unsigned int r;
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = ram_44257 + (int)n * 27;
    p = u;
    w = EGEnv_BaseCurve_B[u[1]];
    x = w;
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (r = (unsigned int)x) | EGEnv_ModeBits_Table[p[0] & 3];
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
    r = PitchBend_ScaleCoeff_Table[b] * k;
    return r >> e;
}

void Voice_PortamentoTarget_SetSlot(unsigned char part, unsigned char slot)
{
    unsigned char *s;
    s = &((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287))[(int)slot * 37 + 0x6e];
    ((struct pslot *)s)->tone = Voice_DefaultToneRecord;
}

void Voice_Slot_ComputePitch(unsigned char *v)
{
    unsigned char *s;
    unsigned char *t23;
    unsigned char *t31;
    int p;
    s = P(v, 35);
    t23 = P(v, 23);
    t31 = P(v, 31);
    p = ((int)(v[5] & 0x7f) << 8) + 0x80 + SW(s, 274);
    p += ram_41349;
    p += (int)(char)s[22] << 8;
    p += (int)(char)s[109] << 8;
    W(v, 8) = Pitch_Saturate_15bit(p);
    p -= ((int)t31[11] << 8) + 0x80;
    p = p + SW(t31, 12);
    p += (int)(char)t23[3] << 8;
    p += (char)t23[4];
    SW(v, 6) = Pitch_Fold_Octaves_Into_Range(p, t31[9], t31[10]);
}

unsigned int TVF_Lookup_Depth_Amount(unsigned char a)
{
    int lo, hi;
    unsigned int n;
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
    return hi | lo;
}

void ToneGen_SilenceChannel(unsigned char ch)
{
    unsigned char c[2];
    c[0] = ch;
    ram_18 &= 0x7f;
    ram_100000 = (unsigned char)(c[0] + 0xc0);
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
    ram_18 &= 0x7f;
    ram_100000 = c[0];
    __ASM(" nop");
    ram_18 |= 0x80;
    ram_100002 = 0x7e00;
    __ASM(" jr $+2");
    __ASM(" nop");
    __ASM(" nop");
    __ASM(" nop");
}

/* cc900-name: VSwapSlot_DE_BC=VoiceState_SwapSlot_DE_BC */
void VSwapSlot_DE_BC(unsigned char a, unsigned char c)
{
    unsigned char x, y;
    x = ram_24e6[(int)a][(unsigned int)c];
    y = ram_24e6[(int)a][(unsigned int)c + 4];
    ram_24e6[(int)y][(unsigned int)c] = x;
    ram_24e6[(int)x][(unsigned int)c + 4] = y;
    ram_24e6[(int)a][(unsigned int)c] = a;
    ram_24e6[(int)a][(unsigned int)c + 4] = a;
}

void Voice_PortamentoTargets_SetAll(unsigned char part)
{
    unsigned int i;
    unsigned int v;
    for (i = 0; i < 4; i++) {
        v = (*(unsigned char **)((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287) + ((unsigned long)i * 37 + 0x6e)))[2];
        v |= (unsigned int)(*(unsigned char **)((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287) + ((unsigned long)i * 37 + 0x6e)))[3] << 8;
        *(unsigned int *)((unsigned char *)(unsigned long)(ram_41368 + (int)part * 287) + ((unsigned long)i * 2 + 0x102)) = (int)(v & 0xfff);
    }
}

void Voice_ScanSlots_ReassignSources(unsigned char a)
{
    unsigned char *r;
    unsigned char i;
    char s;
    unsigned char *q;
    r = ram_24e6[a];
    for (i = 0; i < 4; i++) {
        s = r[(int)i + 8];
        if ((unsigned char)s < 0xc0) {
            q = &ram_2126[(int)(unsigned char)s * 5];
            if (q[4] == a) {
                if (r[i] != a) q[4] = r[i];
                else {
                    q[4] = 0xff;
                    VoiceSlot_UpdateNoteSource((unsigned char)s, 0x1a, Quad_Decode_A_To_L((unsigned char)s));
                }
            }
            VoiceState_SwapSlot_DE_BC(a, i);
            r[(int)i + 8] = 0xff;
        }
    }
}

void Voice_AdvanceSlotIterator(unsigned char a)
{
    unsigned int i, end, j;
    unsigned char k;
    k = 0x30;
    i = k * a;
    end = i;
    end += 0x30;
    for (; i < end; i++) {
        if (ram_212a[i * 5] > 0x40 && ram_2128[i * 5] != 0x1a) {
            j = (unsigned char)i;
            VoiceSlot_UpdateNoteSource(j, 0x1a, Quad_Decode_A_To_L((unsigned char)i));
        }
    }
}

void Voice_Selector_ComputeMixWeights(unsigned char part)
{
    unsigned char g2, g1, g0;
    unsigned int x;
    Voice_Selector_FindBestSlot(&ram_4146a[(int)part * 287], (void *)&g2, (void *)&g1, (void *)&g0);
    *(unsigned int *)&ram_41476[(int)part * 287] = Voice_Part_Trim_Table_A[g2];
    *(unsigned int *)&ram_4147a[(int)part * 287] = Voice_Part_Trim_Table_B[g1];
    x = Voice_Part_Trim_Base[g2];
    x += Voice_Part_Trim_Addend_1[g1];
    x += Voice_Part_Trim_Addend_2[g0];
    *(unsigned int *)&ram_41478[(int)part * 287] = x;
}

void WaveSel_StageB_Build_Reg040(unsigned char *v)
{
    unsigned char *z;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char *p;
    unsigned char k;
    z = P(v, 31);
    a1 = (unsigned char *)(*(unsigned long *)(z + 1) + ToneDB_RelBase);
    a2 = (unsigned char *)(*(unsigned long *)(z + 5) + ToneDB_RelBase);
    p = (unsigned char *)*(unsigned long *)a1 + ToneDB_RelBase;
    k = a1[(int)WaveSel_KeyTable_Lookup(p, SW(v, 6)) + 4];
    if (z[0] & 0x40) {
        if (z[0] & 0x80) {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S15(v, a2, k);
            else WaveSel_Emit_ZoneRecord_S12(v, a2, k);
        } else {
            if (z[0] & 0x20) WaveSel_Emit_ZoneRecord_S13(v, a2, k);
            else WaveSel_Emit_ZoneRecord_S10(v, a2, k);
        }
    } else {
        if (z[0] & 0x80) WaveSel_Emit_ZoneRecord_S6(v, a2, k);
        else WaveSel_Emit_ZoneRecord_S4(v, a2, k);
    }
}

/* ---- not tried before ---- */

void Voice_Freq_WriteLeft(unsigned char n)
{
    unsigned char *p;
    unsigned long x;
    p = (unsigned char *)(void *)(ram_44260 + (int)n * 27);
    if (n < 0x40) {
        x = Voice_FreqWrite_BaseCurve[p[1]];
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        ram_45204 = (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
    } else {
        x = Voice_FreqWrite_BaseCurve[p[1]];
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        ram_4520e = (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
    }
}

void OutputBuf_Flush_B(unsigned char **pp, unsigned char *head, unsigned char key, char all)
{
    unsigned char *n;
    unsigned char *next;
    if (head != 0) {
        n = head;
        do {
            if (all != 0 || n[35] == key) {
emit:
                Voice_List_MoveToPartList(n, P(n, 24), 1);
                Voice_Reprioritise(n);
                **pp = n[36];
                *pp += 1;
                if (n == P(n, 16)) break;
                next = P(n, 16);
                DList_Unlink_SelfLink_Offsets16(n);
                n = next;
                goto emit;
            }
            n = P(n, 8);
        } while (n != head);
    }
    **pp = 0xff;
}

void Voice_PortaLevel_Compute(unsigned char *v)
{
    int c;
    unsigned int a;
    unsigned int b;
    unsigned char *t;
    if (((char *)(t = P(v, 23)))[7] < 0) {
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
    ram_451e2 = (a << 8) | (unsigned char)c;
    ram_451ea = (b << 8) | (unsigned char)Detune_ScaleSymmetric((char)(t[61] + t[62]));
}

void Voice_PitchBend(unsigned char *m)
{
    unsigned char part;
    unsigned int w;
    unsigned char *q;
    if (m[1] >= 0x1a) return;
    part = m[1];
    w = (unsigned int)m[3] << 7;
    w |= m[2] | 32768;
    switch ((*(unsigned char **)(ram_4136e + (int)part * 287))[16] & 0xc0) {
    case 0x00:
    case 0xc0:
    case 0x40:
        q = *(unsigned char **)(ram_4136e + (int)part * 287);
        AudioChannel_Dispatch(part, w, q + 20);
        return;
    case 0x80:
        q = *(unsigned char **)(ram_4136e + (int)part * 287);
        AudioChannel_Dispatch(part, w, q + 18);
        return;
    }
}
