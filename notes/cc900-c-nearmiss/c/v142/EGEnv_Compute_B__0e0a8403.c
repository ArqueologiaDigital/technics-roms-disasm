/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17b.c (2026-11-16-126-sub-r17)
   sha256 0e0a840326316c81afba23a05abfb073bad3f8133f4552d566393030e1a46134 (name+funcs); compiled at -Xr */
extern unsigned int EGEnv_BaseCurve_B[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned char ram_44257[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
unsigned int EGEnv_Compute_B(unsigned char n)
{
    unsigned int w;
    unsigned int r;
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
    r = (unsigned int)x;
    return r | w;
}
