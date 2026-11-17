/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_H_14b.c (2026-11-16-101-sub-r14)
   sha256 bbeccd0d4360f3ac4a49496bd3e48bc2c26a024abdf4b72a929927d46ea7b73b (name+funcs); compiled at -Xr */
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern char TVF_KeyFollow_Curves[][128];
int TVF_Clamp_Cutoff(int a);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    unsigned char *t = P(v, 23);
    int d = (char)t[16];
    int k;
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        c += d >> 5;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
