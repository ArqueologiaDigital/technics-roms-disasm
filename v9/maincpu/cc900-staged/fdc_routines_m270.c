/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: ApTaskControl ClearAllSongSlots Composer_GetPassword FDC_CMD_SEND FindFirstEmptySlot SOME_DELAY SetDialFocus */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __tiny PA;
extern void FDC_CMD_SEND(int);
extern void FDC_CMD_DISABLE(void);
extern unsigned char __near FDC_ERROR_CODE;
extern void FDC_ClearStatus_InitTimer(void);
extern unsigned char __tiny PD;
extern void SOME_DELAY(int);
extern void FDC_PulseResetLine(void);
extern unsigned char __near ram_8b20;
extern unsigned char __near ram_8b22;
extern void FDC_RecordDensityCode(unsigned char a);
extern unsigned char __near FDC_RESULT;
extern void FDC_TIMING_DELAY(void);

void FDC_CMD_DISABLE(void)
{
  PA &= ~0x08;
  FDC_CMD_SEND(14);
}

void FDC_ClearStatus_InitTimer(void)
{
  FDC_ERROR_CODE = 0;
}

void FDC_PulseResetLine(void)
{
  PD |= 0x01;
  SOME_DELAY(10);
  PD &= ~0x01;
  SOME_DELAY(10);
}

void FDC_RecordDensityCode(unsigned char a)
{
  ram_8b20 = ram_8b22;
  ram_8b22 = a;
}

void FDC_TIMING_DELAY(void)
{
  FDC_RESULT = 255;
}
