/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/v140/voice_params_and_tvf_runtime.c (2026-11-16-80-sub-staged2)
   sha256 6befbaa6094214fe1d794fd220aca940c081b955f0ba47c0f252f914fa1a454b (name+funcs); compiled at -Xr
   cc900-options: -Xr */
extern unsigned long __near ram_1040;
extern int ram_41366;
void Voice_Vol_ScaleVelocityWord(void)
{
    unsigned long t;
    t = ram_1040;
    ram_41366 = (int)(char)((t * t >> 2) & 0xff) * 13 >> 7;
}
