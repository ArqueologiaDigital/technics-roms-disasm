/* Functions of shared/boot_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: Vga_SelectWritePlane */   /* scripts/analysis/cc900/module_calls.py v10 */

extern volatile unsigned char __tiny PH;
extern unsigned char __near REGION_CODE_VAR;
extern void Detect_Region_Code(void);

void Detect_Region_Code(void)
{
  if (PH & 0x04) {
    if (PH & 0x02)
      REGION_CODE_VAR = 1;
    else
      REGION_CODE_VAR = 2;
  } else {
    if (PH & 0x02)
      REGION_CODE_VAR = 3;
    else
      REGION_CODE_VAR = 4;
  }
}
