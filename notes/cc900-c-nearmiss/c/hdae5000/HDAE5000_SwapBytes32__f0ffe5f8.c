/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r1b.c (2026-11-16-44-hd-r1)
   sha256 f0ffe5f8f88030190806f17337dda0ecbdcfedf242b4b2ef171faac50dbb205b (tar-sha256); compiled at -O3 -Xr */
unsigned long HDAE5000_SwapBytes32(unsigned long x)
{
    unsigned long r;
    int i;
    r = x & 0xff;
    for (i = 0; i < 3; i++) {
        x >>= 8;
        r = (r << 8) + (x & 0xff);
    }
    return r;
}
