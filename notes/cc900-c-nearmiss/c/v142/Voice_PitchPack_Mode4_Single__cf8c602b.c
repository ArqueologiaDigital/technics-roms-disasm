/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AR_39c.c (2026-11-19-84-sub-r39r)
   sha256 cf8c602bb2df5e3eff8fa03751c28710bf6a9641a960129a0fdcf47d2d4a3209 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern int __near ram_2940;
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s);
void Voice_PitchPack_Mode4_Single(unsigned char *v)
{
    unsigned char *z;
    int c;
    z = (*(unsigned char **)((v) + (23)));
    if ((*(unsigned int *)(((*(unsigned char **)((v) + (35)))) + (2))) & 0x200) c = z[77];
    else c = (int)z[77] + (char)(*(unsigned char **)((v) + (35)))[103];
    c = TVF_Calc_Cutoff(v, c, (char)z[55], (char)z[60]);
    (*(int *)((v) + (66))) = (c | (((unsigned int)z[78] << 13) | ((unsigned int)z[78] << 10))) | 0x80;
    (*(int *)((v) + (68))) = c | 0x80;
    ram_2940 = 0;
}
