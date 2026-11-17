/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7c.c (2026-11-16-79-sub-r7)
   sha256 00220d49c918c71ccd87f5bf36078c78c47fac4fecc2bbf39af41da8ff8ad5f9 (name+funcs); compiled at -Xr */
extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned char ram_4424e[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
unsigned int EGEnv_Compute_A(unsigned char n)
{
    unsigned char *p;
    unsigned long x;
    p = ram_4424e + (int)n * 27;
    x = EGEnv_BaseCurve_A[p[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}
