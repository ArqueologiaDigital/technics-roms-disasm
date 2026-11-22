/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDC_CMD_SEND FDC_POST_OP FDC_Setup_DMA_Mode FDC_TIMING_DELAY */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near FDC_CMD_OPCODE;
extern unsigned char __near FDC_ERROR_CODE;
extern void FDC_Setup_DMA_Mode(void);
extern void FDC_TIMING_DELAY(void);
extern void FDC_CMD_SEND(int);
extern void FDC_POST_OP(void);
extern void FDC_SubmitWriteDataCmd(void);


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
