/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_H_15a.c (2026-11-16-106-sub-r15)
   sha256 1535adaceec3da9c1c6a2afad1430e93d8efa45748ff808674eba91c3e5e9891 (name+funcs); compiled at -Xr */
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern char TVF_KeyFollow_Curves[][128];
int TVF_Clamp_Cutoff(int a);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, unsigned int c)
{
    unsigned char *t;
    unsigned char s;
    int d, k;
    t = P(v, 23);
    s = t[16];
    d = (char)s;
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        d >>= 5;
        c += d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
