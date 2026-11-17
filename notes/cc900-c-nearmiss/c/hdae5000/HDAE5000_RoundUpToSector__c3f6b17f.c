/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_song_module.c (2026-11-16-78-hd-r15-ports)
   sha256 c3f6b17f90dbdd41277568988ab74017678d645718e2e69c1cc70f2d8514d97e (tar-sha256); compiled at -Xr
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
