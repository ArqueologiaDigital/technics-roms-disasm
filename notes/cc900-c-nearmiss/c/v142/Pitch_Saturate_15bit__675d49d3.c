/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_2c.c (2026-11-16-47-sub-r2)
   sha256 675d49d3eeeea79e327148ffdc5c5179606a08452f10204af09a37e964ae4c72 (name+funcs); compiled at -Xr */
unsigned int Pitch_Saturate_15bit(unsigned int a)
{
    if ((a & 0x8000) != 0) {
        if (a > 0xc000) a = 0;
        else a = 0x7fff;
    }
    return a;
}
