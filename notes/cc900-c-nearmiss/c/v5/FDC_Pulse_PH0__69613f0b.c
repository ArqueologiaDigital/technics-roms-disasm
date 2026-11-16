/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/fdc_routines_m270.c (2026-11-16-111-p6-r22-staged)
   sha256 69613f0b2db748c7da0fc9ccb8d8d008644c92e79ba43ac26bc7f1b8d1cb6427 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __tiny PH;
extern void FDC_NOP_Delay(int);
void FDC_Pulse_PH0(void)
{
    PH |= 1;
    FDC_NOP_Delay(10);
    PH &= ~1;
}
