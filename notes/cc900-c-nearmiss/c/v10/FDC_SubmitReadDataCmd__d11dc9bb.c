/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_J_27r1m270e.c (2026-11-22-7-p6-r74)
   sha256 d11dc9bb267e0836ec34e4924a027924137df902e947143d34fe2cd68f576133 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
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
	if (FDC_ERROR_CODE == 0)
		FDC_POST_OP();
}
