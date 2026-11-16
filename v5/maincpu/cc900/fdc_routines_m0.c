/* Functions of storage/fdc_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: FDC_NOP_Delay FDC_Send_Command FDC_Set_Status SOME_DELAY */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_89b6;
extern unsigned char __near FDC_SPECIFY_SRT;
extern unsigned char __near FDC_SPECIFY_HUT;
extern unsigned char __near FDC_SPECIFY_HLT;
extern unsigned char __near FDC_SPECIFY_ND;
extern unsigned char __near FDC_PARAM_DTL;
extern unsigned char __near FDC_FORMAT_FILL;
extern unsigned char __near ram_8983;
extern unsigned char __near ram_8984;
extern unsigned char __near ram_8985;
extern unsigned char __near ram_8986;
extern unsigned char __near ram_8987;
extern void FDC_InitStateVars(void);

void FDC_InitStateVars(void)
{
    FDC_SPECIFY_SRT = (ram_89b6 >> 4) & 0xf;
    FDC_PARAM_DTL = 255;
    FDC_FORMAT_FILL = 0;
    FDC_SPECIFY_HUT = 15;
    FDC_SPECIFY_HLT = 1;
    ram_8984 = 0;
    ram_8983 = 0;
    ram_8985 = 0;
    ram_8986 = 0;
    ram_8987 = 0;
    FDC_SPECIFY_ND = 0;
}
