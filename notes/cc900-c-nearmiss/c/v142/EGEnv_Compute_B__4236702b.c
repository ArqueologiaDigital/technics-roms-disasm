/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17a.c (2026-11-16-126-sub-r17)
   sha256 4236702b3d6d2cd4a34bd2c4b4787b866c2680f5404a1df78ec1c7768ec2066d (name+funcs); compiled at -Xr */
extern unsigned int EGEnv_BaseCurve_B[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned char ram_44257[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned int w;
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = ram_44257 + (int)n * 27;
    p = u;
    w = EGEnv_BaseCurve_B[u[1]];
    x = w;
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    w = EGEnv_ModeBits_Table[p[0] & 3];
    return (unsigned int)x | w;
}
