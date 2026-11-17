/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_U_18c.c (2026-11-17-7-sub-r18)
   sha256 6ca4f2a638402ffcdcd5926c1261daf0d719a4be06e9987d078f0b31724cd5cc (name+funcs); compiled at -Xr */
extern unsigned int ram_45204;
extern unsigned int ram_4520e;
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned int Voice_FreqWrite_BaseCurve[];
extern unsigned char ram_44260[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
void Voice_Freq_WriteLeft(unsigned char n)
{
    unsigned int w;
    unsigned char *p;
    unsigned long x;
    p = (unsigned char *)(void *)(ram_44260 + (int)n * 27);
    if (n < 0x40) {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        w = EGEnv_ModeBits_Table[p[0] & 3];
        ram_45204 = w | (unsigned int)x;
    } else {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        w = EGEnv_ModeBits_Table[p[0] & 3];
        ram_4520e = w | (unsigned int)x;
    }
}
