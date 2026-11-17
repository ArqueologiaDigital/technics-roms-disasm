/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdc_routines_m270.c (2026-11-16-111-p6-r22-staged)
   sha256 46589296630a57618ebd046f165040df3f14e6a4d6df8b8e0dab4c3dcb08fc19 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __tiny PH;
extern void FDC_NOP_Delay(int);
void FDC_Pulse_PH0(void)
{
    PH |= 1;
    FDC_NOP_Delay(10);
    PH &= ~1;
}
