/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hdae5000_ui_display.c (2026-11-16-63-hd-r9s-staged)
   sha256 2610f2d47235e6bafa77af76c8ae213654c07fa497cb63b72f0218c0808b5785 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
unsigned long HDAE5000_Smf_SwapBytes32(unsigned long x)
{
    unsigned long t, r;
    t = x;
    r = t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    t >>= 8; r <<= 8; r += t & 0xff;
    return r;
}
