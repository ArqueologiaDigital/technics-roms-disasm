/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18a.c (2026-11-17-7-sub-r18)
   sha256 28995d12564daee79c182a1ebc86ab804043dda38b11687ee466a817e53c36e2 (name+funcs); compiled at -Xr */
extern char TVF_KeyFollow_Curves[][128];
int TVF_Clamp_Cutoff(int a);
int TVF_Calc_Cutoff(unsigned char *v, int c, int d, char s)
{
    unsigned char *t;
    int k;
    unsigned int w;
    t = (*(unsigned char **)((v) + (23)));
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[54] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d = d * k >> 5;
        c += d;
    }
    if (s != 0) {
        w = ((*(unsigned int *)((v) + (8))) & 0x7f00) >> 8;
        if (w > t[59]) w = t[59];
        else if (w < t[58]) w = t[58];
        w -= t[57];
        c += (s * (int)w) >> 5;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
