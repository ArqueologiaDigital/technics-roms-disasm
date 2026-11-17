/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_8b.c (2026-11-16-82-sub-r8)
   sha256 1cb8c0d97ee0913d1788071e80204ef95aa7b7d7498545a92c7b1647e6250df4 (name+funcs); compiled at -Xr */
extern char TVF_KeyFollow_Curves[][128];
int TVF_Clamp_Cutoff(int a);
int TVF_Calc_Cutoff_NoKeyFollow(unsigned char *v, int c)
{
    int d, k;
    unsigned char *t;
    t = (*(unsigned char **)((v) + (23)));
    d = (char)t[16];
    if (d != 0) {
        k = TVF_KeyFollow_Curves[(t[15] & 0xe0) >> 5][(unsigned int)v[12] & 0x7f];
        d *= k;
        d >>= 5;
        c += d;
    }
    return TVF_Clamp_Cutoff(c + 0x18);
}
