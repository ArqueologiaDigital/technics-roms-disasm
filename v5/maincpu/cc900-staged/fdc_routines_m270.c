/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
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
