/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_C_15m270.c (2026-11-16-100-p6-r19)
   sha256 56a7606b9fb1d5c27a71cafe61d8ec8abc43587fac0dcc311ba7137788e9743b (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near FDC_TARGET_TRACK;
extern unsigned char __near FDC_CURRENT_CYLINDER;
extern unsigned char __near FDC_ERROR_CODE;
extern void SOME_DELAY(int);
extern void FDC_TIMING_DELAY(void);
extern void FDC_CMD_SEND(int);
extern void FDC_POST_OP(void);
void FDC_CmdSeek(void)
{
    if (FDC_TARGET_TRACK == FDC_CURRENT_CYLINDER) return;
    FDC_CURRENT_CYLINDER = FDC_TARGET_TRACK;
    SOME_DELAY(2);
    FDC_TIMING_DELAY();
    FDC_CMD_SEND(15);
    FDC_POST_OP();
    if (FDC_ERROR_CODE != 0) FDC_CURRENT_CYLINDER = 255;
    SOME_DELAY(16);
}
