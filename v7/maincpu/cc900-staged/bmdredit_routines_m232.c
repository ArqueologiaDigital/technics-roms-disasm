/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_DecrementVelocity BmDrEdit_IncrementVelocity BmDrEdit_NullReturn BmDrEdit_UpdateVelocityDisplay */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_295c;
extern unsigned char __near ram_295d;
extern unsigned char __near ram_295f;
extern unsigned char __near ram_2742;
extern void BmDrEdit_VelocityDown_Check(void);
extern void BmDrEdit_IncrementVelocity(void);
extern void BmDrEdit_DecrementVelocity(void);
extern void BmDrEdit_VelocityUp_Check(void);

void BmDrEdit_VelocityDown_Check(void)
{
  if ((ram_295c & 0x80) && ram_295d != 2)
    return;
  if (!(ram_295f & 1))
    return;
  if (ram_2742 & 1)
    BmDrEdit_IncrementVelocity();
  else
    BmDrEdit_DecrementVelocity();
}

void BmDrEdit_VelocityUp_Check(void)
{
  if ((ram_295c & 0x80) && ram_295d != 2)
    return;
  if (!(ram_295f & 1))
    return;
  if (ram_2742 & 1)
    BmDrEdit_DecrementVelocity();
  else
    BmDrEdit_IncrementVelocity();
}
