/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4b.c (2026-11-16-62-sub-r4)
   sha256 2930891c0f4cc37037eb6f8318034f85e7213280edee0124175fee577eb1783d (name+funcs); compiled at -Xr */
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern char TVF_KeyFollow_Curves[][128];
int TVF_Clamp_Cutoff(int a);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    unsigned char *t;
    int d;
    t = P(v, 23);
    d = (char)t[16];
    if (d != 0) {
        d = d * TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f] >> 5;
        c += d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
