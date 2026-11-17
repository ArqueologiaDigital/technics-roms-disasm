/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7c.c (2026-11-16-79-sub-r7)
   sha256 00220d49c918c71ccd87f5bf36078c78c47fac4fecc2bbf39af41da8ff8ad5f9 (name+funcs); compiled at -Xr */
extern char TVF_KeyFollow_Curves[][128];
int TVF_Clamp_Cutoff(int a);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    unsigned char *t;
    int d, k;
    t = (*(unsigned char **)((v) + (23)));
    d = (char)t[16];
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        d >>= 5;
        c += (int)d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
