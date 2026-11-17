/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/fdc_routines_m270_xr.c (2026-11-16-111-p6-r22-staged)
   sha256 a035e841d7293846b48f030e11358e6f4ccc7537fd96ee1103796cf870c21472 (tar-sha256); compiled at -O3 -Xr
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
