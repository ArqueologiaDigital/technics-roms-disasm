/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_A_9c.c (2026-11-16-86-sub-r9)
   sha256 78ecbab13a5dc7797897ffde8967cd943b6b5f2f2195ecc3768976b9be2e7cb2 (name+funcs); compiled at -Xr */
/* lane_sub helper A, round 9, form c (third spellings): functions of the KN5000 sub-CPU payload v1.42 (v142/subcpu, core/05 and
   core/07).  Round-8 misses refined, plus new module-local callers.  Names are the tree's labels; ram_<hex> is a RAM
   cell (sub-CPU address) the tree has not named.  Voice (71 B), node (39 B), part (287 B) and row (5 B / 12 B / 27 B)
   records have odd field offsets, so they are read through char pointers (B / W / SW / P). */

/* cc900-module: Voice_List_MoveToPool */
/* cc900-module: Voice_List_MoveToPartList */
/* cc900-module: Voice_PerVoice_PortamentoPitchUpdate */
/* cc900-module: Voice_Demote_Decayed */
/* cc900-module: Voice_Reprioritise */
/* cc900-module: DList_Unlink_SelfLink_Offsets16 */
/* cc900-module: TVF_Calc_Cutoff_NoKeyFollow */
/* cc900-module: TVF_Bias_Clamp_Amount */
/* cc900-module: TVF_Lookup_Depth_Amount */
/* cc900-module: TVF_Clamp_Cutoff */
/* cc900-module: Voice_Clamp_Byte_WA */
/* cc900-module: EnvDepth_Cap */
/* cc900-module: VoiceRow_FetchPair_DE_WA */
/* cc900-module: VoiceRow_FetchPair_WA_SP */
/* cc900-module: Voice_Selector_Unpack3Groups */
/* cc900-module: WaveSel_Emit_ZoneRecord_S4 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S6 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S10 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S12 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S13 */
/* cc900-module: WaveSel_Emit_ZoneRecord_S15 */
/* cc900-module: WaveSel_KeyTable_Lookup */
/* cc900-module: Voice_Selector_FindBestSlot */
/* cc900-module: VoiceState_SwapSlot_DE_BC */
/* cc900-module: VoiceState_SwapSlot_HL_IY */
/* cc900-module: TVF_Calc_Cutoff */

#define B(p, o) (*(unsigned char *)((p) + (o)))
#define W(p, o) (*(unsigned int *)((p) + (o)))
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))

