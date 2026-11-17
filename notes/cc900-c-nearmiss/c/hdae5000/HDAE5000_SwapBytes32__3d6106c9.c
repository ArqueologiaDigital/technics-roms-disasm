/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r1a.c (2026-11-16-44-hd-r1)
   sha256 3d6106c93617b98bcac5898cac04887249bee17a21630bc45a65c43a896e7307 (tar-sha256); compiled at -O3 -Xr */
unsigned long HDAE5000_SwapBytes32(unsigned long x)
{
    unsigned long r = x & 0xff;
    int i;
    for (i = 0; i < 3; i++) {
        x >>= 8;
        r <<= 8;
        r += x & 0xff;
    }
    return r;
}
