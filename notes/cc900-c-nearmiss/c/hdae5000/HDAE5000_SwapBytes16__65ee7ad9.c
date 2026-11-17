/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_lyrics.c (2026-11-16-63-hd-r9s-staged)
   sha256 65ee7ad9fda77da488ee5d76396483b3b62bb35b8fe47710a93540aa2ce8888b (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
unsigned int HDAE5000_SwapBytes16(unsigned int x)
{
    unsigned int r;
    r = x & 0xff;
    x >>= 8;
    r <<= 8;
    r += x;
    return r;
}
