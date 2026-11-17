/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_ia06.c (2026-11-16-99-sub-r13-idioms)
   sha256 eed09f0bf58d14b8170063de478292f97e7a67816df7ff9a73df87d50927ad3a (name+funcs); compiled at -O1 -Xr */
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c);
int TVF_Bias_Clamp_Amount(int a);
unsigned int TVF_Lookup_Depth_Amount(int a);
void TVF_Build_Short(unsigned char *v)
{
    unsigned char *t;
    unsigned char *u;
    int r;
    unsigned int x;
    u = (*(unsigned char **)((v) + (23)));
    t = u;
    r = TVF_Calc_Cutoff_NoKeyFollow(v, u[17]);
    x = ((unsigned int)t[18] << 13) | 0x400;
    (*(int *)((v) + (66))) = r | x;
    r = TVF_Bias_Clamp_Amount(t[19]);
    (*(int *)((v) + (68))) = r | TVF_Lookup_Depth_Amount(t[20]);
}
