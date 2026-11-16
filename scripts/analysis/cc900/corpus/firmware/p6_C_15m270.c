/* Phase 6, lane_p6 helper C, round 15, module 270 (modules_v10.tsv) of v10 storage/fdc_routines.s: FDC_CmdSeek.  The
   target track is copied into the current cylinder with ldmm8 (both __near); the module routines are called by calr
   and the last one is a jump.  FDC_CMD_SEND takes a byte the caller zero-extends: an int prototype. */
/* cc900-module: SOME_DELAY FDC_TIMING_DELAY FDC_CMD_SEND FDC_POST_OP */

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
