/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_G_14c.c (2026-11-16-101-sub-r14)
   sha256 7513361ba689dc3fd87f7569732a903910d41a1bab9139af3408c3758782af98 (name+funcs); compiled at -Xr */
extern unsigned int EGEnv_BaseCurve_A[];
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned char ram_4424e[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
unsigned int EGEnv_Compute_A(unsigned char n)
{
    unsigned char *p;
    unsigned char *u;
    unsigned long x;
    u = &ram_4424e[(int)n * 27];
    p = u;
    x = EGEnv_BaseCurve_A[u[1]];
    x *= p[2];
    if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
    x >>= 7;
    if (x > 0x1fff) x = 0x1fff;
    return (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
}
