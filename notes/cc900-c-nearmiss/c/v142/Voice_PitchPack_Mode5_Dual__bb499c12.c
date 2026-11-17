/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_10a.c (2026-11-16-90-sub-r10)
   sha256 bb499c121aaefa01b0c094dc81af9c38404b55775ff87425d47cbe4ef107bd5d (name+funcs); compiled at -Xr */
extern int __near ram_2940;
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s);
void Voice_PitchPack_Mode5_Dual(unsigned char *v)
{
    unsigned char *z;
    int c1, c2;
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
    (*(int *)((v) + (66))) = (c1 | (((unsigned int)z[78] << 13) | ((unsigned int)z[80] << 10))) | 0x80;
    (*(int *)((v) + (68))) = c2;
    ram_2940 = 0;
}
