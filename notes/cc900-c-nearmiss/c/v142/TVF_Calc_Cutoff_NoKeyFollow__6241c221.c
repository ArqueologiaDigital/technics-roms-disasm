/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_H_14c.c (2026-11-16-101-sub-r14)
   sha256 6241c22152c9e442038de0e7e597e2e4f496a9449560f5f520c5051b26962272 (name+funcs); compiled at -Xr */
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern char TVF_KeyFollow_Curves[][128];
int TVF_Clamp_Cutoff(int a);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    unsigned char *t;
    char s;
    int d, k;
    t = P(v, 23);
    s = t[16];
    d = s;
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        c += d >> 5;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
