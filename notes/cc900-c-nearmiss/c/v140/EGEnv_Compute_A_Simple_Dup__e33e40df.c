/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_params_and_tvf_b_runtime.c (2026-11-16-80-sub-staged2)
   sha256 e33e40df5164498b0af61e3d0127701726543262fad890abb1b8b4d495821065 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned int EGEnv_ValueCurve_Simple[];
extern unsigned char ram_4424e[];
unsigned long EGEnv_Compute_A_Simple_Dup(unsigned char n)
{
    unsigned char *p;
    unsigned long r;
    p = &ram_4424e[(int)n * 27];
    r = EGEnv_ValueCurve_Simple[p[3]];
    r *= p[4];
    r >>= 7;
    if (r > 0x3fff) r = 0x3fff;
    return r;
}
