/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_26b.c (2026-11-19-30-sub-r26a)
   sha256 2c960b3b7a99d21cae6bbe4ac153250ef4c5be0fb08f4dcf9d7de9d4b461d005 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_44260[];
extern unsigned int ram_45204;
extern unsigned int ram_4520e;
extern int EGEnv_ModeBits_Table[];
extern unsigned int Voice_FreqWrite_BaseCurve[];
unsigned long EnvDepth_Cap(unsigned long a, int c, int e);
void Voice_Freq_WriteLeft(unsigned char n)
{
    unsigned int w;
    unsigned char *p;
    unsigned long x;
    unsigned int r;
    p = (unsigned char *)(void *)(ram_44260 + (int)n * 27);
    if (n < 0x40) {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        r = EGEnv_ModeBits_Table[p[0] & 3] | (unsigned int)x;
        ram_45204 = r;
    } else {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        r = EGEnv_ModeBits_Table[p[0] & 3] | (unsigned int)x;
        ram_4520e = r;
    }
}
