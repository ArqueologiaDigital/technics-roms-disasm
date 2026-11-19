/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_23c.c (2026-11-19-18-sub-r23r-apdsp)
   sha256 4bb47e6b1f423e635d51a32314f6d326c8f5e602a1de1990e6490e2ab9aef8e9 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_4136a[];
extern unsigned char ram_4136e[];
extern int ram_41349;
extern int ram_41366;
extern int Voice_KeyBend_Type41_Table[];
extern int Voice_KeyBend_Type42_Table[];
extern char Voice_ChromaticBend_Table[][12];
int Pitch_Get_Patch_Octave_Shift(int a, int c);
unsigned int ScaleTune_Is_Global_Enabled(void);
unsigned char ScaleTune_Get_Global_Mode(void);
char ScaleTune_Get_User_Offset(unsigned char n);
unsigned int Pitch_Saturate_15bit(unsigned int a);
int Pitch_Fold_Octaves_Into_Range(int a, int lo, int hi);
int Pitch_Clamp_Into_Range(int a, int lo, int hi);
void Voice_Pitch_Compute(unsigned char *v)
{
    unsigned char *q;
    unsigned char part;
    int p;
    int t;
    unsigned char m;
    q = *(unsigned char **)(v + 31);
    part = v[4];
    p = (((int)v[5] << 8) & 0x7f00) + 0x80 + ram_41349;
    p += (int)(*(char **)(v + 35))[22] << 8;
    p += (int)(*(char **)(v + 35))[109] << 8;
    p += Pitch_Get_Patch_Octave_Shift(v[4], (*(unsigned char **)(v + 19))[41]);
    if (ScaleTune_Is_Global_Enabled() != 0) {
        if (*(unsigned int *)&ram_4136a[(int)part * 287] & 0x100) {
            m = ScaleTune_Get_Global_Mode();
            switch (m) {
            case 0:
                break;
            case 0x40:
                p += ram_41366;
                break;
            case 0x41:
                p += Voice_KeyBend_Type41_Table[v[5] & 0x7f];
                break;
            case 0x42:
                p += Voice_KeyBend_Type42_Table[v[5] & 0x7f];
                break;
            case 0x80:
            default:
                t = ScaleTune_Get_User_Offset((v[5] & 0x7f) % 12);
                t += t;
                p += t;
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
            p += Voice_KeyBend_Type41_Table[v[5] & 0x7f];
            break;
        case 0x42:
            p += Voice_KeyBend_Type42_Table[v[5] & 0x7f];
            break;
        case 0x80:
            break;
        default:
            t = Voice_ChromaticBend_Table[m][(v[5] & 0x7f) % 12];
            t += t;
            p += t;
            break;
        }
    }
    *(unsigned int *)(v + 8) = Pitch_Saturate_15bit(p);
    m = (*(unsigned char **)(v + 23))[6] & 7;
    if ((*q & 2) == 0) {
        if (m != 7) {
            p -= ((int)q[11] << 8) + 0x80;
            if (m & 0xf) p >>= 1;
            p += *(int *)(q + 12);
        } else p = *(int *)(q + 12);
    } else {
        if (m != 7) {
            p -= 0x4280;
            if (m & 0xf) p >>= 1;
            p += 0x4280;
        } else p = 0x4280;
    }
    p += (int)(*(char **)(v + 23))[4] << 8;
    p += (int)(*(char **)(v + 39))[32] << 8;
    if (m == 0) *(int *)(v + 6) = Pitch_Fold_Octaves_Into_Range(p, q[9], q[10]);
    else *(int *)(v + 6) = Pitch_Clamp_Into_Range(p, q[9], q[10]);
}
