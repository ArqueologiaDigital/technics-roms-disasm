/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_AP_24c.c (2026-11-19-24-sub-r24a)
   sha256 829cafbbdd721e00cbc466a5b327ee805346b2c458fa6e89a23d3a1cc51fc5b2 (name+funcs); compiled at -Xr
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
        w = EGEnv_ModeBits_Table[p[0] & 3];
        w |= (unsigned int)x;
        ram_45204 = w;
    } else {
        w = Voice_FreqWrite_BaseCurve[p[1]];
        x = w;
        x *= p[2];
        if (p[5] != 0) x -= EnvDepth_Cap(x, p[6], p[5]);
        x >>= 7;
        if (x > 0x1fff) x = 0x1fff;
        w = EGEnv_ModeBits_Table[p[0] & 3];
        w |= (unsigned int)x;
        ram_4520e = w;
    }
}
