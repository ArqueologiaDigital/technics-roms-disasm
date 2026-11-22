/* lane_p6 helper J, round 27r1, form d: module 270 (storage/fdc_routines.s), the family FDC_SubmitReadDataCmd /
   FDC_SubmitWriteDataCmd (families27_J, 2 x 27 B): the command byte 0xc6 / 0xc5 to FDC_CMD_OPCODE, DMA setup, the
   settle delay, FDC_CMD_SEND, and unless FDC_ERROR_CODE is set a tail jump to FDC_POST_OP (`ret nz; jrl`), the
   shape of the built FDC_CmdRecalibrate.  (Forms a-c of this round's m270 hold Arrow_DrawHorizontal.)
   Form d: `if (FDC_ERROR_CODE != 0) return;` before the tail call.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDC_CMD_SEND FDC_POST_OP FDC_Setup_DMA_Mode FDC_TIMING_DELAY */

extern unsigned char __near FDC_CMD_OPCODE;
extern unsigned char __near FDC_ERROR_CODE;
extern void FDC_Setup_DMA_Mode(void);
extern void FDC_TIMING_DELAY(void);
extern void FDC_CMD_SEND(int);
extern void FDC_POST_OP(void);

void FDC_SubmitReadDataCmd(void)
{
	FDC_CMD_OPCODE = 0xc6;
	FDC_Setup_DMA_Mode();
	FDC_TIMING_DELAY();
	FDC_CMD_SEND(0xc6);
	if (FDC_ERROR_CODE != 0)
		return;
	FDC_POST_OP();
}

void FDC_SubmitWriteDataCmd(void)
{
	FDC_CMD_OPCODE = 0xc5;
	FDC_Setup_DMA_Mode();
	FDC_TIMING_DELAY();
	FDC_CMD_SEND(0xc5);
	if (FDC_ERROR_CODE != 0)
		return;
	FDC_POST_OP();
}
