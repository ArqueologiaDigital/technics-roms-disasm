/* Functions of file_io/medley.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: SetDialFocus */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int ram_9480e;
extern unsigned int Composer_GetPassword(void);

unsigned int Composer_GetPassword(void)
{
  return ram_9480e;
}
