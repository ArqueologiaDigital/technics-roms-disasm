/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_13m270.c (2026-11-16-100-p6-r19)
   sha256 f9afccc92d4f380fc868b037e9ce1ad6786885a26813d1cbe861cf083138ef4a (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __tiny PH;
extern void FDC_NOP_Delay(int);
void FDC_Pulse_PH0(void)
{
    PH |= 1;
    FDC_NOP_Delay(10);
    PH &= ~1;
}
