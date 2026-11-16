/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7a.c (2026-11-16-79-sub-r7)
   sha256 f70607b5111b1b73ae470351c728e34d55ce40ce7a9d878e58e34960dca5e443 (name+funcs); compiled at -Xr */
extern unsigned int EGEnv_ValueCurve_Simple[];
extern unsigned char ram_44257[];
unsigned long EGEnv_Compute_B_Simple(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = (unsigned char *)((long)((int)n * 27) + (long)ram_44257);
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    if (r > 0x3fff) r = 0x3fff;
    return r;
}
