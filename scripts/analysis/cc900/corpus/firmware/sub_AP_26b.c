/* lane_sub helper AP, round 26, form b: form a with one change per function --
   Voice_Pitch_Compute the row base as `&Voice_ChromaticBend_Table[(int)m * 12]` inside the (unsigned long) cast;
   Voice2_UpdatePitch 25a's locals (e volatile, nothing address-taken) with the base through WriteLeft's spelling,
   `e = (unsigned char *)(void *)(ram_44260 + (unsigned long)ch * 27);` (which gives `lda` there);
   Voice_Freq_WriteLeft `r = Table[..] | (unsigned int)x;` (operands swapped).
   Form a's notes follow.
   Round 26, form a (KN5000 sub-CPU payload v1.42, core/05).  Every function starts from
   sub_AP_25a.c; real (non-branch) differences of run 2026-11-19-27-sub-r25a, read with idiff_full.py:
   - Voice_Pitch_Compute: 25a's only difference left is the chromatic row offset, `m * 12` done as an 8-bit
     `mul a,12` where the ROM does `extz wa; muls wa,12`.  Form a: `(int)m * 12`.  (The first-diff figure +146 vs
     23c's +31 is misleading: 25a fixed everything before it.)
   - Voice2_UpdatePitch: 25a's argument `(unsigned char)((int)ty | 0x28)` matched; its only difference left is the
     record base, `ld xwa,imm` where the ROM has `lda xwa`.  In 24b, where e was address-taken (`(void *)&e`), V4.23
     used `lda` but moved e to the top of the frame; the address-taken locals go top-down in declaration order.
     Form a: e, w, part and ty all address-taken, declared ty, part, w, e (so ty is highest, e lowest of them, as
     in the ROM's frame: e +10, w +14, part +16, ty +18), q and r plain (the spilled ones, lowest); no volatile.
   - Voice_Freq_WriteLeft: in a store, `(unsigned int)x | Table[..]` keeps x in WA and ORs the table word in BC.
     The built EGEnv_Compute_A's return gets the ROM's order (table into WA, x into BC, OR into BC) and then copies
     to HL; form a gives the OR a result local r of its own, `r = (unsigned int)x | Table[..]; ram = r;`.
   cc900-options: -Xr
*/

struct b4 { unsigned char b0, b1, b2, b3; };

extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char ram_44260[];
extern unsigned int ram_451cc[];
extern unsigned int ram_451e0;
extern unsigned int ram_45204;
extern unsigned int ram_4520e;
extern int ram_41349;
extern int ram_41366;
extern int EGEnv_ModeBits_Table[];
extern unsigned int Voice_FreqWrite_BaseCurve[];
extern int Voice_KeyBend_Type41_Table[];
extern int Voice_KeyBend_Type42_Table[];
extern char Voice_ChromaticBend_Table[];

unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
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
void Voice_Pitch_Compute(unsigned char *v);
void Voice2_UpdatePitch(unsigned char *v);

/* cc900-module: EnvDepth_Cap Voice_Freq_WriteLeft */
void Voice_Freq_WriteLeft(unsigned char n)
{
    unsigned int w;
    unsigned char *p;
    unsigned long x;
    unsigned int r;
    p = (unsigned char *)(void *)(ram_44260 + (int)n * 27);
    if (n < 0x40) {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        r = EGEnv_ModeBits_Table[p[0] & 3] | (unsigned int)x;
        ram_45204 = r;
    } else {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        r = EGEnv_ModeBits_Table[p[0] & 3] | (unsigned int)x;
        ram_4520e = r;
    }
}

/* cc900-module: Pitch_Clamp_Into_Range Pitch_Fold_Octaves_Into_Range Pitch_Get_Patch_Octave_Shift Pitch_Saturate_15bit Voice_Pitch_Compute */
void Voice_Pitch_Compute(unsigned char *v)
{
    unsigned char *q;
    unsigned char part;
    int p;
    int t;
    unsigned char m;
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
            switch (m = ScaleTune_Get_Global_Mode()) {
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
            t = ((char *)(unsigned long)&Voice_ChromaticBend_Table[(int)m * 12])[(v[5] & 0x7f) % 12];
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
    unsigned char * volatile e;
    unsigned int w;
    unsigned char part;
    unsigned char ty;
    unsigned char t;
    unsigned int ch;
    ram_451e0 = 0x4400;
    q = *(unsigned char **)(v + 35);
    r = *(unsigned char **)(v + 39);
    part = v[4];
    if (*(unsigned int *)(r + 30) == 0) return;
    t = (unsigned char)*(unsigned int *)(r + 30) & 3;
    ty = t;
    if (((struct b4 *)&(*(unsigned char **)(v + 19))[((int)t << 2) + 0x4b])->b2 & 0x80) {
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned char)((int)ty | 0x28));
        ch = w & 0xff;
        TG_WriteExtParam_Mute_TypeDisp(ch);
    } else {
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned char)((int)ty | 8));
        ch = w & 0xff;
    }
    e = (unsigned char *)(void *)(ram_44260 + (unsigned long)ch * 27);
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
