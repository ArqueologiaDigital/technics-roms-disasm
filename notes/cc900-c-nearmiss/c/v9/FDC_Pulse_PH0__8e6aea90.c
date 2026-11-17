/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/fdc_routines_m270.c (2026-11-16-111-p6-r22-staged)
   sha256 8e6aea90aa223b87eea87a877e5958efd9f7c4b98272e22f8a7010a7a6315fa2 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __tiny PH;
extern void FDC_NOP_Delay(int);
void FDC_Pulse_PH0(void)
{
    PH |= 1;
    FDC_NOP_Delay(10);
    PH &= ~1;
}
