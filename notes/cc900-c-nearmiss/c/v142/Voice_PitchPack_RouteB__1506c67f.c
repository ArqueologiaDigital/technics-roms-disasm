/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_ia02.c (2026-11-16-99-sub-r13-idioms)
   sha256 1506c67fc02d1a21f6dc387f81d095a2c44eef3f3b100dc83ba3dcb9a6ff8d25 (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void Voice_PitchPack_RouteB(unsigned char *v)
{
    unsigned char *t;
    int r;
    unsigned int x;
    r = TVF_Calc_Cutoff_NoKeyFollow(v, (t = P(v, 23))[17]);
    x = ((unsigned int)t[18] << 13) | 0x400;
    SW(v, 66) = (r | x) | 0x80;
    r = TVF_Bias_Clamp_Amount(t[19]);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t[20]);
}
