/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the whole file of sub/sub_AP_25b.c (2026-11-19-27-sub-r25a)
   sha256 d48df07d0d144a128e95b025f156c4ab1a365b05046469cc84827425b08613bf (name+funcs); compiled at -Xr */
/* lane_sub helper AP, round 25, form b: form a with these spellings changed --
   Voice_Freq_WriteLeft `ram = Table[p[0] & 3] | (unsigned int)x;` (int table, operands swapped);
   Voice2_UpdatePitch the third argument `(unsigned int)ty | 0x28` and the base `&ram_44260[0] + (unsigned long)ch * 27`;
   Voice_Pitch_Compute `m = ScaleTune_Get_Global_Mode(); switch ((unsigned char)m)` (a conversion to force the copy).
   Form a's notes follow.
   Round 25, form a (KN5000 sub-CPU payload v1.42, core/05).  The three functions round 24
   (run 2026-11-19-24-sub-r24a) left open, each from its best form, changed only where that listing differs:
   - Voice_Freq_WriteLeft (24c +47): reusing w for the mode bits gave w BC for the whole function.  Back to round
     23's `ram = (unsigned int)x | Table[p[0] & 3];` with the table declared `int`, as in the built
     EGEnv_Compute_A (its listing loads the int table word into WA, x into BC, then ORs: the ROM's order).
   - Voice2_UpdatePitch (24a +50): `volatile` on e worked (ch now in IZ, e at (xsp+10)).  Left: the third argument
     (the ROM ORs 16-bit, then `ld e,a; extz de`; `(int)ty | 0x28` gave an 8-bit OR and no extz), now
     `(unsigned char)((int)ty | 0x28)`; and the record base, which the ROM loads with `lda` (ours `ld xwa,imm`),
     now `e = &ram_44260[(unsigned long)ch * 27];`.
   - Voice_Pitch_Compute (24 +121): from 24b (temporaries for the table values and q+12, which matched there), with
     m assigned from the mode call again (round 23 gave m L, the ROM's register; without it m went to C), the
     active switch `switch (m = ScaleTune_Get_Global_Mode())` (the ROM copies L to A before the compares; plain
     `switch (m)` compares L in place), the chromatic column back to the expression (24a's matched the ROM's
     `ld a,w; ld e,a`), and the row base built apart from the column the way Route2's record base is,
     `((char *)(unsigned long)(Voice_ChromaticBend_Table + m * 12))[col]` (the ROM widens the row offset, adds the
     base, then indexes with the column in DE; V4.23 had folded row and column into one 16-bit index).
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
    p = (unsigned char *)(void *)(ram_44260 + (int)n * 27);
    if (n < 0x40) {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        ram_45204 = EGEnv_ModeBits_Table[p[0] & 3] | (unsigned int)x;
    } else {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        ram_4520e = EGEnv_ModeBits_Table[p[0] & 3] | (unsigned int)x;
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
            m = ScaleTune_Get_Global_Mode();
            switch ((unsigned char)m) {
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
            t = ((char *)(unsigned long)(Voice_ChromaticBend_Table + m * 12))[(v[5] & 0x7f) % 12];
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
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned int)ty | 0x28);
        ch = w & 0xff;
        TG_WriteExtParam_Mute_TypeDisp(ch);
    } else {
        w = ExtVoice_Alloc_StreamSlot(part, v[0], (unsigned int)ty | 8);
        ch = w & 0xff;
    }
    e = &ram_44260[0] + (unsigned long)ch * 27;
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
