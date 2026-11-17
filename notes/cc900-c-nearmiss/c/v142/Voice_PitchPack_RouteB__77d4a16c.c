/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_ia07.c (2026-11-16-99-sub-r13-idioms)
   sha256 77d4a16c73e7d87409668d95549bb37c5e329256c123775b51a9f5944f1011d7 (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void Voice_PitchPack_RouteB(unsigned char *v)
{
    unsigned char *t;
    unsigned char *u;
    int r;
    unsigned int x;
    r = TVF_Calc_Cutoff_NoKeyFollow(v, (u = t = P(v, 23))[17]);
    x = ((unsigned int)t[18] << 13) | 0x400;
    SW(v, 66) = (r | x) | 0x80;
    r = TVF_Bias_Clamp_Amount(t[19]);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t[20]);
}