extern int __near ram_2940;
extern unsigned int ram_451d0;
extern unsigned int ram_451d4;
extern unsigned int ram_451d6;
extern unsigned int ram_45206;
extern unsigned int ram_4520a;
extern unsigned long ToneDB_RelBase;
extern unsigned int EGEnv_ValueCurve_Simple[];
extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_BaseCurve_B[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned int Voice_OutputLevel_Table[];
extern unsigned int Voice_Reg080_NoteField_Table[];
extern unsigned int Voice_Part_Trim_Table_A[];
extern unsigned int Voice_Part_Trim_Table_B[];
extern unsigned int Voice_Part_Trim_Base[];
extern unsigned int Voice_Part_Trim_Addend_1[];
extern unsigned int Voice_Part_Trim_Addend_2[];
extern char TVF_KeyFollow_Curves[][128];
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
extern unsigned char __near ram_1e4d[];
extern unsigned char __near ram_2126[];
extern unsigned char __near ram_24e6[];
extern unsigned int __near ram_2936[];

void Voice_List_MoveToPool(unsigned char *n, unsigned char *list, int k);
void Voice_List_MoveToPartList(unsigned char *n, unsigned char *list, int k);
/* cc900-name: Voice_PerVoice_PortaPitchUpd=Voice_PerVoice_PortamentoPitchUpdate */
void Voice_PerVoice_PortaPitchUpd(int n);
void DList_Unlink_SelfLink_Offsets16(unsigned char *n);
void Voice_Demote_Decayed(unsigned char *p);
void Voice_Reprioritise(unsigned char *p);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
int TVF_Clamp_Cutoff(int a);
int Voice_Clamp_Byte_WA(int a);
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
void VoiceRow_FetchPair_WA_SP(int a);
void VoiceRow_FetchPair_DE_WA(int a, int c);
void Voice_Selector_Unpack3Groups(unsigned char *p, unsigned int v, int e);
unsigned char WaveSel_KeyTable_Lookup(unsigned char *t, int k);
void WaveSel_Emit_ZoneRecord_S4(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S6(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S10(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S12(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S13(unsigned char *v, unsigned char *t, int i);
void WaveSel_Emit_ZoneRecord_S15(unsigned char *v, unsigned char *t, int i);
void VoiceState_SwapSlot_DE_BC(int a, int c);
void VoiceState_SwapSlot_HL_IY(int a, int c, int e);
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s);
void Voice_Selector_FindBestSlot(unsigned int *w, unsigned char *cnt, unsigned char *idx, unsigned char *val);

void Voice_Freq_WriteRight(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = (unsigned char *)(void *)(ram_44260 + (int)n * 27);
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    if (n < 0x40) {
        if (r > 0x3fff) r = 0x3fff;
        if (p[0] & 0x20) {
            r |= 0x8000;
            ram_45206 = r;
        } else ram_45206 = r;
    } else {
        if (r > 0x3fff) r = 0x3fff;
        ram_4520a = r;
    }
}

void Voice_PitchPack_RouteC(unsigned char *v)
{
    unsigned char *t;
    unsigned int r, x;
    t = P(v, 23);
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    x = ((unsigned int)t[18] << 13) | ((unsigned int)t[18] << 10);
    SW(v, 66) = r | x;
    SW(v, 68) = r;
    ram_2940 = 0;
}

void Voice_PitchPack_RouteD(unsigned char *v)
{
    unsigned char *t;
    unsigned int r, x;
    t = P(v, 23);
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    x = ((unsigned int)t[18] << 13) | ((unsigned int)t[18] << 10);
    SW(v, 66) = (r | x) | 0x80;
    r |= 0x80;
    SW(v, 68) = r;
    ram_2940 = 0;
}

void Voice_PitchPack_RouteE(unsigned char *v)
{
    unsigned char *t;
    unsigned int r1, r2, x;
    t = P(v, 23);
    r1 = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    r2 = TVF_Calc_Cutoff_NoKeyFollow(v, t[19]);
    x = ((unsigned int)t[18] << 13) | ((unsigned int)t[20] << 10);
    SW(v, 66) = (r1 | x) | 0x80;
    SW(v, 68) = r2;
    ram_2940 = 0;
}

void TVF_Build_Short(unsigned char *v)
{
    unsigned char *t;
    unsigned int r;
    unsigned int x;
    r = TVF_Calc_Cutoff_NoKeyFollow(v, (t = P(v, 23))[17]);
    x = ((unsigned int)t[18] << 13) | 0x400;
    SW(v, 66) = r | x;
    r = TVF_Bias_Clamp_Amount(t[19]);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t[20]);
}

void Voice_PitchPack_RouteB(unsigned char *v)
{
    unsigned char *t;
    unsigned int r;
    unsigned int x;
    r = TVF_Calc_Cutoff_NoKeyFollow(v, (t = P(v, 23))[17]);
    x = ((unsigned int)t[18] << 13) | 0x400;
    SW(v, 66) = (r | x) | 0x80;
    r = TVF_Bias_Clamp_Amount(t[19]);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t[20]);
}

int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s)
{
    unsigned int w;
    int k;
    unsigned char *t;
    int x;
    x = d;
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

int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    int k;
    unsigned char *t;
    int d;
    t = P(v, 23);
    d = (char)t[16];
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        d >>= 5;
        c += d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}

void Voice_Clear_HoldBit(unsigned char n)
{
    ram_14af[(int)n * 39] &= 0x7f;
    ram_2936[(int)(n >> 4)] &= ~(1 << (n & 0xf));
    Voice_Reprioritise(ram_148d + (int)n * 39);
}

void Voice_Reprioritise(unsigned char *p)
{
    if (p[34] & 0x80) return;
    if (p[37] < 0x80) Voice_Demote_Decayed(p);
    else if (p[34] & 8) {
        p[34] &= ~8;
        p[34] |= 4;
        Voice_List_MoveToPool(p, P(p, 29), p[38]);
    }
}

void Voice_AllVoices_PortamentoUpdate(void)
{
    unsigned char i;
    for (i = 0; i < 0x1a; i++) Voice_PerVoice_PortaPitchUpd(i);
}

void TVF_Emit_Offset_Reg100(unsigned char *v)
{
    if (W(P(v, 39), 24) & 0x40)
        ram_451d4 = (SW(v, 66) & 0xff80) | TVF_Clamp_Cutoff((W(P(v, 39), 24) & 0x80) ?
                                                             (SW(v, 66) & 0x7f) - (char)P(v, 35)[31] :
                                                             (SW(v, 66) & 0x7f) + (char)P(v, 35)[31]);
    else ram_451d4 = SW(v, 66);
    ram_451d6 = SW(v, 68);
}

void TVF_Emit_Offset_Both(unsigned char *v)
{
    int d;
    if (W(P(v, 39), 24) & 0x40) {
        if (W(P(v, 39), 24) & 0x80) d = (SW(v, 66) & 0x7f) - (char)P(v, 35)[31];
        else d = (SW(v, 66) & 0x7f) + (char)P(v, 35)[31];
        d = TVF_Clamp_Cutoff(d);
        ram_451d4 = (SW(v, 66) & 0xff80) | d;
        ram_451d6 = (SW(v, 68) & 0xff80) | d;
    } else {
        ram_451d4 = SW(v, 66);
        ram_451d6 = SW(v, 68);
    }
}

void Voice_Build_OutputLevel(unsigned char *v, int b)
{
    unsigned int w;
    b += SW(P(v, 35), 12);
    b += SW(P(v, 35), 16);
    b += SW(v, 51);
    b = Voice_Clamp_Byte_WA(b);
    b = Voice_OutputLevel_Table[b] * 2;
    if (P(v, 15)[2] & 0x80) w = ((unsigned int)P(v, 15)[2] & 0x70) << 8;
    else w = Voice_Reg080_NoteField_Table[W(v, 6) >> 8];
    ram_451d0 = b | w | 0x8000;
}

unsigned int EGEnv_Compute_A(unsigned char n)
{
    unsigned char *p;
    unsigned long x;
    p = ram_4424e + (int)n * 27;
    x = EGEnv_BaseCurve_A[p[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}

unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned char *p;
    unsigned long x;
    p = ram_44257 + (int)n * 27;
    x = EGEnv_BaseCurve_B[p[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}

void Voice_Retire_ToFreePool(unsigned char *v)
{
    if (!(v[34] & 1)) {
        if (P(v, 29)[1] != 0) P(v, 29)[1]--;
        Voice_List_MoveToPool(v, ram_132b, 6);
        Voice_List_MoveToPartList(v, ram_1481, 1);
        DList_Unlink_SelfLink_Offsets16(v);
        v[34] = 1;
        v[37] = 0;
        if (P(v, 29)[1] < P(v, 29)[0]) P(v, 29)[1]++;
    }
}

void VoiceSlot_UpdateNoteSource(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char *s;
    unsigned char *r;
    unsigned char k;
    s = &ram_2126[(int)a * 5];
    r = &ram_1e4d[(int)s[2] * 27];
    k = s[3];
    if (r[k] == a) {
        if (s[0] != a) r[k] = s[0];
        else r[k] = 0xff;
    }
    r = &ram_1e4d[(int)c * 27];
    if (r[e] > 0xc0) {
        r[e] = a;
        VoiceRow_FetchPair_WA_SP(a);
    } else VoiceRow_FetchPair_DE_WA(a, r[e]);
    s[2] = c;
    s[3] = e;
}

void Voice_Selector_FindBestSlot(unsigned int *w, unsigned char *cnt, unsigned char *idx, unsigned char *val)
{
    unsigned char g[10];
    unsigned char lo, hi, d;
    Voice_Selector_Unpack3Groups(g, w[0], 0);
    Voice_Selector_Unpack3Groups(g, w[1], 1);
    Voice_Selector_Unpack3Groups(g, w[2], 2);
    hi = 0xff;
    lo = 0xff;
    *cnt = 0;
    for (d = 0; d < 9; d++) {
        if (lo == 0xff && g[d] != 0) lo = d;
        if (g[d] >= 4) {
            (*cnt)++;
            if (hi == 0xff) hi = d;
        }
    }
    if (hi != 0xff) {
        *idx = hi;
        *val = g[hi];
    } else {
        *idx = lo;
        *val = g[lo];
    }
}

void WaveSel_StageB_Build_Reg040(unsigned char *v)
{
    unsigned char *z;
    unsigned char *a1;
    unsigned char *a2;
    unsigned char k;
    z = P(v, 31);
    a1 = (unsigned char *)(*(unsigned long *)(z + 1) + ToneDB_RelBase);
    a2 = (unsigned char *)(*(unsigned long *)(z + 5) + ToneDB_RelBase);
    k = a1[(unsigned int)WaveSel_KeyTable_Lookup((unsigned char *)(*(unsigned long *)a1 + ToneDB_RelBase), SW(v, 6))
           + 4];
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

void Voice_Selector_ComputeMixWeights(unsigned char part)
{
    unsigned char g0, g1, g2;
    unsigned int x;
    Voice_Selector_FindBestSlot((unsigned int *)&ram_4146a[(int)part * 287], &g2, &g1, &g0);
    *(unsigned int *)&ram_41476[(int)part * 287] = Voice_Part_Trim_Table_A[g2];
    *(unsigned int *)&ram_4147a[(int)part * 287] = Voice_Part_Trim_Table_B[g1];
    x = Voice_Part_Trim_Base[g2] + Voice_Part_Trim_Addend_1[g1] + Voice_Part_Trim_Addend_2[g0];
    *(unsigned int *)&ram_41478[(int)part * 287] = x;
}

void VoiceState_SwapSlot_Guarded(unsigned char a, unsigned char c, unsigned char e)
{
    unsigned char *r;
    unsigned char *s;
    unsigned char k;
    r = ram_24e6 + (int)a * 12;
    k = r[(int)c + 8];
    if (k < 0xc0) {
        s = &ram_2126[(int)k * 5];
        if (s[4] == a) {
            if (r[c] != a) s[4] = r[c];
            else s[4] = 0xff;
        }
    }
    s = &ram_2126[(int)e * 5];
    if (s[4] > 0x40) {
        s[4] = a;
        VoiceState_SwapSlot_DE_BC(a, c);
    } else VoiceState_SwapSlot_HL_IY(a, c, s[4]);
    r[(int)c + 8] = e;
}

void Voice_PitchPack_Mode5_Dual(unsigned char *v)
{
    unsigned char *z;
    int c1, c2;
    z = P(v, 23);
    if (W(P(v, 35), 2) & 0x200) {
        c1 = z[77];
        c2 = z[79];
    } else {
        c1 = z[77] + (char)P(v, 35)[103];
        c2 = z[79] + (char)P(v, 35)[103];
    }
    c1 = TVF_Calc_Cutoff(v, c1, (char)z[55], (char)z[60]);
    c2 = TVF_Calc_Cutoff(v, c2, (char)z[55], (char)z[60]);
    SW(v, 66) = (c1 | (((unsigned int)z[78] << 13) | ((unsigned int)z[80] << 10))) | 0x80;
    SW(v, 68) = c2;
    ram_2940 = 0;
}
