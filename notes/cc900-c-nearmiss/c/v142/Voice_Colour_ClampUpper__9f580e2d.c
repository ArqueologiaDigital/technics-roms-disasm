/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_lane_23w5a.c (2026-11-19-10-sub-r23w-asm)
   sha256 9f580e2d240854361aca295c79708c26ded3536f461a92b7ed539fefcce12719 (name+funcs); compiled at -Xr
   cc900-options: -Xr */
int Voice_Colour_ClampUpper(unsigned int a, unsigned char b, unsigned char lo, unsigned char hi, char s)
{
    int d, r;
    a = (a & 0x7f00) >> 8;
    if (a > hi) a = hi;
    else if (a < lo) a = lo;
    d = a - (int)b;
    r = s;
    r = (r * d) >> 5;
    return r;
}
