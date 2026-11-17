/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of sub/sub_A_4c.c (2026-11-16-62-sub-r4)
   sha256 5fa07bbc698c05cdf1499ef39438f01891abf5d3f8e20a0d5e7cd774bd8f0d32 (name+funcs); compiled at -Xr */
int Pan_ScaleWithVelocity(unsigned int a, unsigned char b, unsigned char lo, unsigned char hi, char s)
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
