/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17a.c (2026-11-16-126-sub-r17)
   sha256 4236702b3d6d2cd4a34bd2c4b4787b866c2680f5404a1df78ec1c7768ec2066d (name+funcs); compiled at -Xr */
extern int ram_41349;
unsigned int Pitch_Saturate_15bit(unsigned int a);
int Pitch_Fold_Octaves_Into_Range(int a, int lo, int hi);
void Voice_Slot_ComputePitch(unsigned char *v)
{
    unsigned char *s;
    unsigned char *t23;
    unsigned char *t31;
    int p;
    s = (*(unsigned char **)((v) + (35)));
    t23 = (*(unsigned char **)((v) + (23)));
    t31 = (*(unsigned char **)((v) + (31)));
    p = v[5] & 0x7f;
    p <<= 8;
    p += 0x80;
    p += (*(int *)((s) + (274)));
    p += ram_41349;
    p += (int)(char)s[22] << 8;
    p += (int)(char)s[109] << 8;
    (*(unsigned int *)((v) + (8))) = Pitch_Saturate_15bit(p);
    p -= ((int)t31[11] << 8) + 0x80;
    p += (*(unsigned int *)((t31) + (12)));
    p += (int)(char)t23[3] << 8;
    p += (char)t23[4];
    (*(int *)((v) + (6))) = Pitch_Fold_Octaves_Into_Range(p, t31[9], t31[10]);
}
