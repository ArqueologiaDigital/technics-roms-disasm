/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -Xr */
extern unsigned char Detune_Scale_Curve[];
int Detune_ScaleSymmetric(int a)
{
    if (a < 0) {
        a = -a;
        if (a > 0x32) a = 0x32;
        a = -Detune_Scale_Curve[(unsigned char)a];
    } else {
        if (a > 0x32) a = 0x32;
        a = Detune_Scale_Curve[(unsigned char)a];
    }
    return a;
}
