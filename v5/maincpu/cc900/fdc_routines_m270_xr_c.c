/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: FDC_CMD_SEND FDC_Set_Status SOME_DELAY */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __tiny PA;
extern unsigned char __near FDC_ERROR_CODE;
extern void FDC_CMD_SEND(int);
extern void FDC_Set_Status(int);
extern void SOME_DELAY(int);
extern void FDC_CMD_ENABLE(void);

void FDC_CMD_ENABLE(void)
{
    int i;

    PA |= 0x08;
    FDC_CMD_SEND(254);
    if (FDC_ERROR_CODE != 0) {
        FDC_Set_Status(49);
        return;
    }
    for (i = 1; i != 0; i--)
        SOME_DELAY(10);
}
