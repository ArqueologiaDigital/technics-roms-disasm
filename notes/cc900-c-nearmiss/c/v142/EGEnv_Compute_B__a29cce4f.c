/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_G_15a.c (2026-11-16-106-sub-r15)
   sha256 a29cce4fc4ae4d201acc766f6ba318eef4cde2b23e038f95a0f4fd0bf404b6f5 (name+funcs); compiled at -Xr */
extern unsigned int EGEnv_BaseCurve_B[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned char ram_44257[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    unsigned int w;
    u = ram_44257 + (int)n * 27;
    p = u;
    w = EGEnv_BaseCurve_B[u[1]];
    x = w;
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}
