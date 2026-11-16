/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fdc_routines_m270.c (2026-11-16-92-p6-r18)
   sha256 c58de265f0d133594d6ca57d2364319f9d0e10e12dbc63b94df4c823dd77c314 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
unsigned char FDC_Read_Status()
{
    return *(unsigned char *)0x110008;
}
