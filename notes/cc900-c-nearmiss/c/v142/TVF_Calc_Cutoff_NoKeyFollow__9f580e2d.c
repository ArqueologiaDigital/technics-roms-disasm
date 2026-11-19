/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w5a.c (2026-11-19-10-sub-r23w-asm)
   sha256 9f580e2d240854361aca295c79708c26ded3536f461a92b7ed539fefcce12719 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern char TVF_KeyFollow_Curves[][128];
int TVF_Clamp_Cutoff(int a);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    unsigned char *t;
    int d;
    t = (*(unsigned char **)((v) + (23)));
    d = (char)t[16];
    if (d != 0) {
        d = d * TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d >>= 5;
        c += d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
