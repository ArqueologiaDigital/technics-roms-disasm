/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AP_24b.c (2026-11-19-24-sub-r24a)
   sha256 9029a408e3c2c3a9b2455df6d150034bf0d466f1858942799be87ea150f2638c (name+funcs); compiled at -Xr */
/* lane_sub helper AP, round 24, form b: sub_AP_24a.c (read its header) with these spellings changed:
   - Voice2_UpdatePitch: e a plain pointer local whose address is taken once, `(void *)&e;` (idiom (ab)), instead
     of volatile, to keep it out of XIZ.
   - Voice_StereoLevel_Compute: `Curve[..] + (unsigned int)k` for channels 1-2 (operands swapped).
   - Voice_Pitch_Compute: the bend tables back to int, each value and q+12 through the int temporary t
     (`t = Table[..]; p += t;`); the chromatic column in a byte local c computed first.
   - Voice_Freq_WriteLeft: `ram = w | (unsigned int)x;`.
   - DSP_VoiceCoeffRoute: round 23a's two statements `tbl = RelBase; tbl += off;` with tbl declared before off
     (23a gave tbl XBC; the declaration order moved registers in 23c).
   cc900-options: -Xr
*/

struct r16 { unsigned char b[16]; };
struct b4 { unsigned char b0, b1, b2, b3; };

extern unsigned long ToneDB_RelBase;
extern unsigned long *ToneDB_RootPtr;
extern unsigned char ram_45210[];
extern unsigned char ram_41368[];
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char ram_44260[];
extern unsigned int ram_451cc[];
extern unsigned int ram_451e0;
extern unsigned int ram_451f2;
extern unsigned int ram_451f4;
extern unsigned int ram_451f6;
extern unsigned int ram_45204;
extern unsigned int ram_4520e;
extern int ram_41349;
extern int ram_41366;
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned int Voice_FreqWrite_BaseCurve[];
extern unsigned char Voice_EnvelopeLevel_Curve[];
extern int Voice_KeyBend_Type41_Table[];
extern int Voice_KeyBend_Type42_Table[];
extern char Voice_ChromaticBend_Table[][12];

unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
extern int Int_ClampSignedToRange(int a, int hi, int lo);
extern int Pan_ScaleWithVelocity(int a, int b, int c, int d, int e);
extern int PitchBend_Scale(int a, int b, int c);
extern int Detune_ScaleSymmetric(int a);
int Pitch_Get_Patch_Octave_Shift(int a, int c);
unsigned int ScaleTune_Is_Global_Enabled(void);
unsigned char ScaleTune_Get_Global_Mode(void);
char ScaleTune_Get_User_Offset(unsigned char n);
unsigned int Pitch_Saturate_15bit(unsigned int a);
int Pitch_Fold_Octaves_Into_Range(int a, int lo, int hi);
int Pitch_Clamp_Into_Range(int a, int lo, int hi);
unsigned int ExtVoice_Alloc_StreamSlot(unsigned char a, unsigned char c, unsigned char e);
void TG_WriteExtParam_Mute_TypeDisp(unsigned int ch);
void TG_WriteExtParams_TypeDispatch(unsigned int ch, unsigned int *blk);
void ToneGen_WrExtParam_TypeDisp_Sgl(unsigned int ch, unsigned int *blk);
void Voice_OpSlot_WriteParams(int part, unsigned char *rec, int slot, int k, int voice);
void Voice_Freq_WriteRight(unsigned char n);
void Voice_Freq_WriteLeft(unsigned char n);
void DSP_VoiceCoeffRoute(unsigned char part, unsigned char sel);
void Voice_StereoLevel_Compute(unsigned char *v);
void Voice_Pitch_Compute(unsigned char *v);
void Voice2_UpdatePitch(unsigned char *v);

/* cc900-module: EnvDepth_Cap Voice_Freq_WriteLeft */
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
        ram_45204 = w | (unsigned int)x;
    } else {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        w = EGEnv_ModeBits_Table[p[0] & 3];
        ram_4520e = w | (unsigned int)x;
    }
}

