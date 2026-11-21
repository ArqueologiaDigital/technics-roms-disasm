/* Functions of demo/fdemotext_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -Xr
*/
/* cc900-module: Seq_CopyResourcePtrs */   /* scripts/analysis/cc900/module_calls.py v10 */

extern void FDemoText_ScaleUpCoords(int *s, int *d);
extern unsigned int ram_25b82;
extern void Seq_CopyResourcePtrs(unsigned int);
extern void Seq_PostProcessDisplay(void);

void FDemoText_ScaleUpCoords(int *s, int *d)
{
  d[0] = s[0] << 3;
  d[1] = (s[1] << 2) + 3;
}

void Seq_PostProcessDisplay(void)
{
  Seq_CopyResourcePtrs(ram_25b82);
}
