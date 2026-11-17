/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_9c.c (2026-11-16-86-sub-r9)
   sha256 78ecbab13a5dc7797897ffde8967cd943b6b5f2f2195ecc3768976b9be2e7cb2 (name+funcs); compiled at -Xr */
extern unsigned int EGEnv_BaseCurve_B[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned char ram_44257[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned char *p;
    unsigned long x;
    p = ram_44257 + (int)n * 27;
    x = EGEnv_BaseCurve_B[p[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}
