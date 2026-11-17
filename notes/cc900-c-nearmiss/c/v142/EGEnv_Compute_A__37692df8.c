/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_G_14b.c (2026-11-16-101-sub-r14)
   sha256 37692df8ad8f998647171a653260913df828d5f0d96faa01d18a8cedc8ac1de3 (name+funcs); compiled at -Xr */
extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned char ram_4424e[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
unsigned int EGEnv_Compute_A(unsigned char n)
{
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    p = u = ram_4424e + (int)n * 27;
    x = EGEnv_BaseCurve_A[u[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}
