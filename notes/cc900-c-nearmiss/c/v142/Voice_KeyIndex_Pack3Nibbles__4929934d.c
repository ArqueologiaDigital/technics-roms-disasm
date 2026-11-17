/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -O3 -Xr */
unsigned int Voice_KeyIndex_Pack3Nibbles(unsigned int a)
{
    unsigned int r;
    r = ((a >> 8) & 0xf) * 81;
    r += ((a >> 4) & 0xf) * 9;
    r += a & 0xf;
    return r;
}
