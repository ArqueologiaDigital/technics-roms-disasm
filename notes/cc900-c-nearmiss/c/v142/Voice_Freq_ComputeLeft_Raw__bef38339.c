/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_7b.c (2026-11-16-79-sub-r7)
   sha256 bef3833963878e0910cfc435c5744015fa3834273d8d4314fee65c98fc8c4c31 (name+funcs); compiled at -Xr */
extern unsigned int EGEnv_ValueCurve_Simple[];
extern unsigned char ram_44257[];
unsigned long Voice_Freq_ComputeLeft_Raw(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = (unsigned char *)((int)n * 27 + (unsigned long)ram_44257);
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    return r;
}
