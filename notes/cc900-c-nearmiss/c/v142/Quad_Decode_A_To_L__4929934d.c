/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2b.c (2026-11-16-47-sub-r2)
   sha256 4929934d1be3b922f61146a30935689ade1baf0354878540871355a4884bb871 (name+funcs); compiled at -Xr */
unsigned char Quad_Decode_A_To_L(unsigned char a)
{
    if (a < 0x40) return 0;
    else if (a < 0x80) return 4;
    else if (a < 0xc0) return 8;
    else return 0;
}
