/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_ia09.c (2026-11-16-99-sub-r13-idioms)
   sha256 01997cd5c0e01724acc78d395b875efdbccbf2d7de541c4b1cc34435377421c4 (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void Voice_PitchPack_RouteB(unsigned char *v)
{
    unsigned long t;
    int r;
    unsigned int x;
    t = *(unsigned long *)(v + 23);
    r = TVF_Calc_Cutoff_NoKeyFollow(v, ((unsigned char *)t)[17]);
    x = ((unsigned int)((unsigned char *)t)[18] << 13) | 0x400;
    SW(v, 66) = (r | x) | 0x80;
    r = TVF_Bias_Clamp_Amount(((unsigned char *)t)[19]);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(((unsigned char *)t)[20]);
}
