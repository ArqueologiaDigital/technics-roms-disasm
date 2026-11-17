/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdc_routines_m270.c (2026-11-16-92-p6-r18)
   sha256 e7b61cfe085ecbfe64bddce8f52c83be4863a8c1fd90498ff2d82dc431f5f0d1 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
unsigned char FDC_Read_Status()
{
    return *(unsigned char *)0x110008;
}
