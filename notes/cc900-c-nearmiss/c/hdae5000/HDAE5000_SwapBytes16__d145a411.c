/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_lyrics.c (2026-11-16-78-hd-r15-ports)
   sha256 d145a4110744569645fe5fa90b81074d74009d813cb945de0f2b13be7d48739e (tar-sha256); compiled at -Xr
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
