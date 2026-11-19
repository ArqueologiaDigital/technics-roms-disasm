/* Functions of core/05_voice_params_and_tvf.s.
   Firmware C (cc900), staged: Toshiba V4.23 reproduces each function (notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv);
   the build does not compile this directory yet.  Names are the tree's; ram_<hex> is a RAM cell the tree spells
   as a number or as Payload_Bss_Start+offset.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern unsigned char ram_44260[];
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
void Voice_Freq_WriteLeft(unsigned char n);
void Voice_Pitch_Compute(unsigned char *v);
void Voice_Freq_WriteLeft(unsigned char n);
void Voice_Pitch_Compute(unsigned char *v);

/* cc900-module: EnvDepth_Cap Pitch_Clamp_Into_Range Pitch_Fold_Octaves_Into_Range Pitch_Get_Patch_Octave_Shift Pitch_Saturate_15bit Voice_Freq_WriteLeft Voice_Pitch_Compute */
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
        r = (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
        ram_45204 = r;
    } else {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        r = (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
        ram_4520e = r;
    }
}

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
            t = ((char *)(unsigned long)(Voice_ChromaticBend_Table + (int)m * 12))[(v[5] & 0x7f) % 12];
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
