/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_P_17c.c (2026-11-16-126-sub-r17)
   sha256 bd67878aa1a0f366ab5645d3437f1f797cce2b2e9dbc7116c6bff2282d78e494 (name+funcs); compiled at -Xr */
extern unsigned int ram_45204;
extern unsigned int ram_4520e;
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned int Voice_FreqWrite_BaseCurve[];
extern unsigned char ram_44260[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
void Voice_Freq_WriteLeft(unsigned char n)
{
    unsigned char *p;
    unsigned long x;
    p = (unsigned char *)(void *)(ram_44260 + (int)n * 27);
    if (n < 0x40) {
        x = Voice_FreqWrite_BaseCurve[p[1]];
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        ram_45204 = (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
    } else {
        x = Voice_FreqWrite_BaseCurve[p[1]];
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        ram_4520e = (unsigned int)x | EGEnv_ModeBits_Table[p[0] & 3];
    }
}
