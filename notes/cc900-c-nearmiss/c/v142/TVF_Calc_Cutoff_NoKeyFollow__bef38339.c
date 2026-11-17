/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7b.c (2026-11-16-79-sub-r7)
   sha256 bef3833963878e0910cfc435c5744015fa3834273d8d4314fee65c98fc8c4c31 (name+funcs); compiled at -Xr */
#define P(p, o) (*(unsigned char **)((p) + (o)))
extern char TVF_KeyFollow_Curves[][128];
int TVF_Clamp_Cutoff(int a);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    int k, d;
    unsigned char *t;
    t = P(v, 23);
    d = (char)t[16];
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        d >>= 5;
        c = c + d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
