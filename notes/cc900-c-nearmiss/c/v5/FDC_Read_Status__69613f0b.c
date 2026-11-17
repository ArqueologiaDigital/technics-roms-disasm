/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/fdc_routines_m270.c (2026-11-16-111-p6-r22-staged)
   sha256 69613f0b2db748c7da0fc9ccb8d8d008644c92e79ba43ac26bc7f1b8d1cb6427 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
unsigned char FDC_Read_Status()
{
    return *(unsigned char *)0x110008;
}
