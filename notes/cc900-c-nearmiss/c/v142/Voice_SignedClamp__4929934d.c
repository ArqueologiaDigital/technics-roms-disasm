/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -Xr */
void Voice_SignedClamp(unsigned char *p, char d, int hi, int lo)
{
    int v;
    v = d + *p;
    if (v > hi) v = hi;
    if (v < lo) v = lo;
    *p = v;
}
