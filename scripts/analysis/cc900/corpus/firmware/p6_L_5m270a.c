/* Phase 6, lane_p6 helper L, round 5, form a: module 270 (storage/fdc_routines.s), new.
   - FDC_CmdRecalibrate: seek to track 5 from an unknown cylinder, recalibrate (command 7), mark the cylinder
     unknown on error, restore the target track (kept in QIZ's low byte: the ROM saves only QIZ, as V4.23 does for
     a byte local across calls), then a 16-unit delay.  Prototypes as the matched fdc_routines C has them. */
/* cc900-module: FDC_CMD_SEND FDC_CmdSeek FDC_POST_OP FDC_TIMING_DELAY SOME_DELAY */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near FDC_TARGET_TRACK;
extern unsigned char __near FDC_CURRENT_CYLINDER;
extern unsigned char __near FDC_ERROR_CODE;
extern void FDC_CmdSeek(void);
extern void FDC_TIMING_DELAY(void);
extern void FDC_CMD_SEND(int);
extern void FDC_POST_OP(void);
extern void SOME_DELAY(int);
extern void FDC_CmdRecalibrate(void);

void FDC_CmdRecalibrate(void)
{
	unsigned char t;

	t = FDC_TARGET_TRACK;
	FDC_TARGET_TRACK = 5;
	FDC_CURRENT_CYLINDER = 255;
	FDC_CmdSeek();
	FDC_CURRENT_CYLINDER = 0;
	FDC_TIMING_DELAY();
	FDC_CMD_SEND(7);
	FDC_POST_OP();
	if (FDC_ERROR_CODE != 0)
		FDC_CURRENT_CYLINDER = 255;
	FDC_TARGET_TRACK = t;
	SOME_DELAY(16);
}
