/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_H_15b.c (2026-11-16-106-sub-r15)
   sha256 66164b1cba1f65710cc1f15e377a49a501d9d6208ea26ea566d807fd9a7b9891 (name+funcs); compiled at -Xr */
extern char TVF_KeyFollow_Curves[][128];
int TVF_Clamp_Cutoff(int a);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    unsigned char *t;
    unsigned char s;
    int d, k;
    t = (*(unsigned char **)((v) + (23)));
    s = t[16];
    d = (char)s;
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        d >>= 5;
        c += (unsigned int)d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
