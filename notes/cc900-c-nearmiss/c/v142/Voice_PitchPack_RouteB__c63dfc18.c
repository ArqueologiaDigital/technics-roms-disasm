/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_ia14.c (2026-11-16-99-sub-r13-idioms)
   sha256 c63dfc18ab46a25afdc6513a6dd82d2ba14553e851ae1b7a30d8aa37949525a6 (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void Voice_PitchPack_RouteB(unsigned char *v)
{
    int r;
    unsigned char *t;
    unsigned int x;
    t = P(v, 23);
    r = TVF_Calc_Cutoff_NoKeyFollow(v, t[17]);
    x = ((unsigned int)t[18] << 13) | 0x400;
    SW(v, 66) = (r | x) | 0x80;
    r = TVF_Bias_Clamp_Amount(t[19]);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t[20]);
}
