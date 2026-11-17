/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_8c.c (2026-11-16-82-sub-r8)
   sha256 8425d89435501285c5621aa4eb0c72cc6c86af1f723686ae88429516fe20ee43 (name+funcs); compiled at -Xr */
extern unsigned int ram_45206;
extern unsigned int ram_4520a;
extern unsigned int EGEnv_ValueCurve_Simple[];
extern unsigned char ram_44260[];
void Voice_Freq_WriteRight(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = (unsigned char *)(ram_44260 + (int)n * 27);
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    if (n < 0x40) {
        if (r > 0x3fff) r = 0x3fff;
        if (p[0] & 0x20) ram_45206 = (unsigned int)r | 0x8000;
        else ram_45206 = r;
    } else {
        if (r > 0x3fff) r = 0x3fff;
        ram_4520a = r;
    }
}