void DSP_VoiceCoeffRoute(unsigned char part, unsigned char sel)
{
    unsigned int n;
    unsigned int d;
    unsigned char *tbl;
    unsigned char *off;
    unsigned char s;
    unsigned int x;
    unsigned int y;
    unsigned int i;
    s = sel;
    s &= 15;
    x = (*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110])[2];
    x &= 127;
    y = (*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110])[3];
    y &= 15;
    switch ((int)(*(unsigned char **)&((unsigned char *)(unsigned long)(ram_41368 + (part) * 0x11f))[(int)(s) * 37 + 110])[3] & 192) {
    case 0x00:
        off = (unsigned char *)ToneDB_RootPtr[17];
        break;
    case 0x40:
        off = (unsigned char *)ToneDB_RootPtr[19];
        break;
    case 0x80:
        off = (unsigned char *)ToneDB_RootPtr[18];
        break;
    case 0xc0:
        off = (unsigned char *)ToneDB_RootPtr[17];
        break;
    }
    d = *(unsigned long *)((unsigned long)(((y << 7) + x) * 2) + (unsigned long)off + ToneDB_RelBase);
    off = (unsigned char *)ToneDB_RootPtr[20];
    tbl = (unsigned char *)ToneDB_RelBase;
    tbl += (unsigned long)off;
    n = 13;
    for (i = 0; i < n; i++)
        ram_45210[i + 6] = tbl[(unsigned long)d * 16 + i];
    ram_45210[n + 6] = ((struct r16 *)(tbl + (unsigned long)d * 16))->b[13];
    n++;
    ram_45210[n + 6] = (unsigned char)(d & 0xff);
    n++;
    ram_45210[n + 6] = (unsigned char)(d >> 8);
    n++;
}

/* cc900-module: Detune_ScaleSymmetric Int_ClampSignedToRange Pan_ScaleWithVelocity PitchBend_Scale Voice_StereoLevel_Compute */
void Voice_StereoLevel_Compute(unsigned char *v)
{
    unsigned char *p;
    unsigned char *s;
    int l1, l2, l3;
    int k, t, d;
    p = *(unsigned char **)(v + 23);
    s = p;
    if (p[71] != 0) {
        k = PitchBend_Scale((char)s[71], v[12], 4);
        if (s[63] != 0) l1 = Voice_EnvelopeLevel_Curve[s[63]] + (unsigned int)k;
        else l1 = Voice_EnvelopeLevel_Curve[s[63]];
        if (s[65] != 0) l2 = Voice_EnvelopeLevel_Curve[s[65]] + (unsigned int)k;
        else l2 = Voice_EnvelopeLevel_Curve[s[65]];
        if (s[67] != 0) l3 = k + Voice_EnvelopeLevel_Curve[s[67]];
        else l3 = Voice_EnvelopeLevel_Curve[s[67]];
    } else {
        l1 = Voice_EnvelopeLevel_Curve[s[63]];
        l2 = Voice_EnvelopeLevel_Curve[s[65]];
        l3 = Voice_EnvelopeLevel_Curve[s[67]];
    }
    if (s[74] != 0) l1 += Pan_ScaleWithVelocity(*(int *)(v + 8), s[73], 0, 0x7f, (char)s[74]);
    l1 = Int_ClampSignedToRange(l1, 0xff, 0);
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[64] + (int)(char)s[61], 50, -50));
    ram_451f2 = (l1 << 8) | (d & 0xff);
    if (s[75] != 0) {
        t = Pan_ScaleWithVelocity(*(int *)(v + 8), s[73], 0, 0x7f, (char)s[75]);
        l2 = Int_ClampSignedToRange(l2 + t, 0xff, 0);
        l3 = Int_ClampSignedToRange(l3 + t, 0xff, 0);
    } else {
        l2 = Int_ClampSignedToRange(l2, 0xff, 0);
        l3 = Int_ClampSignedToRange(l3, 0xff, 0);
    }
    t = Int_ClampSignedToRange((int)(char)s[66] + (int)(char)s[61], 50, -50);
    t = Detune_ScaleSymmetric(t);
    d = Detune_ScaleSymmetric(Int_ClampSignedToRange((int)(char)s[68] + (int)(char)s[61], 50, -50));
    ram_451f4 = (l2 << 8) | (t & 0xff);
    ram_451f6 = (l3 << 8) | (d & 0xff);
}

