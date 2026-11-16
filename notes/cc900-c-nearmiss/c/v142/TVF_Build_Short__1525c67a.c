/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_ia12.c (2026-11-16-99-sub-r13-idioms)
   sha256 1525c67a940c1df2f125c02e2475684b3a8a2bc714c17558e96af32141fe25e7 (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void TVF_Build_Short(unsigned char *v)
{
    unsigned char *w;
    unsigned char *t;
    int r;
    unsigned int x;
    w = v;
    t = P(w, 23);
    r = TVF_Calc_Cutoff_NoKeyFollow(w, t[17]);
    x = ((unsigned int)t[18] << 13) | 0x400;
    SW(v, 66) = r | x;
    r = TVF_Bias_Clamp_Amount(t[19]);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t[20]);
}
