/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -Xr */
unsigned int Pitch_Saturate_15bit(unsigned int a)
{
    if ((int)a < 0) {
        if (a > 0xc000) a = 0;
        else a = 0x7fff;
    }
    return a;
}
