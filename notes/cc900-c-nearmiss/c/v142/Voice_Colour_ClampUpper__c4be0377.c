/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_3c.c (2026-11-16-58-sub-r3)
   sha256 c4be0377121c92aaf4310ff02e0d53aa962b80a276e1426001d4bcb998399cbf (name+funcs); compiled at -Xr */
int Voice_Colour_ClampUpper(unsigned int a, unsigned char b, unsigned char lo, unsigned char hi, char s)
{
    a = (a & 0x7f00) >> 8;
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    return (s * (int)(a - b)) >> 5;
}
