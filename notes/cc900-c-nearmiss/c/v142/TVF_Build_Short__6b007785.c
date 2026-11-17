/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_ia01.c (2026-11-16-99-sub-r13-idioms)
   sha256 6b0077851e1f67b7bd7322e5388a835ffc175aaa486169943d6dfb62c1d15dbc (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void TVF_Build_Short(unsigned char *v)
{
    unsigned char *t;
    int r;
    unsigned int x;
    t = P(v, 23);
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    x = ((unsigned int)t[18] << 13) | 0x400;
    SW(v, 66) = r | x;
    r = TVF_Bias_Clamp_Amount(t[19]);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t[20]);
}
