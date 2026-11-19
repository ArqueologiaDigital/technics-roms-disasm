/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/fdc_routines_m270_xr.c (2026-11-19-29-p6-r46)
   sha256 1f81a03588aae031d7e7cfbab2ead5599225158514d4c3ce2bcdf8c975881357 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
extern unsigned int __near SYSTEM_TIMESTAMP;
extern void FDC_Set_Status(int);
unsigned char FDC_Read_Status();
extern unsigned char FDC_Read_Status();
void FDC_WaitParamByteReady()
{
    unsigned int t, s;
    t = SYSTEM_TIMESTAMP;
    s = 128;
    if (s == 128) do {
        if ((FDC_Read_Status() & 0x90) == 0x90) s = 0;
        if (SYSTEM_TIMESTAMP - t > 500) s = 0xffff;
    } while (s == 128);
    if (s != 0) FDC_Set_Status(1);
}
