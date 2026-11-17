/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of hdae5000_v1_10i/hdae5000_song_module.c (2026-11-16-105-hd-r23b)
   sha256 f721493898ffe347f63ad95ec5c545423ef33b04332f244f5af5436afc2e1b69 (tar-sha256); compiled at -Xr
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
