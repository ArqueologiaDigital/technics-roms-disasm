/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AR_39a.c (2026-11-19-84-sub-r39r)
   sha256 2103e71b9b99cb10996fb18388a6d3195fa891b82022ede544f65b9919caffea (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern int __near ram_2940;
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void Voice_PitchPack_Mode3(unsigned char *v)
{
    unsigned char *z;
    int r;
    unsigned int x;
    z = (*(unsigned char **)((v) + (23)));
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (35)))) + (2))) & 0x200) {
        r = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
        r = TVF_Calc_Cutoff(v, r, (char)z[55], (char)z[60]);
        x = ((unsigned int)z[78] << 13) | 0x400;
        (*(int *)((v) + (66))) = r | x;
        r = TVF_Bias_Clamp_Amount(0x48);
        (*(int *)((v) + (68))) = r | TVF_Lookup_Depth_Amount(0x8d);
    } else {
        r = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
        r = TVF_Calc_Cutoff(v, r, (char)z[55], (char)z[60]);
        x = ((unsigned int)z[78] << 13) | ((unsigned int)z[78] << 10);
        (*(int *)((v) + (66))) = r | x;
        (*(int *)((v) + (68))) = r;
        ram_2940 = 0;
    }
}
