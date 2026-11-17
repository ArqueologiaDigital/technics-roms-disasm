/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_ia08.c (2026-11-16-99-sub-r13-idioms)
   sha256 d9656089489e8bfc7233bcb348bb995ad07472b7671110f20ff04ddb7cca790c (name+funcs); compiled at -Xr */
#define SW(p, o) (*(int *)((p) + (o)))
#define P(p, o) (*(unsigned char **)((p) + (o)))
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void Voice_PitchPack_RouteB(unsigned char *v)
{
    unsigned char *t;
    int r;
    unsigned char c;
    unsigned int x;
    t = P(v, 23);
    c = t[17];
    r = TVF_Calc_Cutoff_NoKeyFollow(v, c);
    x = ((unsigned int)t[18] << 13) | 0x400;
    SW(v, 66) = (r | x) | 0x80;
    r = TVF_Bias_Clamp_Amount(t[19]);
    SW(v, 68) = r | TVF_Lookup_Depth_Amount(t[20]);
}
