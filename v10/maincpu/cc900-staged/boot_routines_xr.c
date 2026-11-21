/* Functions of shared/boot_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/

extern volatile unsigned char __tiny PH;
extern unsigned char __near REGION_CODE_VAR;

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
