/* Functions of demo/file_demo_proc.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: Seq_CopyResourcePtrs */   /* scripts/analysis/cc900/module_calls.py v10 */

struct disk { long freesz; long total; };
extern struct disk ram_25d6c;
extern void GetDiskFreeSpace(long *, long *);
extern long FileIO_GetDiskFreeSpace(void);

long FileIO_GetDiskFreeSpace(void)
{
  GetDiskFreeSpace(&ram_25d6c.freesz, &ram_25d6c.total);
  return ram_25d6c.freesz;
}
