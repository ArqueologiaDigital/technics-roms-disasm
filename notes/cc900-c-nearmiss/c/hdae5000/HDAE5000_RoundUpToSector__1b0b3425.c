/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hd/hd_r27_b_song.c (2026-11-16-119-hd-r30)
   sha256 1b0b3425565dbcd8f801136a0c450ece38c98939f682467189952383017fc424 (tar-sha256); compiled at -Xr
   cc900-options: -Xr */
typedef struct { long quot; long rem; } ldiv_t;
extern ldiv_t __cdecl HDAE5000_LDiv(long, long);
unsigned long HDAE5000_RoundUpToSector(unsigned long n)
{
    unsigned long ret;
    ldiv_t r;

    ret = n;
    if (n != 0) {
        r = HDAE5000_LDiv(n, 512);
        if (r.rem != 0)
            ret = (r.quot << 9) + 0x200;
    } else
        ret = 0x200;
    return ret;
}
