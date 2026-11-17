/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v2_01i/hdae5000_lyrics.c (2026-11-16-78-hd-r15-ports)
   sha256 d145a4110744569645fe5fa90b81074d74009d813cb945de0f2b13be7d48739e (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
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
