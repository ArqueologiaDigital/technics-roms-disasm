/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/fdc_routines_m270.c (2026-11-16-92-p6-r18)
   sha256 0fd4b0dac24246ed57f413535f8e590ac3f4bd053270723b7c7796472c5afb54 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
unsigned char FDC_Read_Status()
{
    return *(unsigned char *)0x110008;
}
