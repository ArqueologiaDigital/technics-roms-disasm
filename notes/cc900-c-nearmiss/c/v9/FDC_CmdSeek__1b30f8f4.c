/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/fdc_routines_m270_xr.c (2026-11-16-103-p6-r20-staged)
   sha256 1b30f8f4b9890e39ac38dc1256ee9d929186110e5939b9625b84858feee42a25 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -Xr */
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
