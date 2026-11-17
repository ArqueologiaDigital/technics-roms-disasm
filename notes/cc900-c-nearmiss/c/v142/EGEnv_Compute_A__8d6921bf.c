/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_M_16c.c (2026-11-16-112-sub-r16)
   sha256 8d6921bf12905372c8523e335435fae8806bf900d037571180f04bd2c3cc2168 (name+funcs); compiled at -Xr */
extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned char ram_4424e[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
unsigned int EGEnv_Compute_A(unsigned char n)
{
    unsigned int w;
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = ram_4424e + (int)n * 27;
    p = u;
    w = EGEnv_BaseCurve_A[u[1]];
    x = w;
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return EGEnv_ModeBits_Table[p[0] & 3] | (unsigned int)x;
}
