/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v142/voice_params_and_tvf_runtime.c (2026-11-16-80-sub-staged2)
   sha256 6befbaa6094214fe1d794fd220aca940c081b955f0ba47c0f252f914fa1a454b (name+funcs); compiled at -Xr
   cc900-options: -Xr */
unsigned long EnvDepth_Cap(unsigned long a, unsigned char c, unsigned char e)
{
    unsigned long t, r;
    t = (unsigned long)e * (0x7fUL - c);
    r = (t * a) >> 12;
    if (r > a) r = a;
    return r;
}
