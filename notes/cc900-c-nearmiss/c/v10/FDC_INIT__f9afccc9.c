/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_13m270.c (2026-11-16-100-p6-r19)
   sha256 f9afccc92d4f380fc868b037e9ce1ad6786885a26813d1cbe861cf083138ef4a (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near FDC_CURRENT_CYLINDER;
extern void FDC_Send_Command(int);
extern void SOME_DELAY(int);
void FDC_INIT(void)
{
    FDC_Send_Command(54);
    SOME_DELAY(2);
    FDC_CURRENT_CYLINDER = 255;
}
