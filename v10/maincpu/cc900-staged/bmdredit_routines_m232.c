/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_CheckAndAdvancePage */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned int __near ram_279a;
extern unsigned int __near ram_2782;
extern unsigned char __near ram_2784;
extern void BmDrEdit_CheckAndAdvancePage(void);
extern void BmDrEdit_CalcTickPosition(void);

void BmDrEdit_CalcTickPosition(void)
{
	unsigned int t;

	BmDrEdit_CheckAndAdvancePage();
	t = ram_2782 * 0x60;
	t += ram_2784;
	ram_279a = t;
}
