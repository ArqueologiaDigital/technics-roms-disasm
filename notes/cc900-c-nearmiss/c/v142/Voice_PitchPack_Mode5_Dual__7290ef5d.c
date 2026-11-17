/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_params_and_tvf_a_11a.c (2026-11-16-101-sub-r14)
   sha256 7290ef5d885c32ebf80e86731d54829de671490f993f73c52901608f1ed37610 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern int __near ram_2940;
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s);
void Voice_PitchPack_Mode5_Dual(unsigned char *v)
{
    unsigned char *z;
    int c1, c2;
    unsigned int x;
    z = (*(unsigned char **)((v) + (23)));
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (35)))) + (2))) & 0x200) {
        c1 = z[77];
        c2 = z[79];
    } else {
        c1 = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
        c2 = (int)z[79] + (char)(*(unsigned char **)((v) + (35)))[103];
    }
    c1 = TVF_Calc_Cutoff(v, c1, (char)z[55], (char)z[60]);
    c2 = TVF_Calc_Cutoff(v, c2, (char)z[55], (char)z[60]);
    x = ((unsigned int)z[78] << 13) | ((unsigned int)z[80] << 10);
    (*(int *)((v) + (66))) = (c1 | x) | 0x80;
    (*(int *)((v) + (68))) = c2;
    ram_2940 = 0;
}
