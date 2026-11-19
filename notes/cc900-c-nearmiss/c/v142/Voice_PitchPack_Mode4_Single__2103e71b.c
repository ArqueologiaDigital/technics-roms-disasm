/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AR_39a.c (2026-11-19-84-sub-r39r)
   sha256 2103e71b9b99cb10996fb18388a6d3195fa891b82022ede544f65b9919caffea (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern int __near ram_2940;
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s);
void Voice_PitchPack_Mode4_Single(unsigned char *v)
{
    unsigned char *z;
    int c;
    unsigned int x;
    z = (*(unsigned char **)((v) + (23)));
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (35)))) + (2))) & 0x200) c = z[77];
    else c = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
    c = TVF_Calc_Cutoff(v, c, (char)z[55], (char)z[60]);
    x = ((unsigned int)z[78] << 13) | ((unsigned int)z[78] << 10);
    (*(int *)((v) + (66))) = (c | x) | 0x80;
    (*(int *)((v) + (68))) = c | 0x80;
    ram_2940 = 0;
}
