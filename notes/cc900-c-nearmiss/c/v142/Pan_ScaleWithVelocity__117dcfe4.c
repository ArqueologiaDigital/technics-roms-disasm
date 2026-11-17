/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3a.c (2026-11-16-58-sub-r3)
   sha256 117dcfe4c69ab73765948417bed771add93ad5e8a4aacafd170500b351b44157 (name+funcs); compiled at -Xr */
int Pan_ScaleWithVelocity(unsigned int a, unsigned char b, unsigned char lo, unsigned char hi, char s)
{
    int d;
    a = (a & 0x7f00) >> 8;
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    d = a - b;
    return (s * d) >> 5;
}
