/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_25c.c (2026-11-19-27-sub-r25a)
   sha256 c82f294e838831d356d7ad2a87718f665ce0326efd3feb51a432241e8cf98f6b (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned char ram_44260[];
extern unsigned int ram_45204;
extern unsigned int ram_4520e;
extern unsigned int EGEnv_ModeBits_Table[];
extern unsigned int Voice_FreqWrite_BaseCurve[];
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
        ram_45204 = (unsigned int)x | (int)EGEnv_ModeBits_Table[p[0] & 3];
    } else {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        ram_4520e = (unsigned int)x | (int)EGEnv_ModeBits_Table[p[0] & 3];
    }
}