/* cc900-module: Pitch_Clamp_Into_Range Pitch_Fold_Octaves_Into_Range Pitch_Get_Patch_Octave_Shift Pitch_Saturate_15bit Voice_Pitch_Compute */
void Voice_Pitch_Compute(unsigned char *v)
{
    unsigned char *q;
    unsigned char part;
    int p;
    int t;
    unsigned char m;
    unsigned char c;
    q = *(unsigned char **)(v + 31);
    part = v[4];
    p = v[5];
    p <<= 8;
    p &= 0x7f00;
    p += 0x80;
    p += ram_41349;
    p += (int)(*(char **)(v + 35))[22] << 8;
    p += (int)(*(char **)(v + 35))[109] << 8;
    p += Pitch_Get_Patch_Octave_Shift(v[4], (*(unsigned char **)(v + 19))[41]);
    if (ScaleTune_Is_Global_Enabled() != 0) {
        if (*(unsigned int *)&ram_4136a[(int)part * 287] & 0x100) {
            switch (ScaleTune_Get_Global_Mode()) {
            case 0:
                break;
            case 0x40:
                p += ram_41366;
                break;
            case 0x41:
                t = Voice_KeyBend_Type41_Table[v[5] & 0x7f];
                p += t;
                break;
            case 0x42:
                t = Voice_KeyBend_Type42_Table[v[5] & 0x7f];
                p += t;
                break;
            case 0x80:
            default:
                t = ScaleTune_Get_User_Offset((v[5] & 0x7f) % 12);
                p += t + t;
                break;
            }
        }
    } else {
        m = (*(unsigned char **)&ram_4136e[(int)part * 287])[19];
        switch (m) {
        case 0:
            break;
        case 0x40:
            p += ram_41366;
            break;
        case 0x41:
            t = Voice_KeyBend_Type41_Table[v[5] & 0x7f];
            p += t;
            break;
        case 0x42:
            t = Voice_KeyBend_Type42_Table[v[5] & 0x7f];
            p += t;
            break;
        case 0x80:
            break;
        default:
            c = (v[5] & 0x7f) % 12;
            t = ((char *)Voice_ChromaticBend_Table + (int)m * 12)[c];
            p += t + t;
            break;
        }
    }
    *(unsigned int *)(v + 8) = Pitch_Saturate_15bit(p);
    m = (*(unsigned char **)(v + 23))[6] & 7;
    if ((*q & 2) == 0) {
        if (m != 7) {
            p -= ((int)q[11] << 8) + 0x80;
            p >>= m;
            t = *(int *)(q + 12);
            p += t;
        } else p = *(int *)(q + 12);
    } else {
        if (m != 7) {
            p -= 0x4280;
            p >>= m;
            p += 0x4280;
        } else p = 0x4280;
    }
    p += (int)(*(char **)(v + 23))[4] << 8;
    p += (int)(*(char **)(v + 39))[32] << 8;
    if (m == 0) *(int *)(v + 6) = Pitch_Fold_Octaves_Into_Range(p, q[9], q[10]);
    else *(int *)(v + 6) = Pitch_Clamp_Into_Range(p, q[9], q[10]);
}

/* cc900-name: TG_WriteExtParam_Mute_TypeDisp=ToneGen_WriteExtParam_Mute_TypeDispatch */
/* cc900-name: TG_WriteExtParams_TypeDispatch=ToneGen_WriteExtParams_TypeDispatch */
/* cc900-name: ToneGen_WrExtParam_TypeDisp_Sgl=ToneGen_WriteExtParam_TypeDispatch_Single */
/* cc900-module: Voice2_UpdatePitch Voice_Freq_WriteLeft Voice_Freq_WriteRight Voice_OpSlot_WriteParams */
void Voice2_UpdatePitch(unsigned char *v)
{
    unsigned char *q;
    unsigned char *r;
    unsigned char *e;
    unsigned int w;
    unsigned char part;
    unsigned char ty;
    unsigned char t;
    unsigned int ch;
    (void *)&e;
    ram_451e0 = 0x4400;
    q = *(unsigned char **)(v + 35);
    r = *(unsigned char **)(v + 39);
    part = v[4];
    if (*(unsigned int *)(r + 30) == 0) return;
    t = (unsigned char)*(unsigned int *)(r + 30) & 3;
    ty = t;
    if (((struct b4 *)&(*(unsigned char **)(v + 19))[((int)t << 2) + 0x4b])->b2 & 0x80) {
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (int)ty | 0x28);
        ch = w & 0xff;
        TG_WriteExtParam_Mute_TypeDisp(ch);
    } else {
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (int)ty | 8);
        ch = w & 0xff;
    }
    e = ram_44260 + (unsigned long)ch * 27;
    e[6] = v[12];
    if (ch >= 0x80) return;
    ram_451e0 |= (*(unsigned int *)(r + 30) & 0x3300) | ch;
    if (!(w & 0x8000) || (*(unsigned int *)q & 0xc)) {
        Voice_OpSlot_WriteParams(part, q, ty, 2, (unsigned char)ch);
        Voice_Freq_WriteRight((unsigned char)ch);
        TG_WriteExtParams_TypeDispatch(ch, ram_451cc);
    }
    if ((e[7] != 0 && (*(unsigned int *)(q + 2) & 0x2000)) || (e[0] & 0x20)) {
        e[8] = 0;
        e[0] &= 0xf3;
        e[0] |= 0x10;
        ram_45204 = 0;
        ram_4520e = 0;
        ToneGen_WrExtParam_TypeDisp_Sgl(ch, ram_451cc);
        return;
    }
    if ((e[5] != 0 || !(w & 0x8000)) && !(e[0] & 0x38)) {
        Voice_Freq_WriteLeft((unsigned char)ch);
        ToneGen_WrExtParam_TypeDisp_Sgl(ch, ram_451cc);
    } else if (*(unsigned int *)q & 0xc) {
        Voice_Freq_WriteLeft((unsigned char)ch);
        ToneGen_WrExtParam_TypeDisp_Sgl(ch, ram_451cc);
    }
}
