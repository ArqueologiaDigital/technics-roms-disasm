/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_ia15.c (2026-11-16-99-sub-r13-idioms)
   sha256 0550ba37bd10d9e3d5df018afd19d890d39b3f55d5f88cc1abeb9ad7f6c1d8cc (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void TVF_Build_Short(unsigned char *v)
{
    unsigned char *t;
    int r;
    unsigned int x;
    t = ((unsigned char **)(v + 23))[0];
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    x = ((unsigned int)t[18] << 13) | 0x400;
    SW(v, 66) = r | x;
    r = TVF_Bias_Clamp_Amount(t[19]);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t[20]);
}
