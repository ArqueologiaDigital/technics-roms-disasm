/* Functions of ui/ui_control_panel.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: ClearAllSongSlots FindFirstEmptySlot */   /* scripts/analysis/cc900/module_calls.py v10 */

extern int BoxLeftCheck(int x);
extern int BoxRightCheck(int x);

int BoxLeftCheck(int x)
{
  if (x <= 0x88 && x >= 0x80) return 1;
  return 0;
}

int BoxRightCheck(int x)
{
  if (x <= 0xa8 && x >= 0xa0) return 1;
  return 0;
}
