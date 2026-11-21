/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_2746[];
extern void BmDrEdit_ClearAllSlots(void);
extern unsigned char __near ram_2747[];
extern void BmDrEdit_ClearAllSlotsAlt(void);

void BmDrEdit_ClearAllSlots(void)
{
  unsigned char i;
  for (i = 0; i < 8; i++)
    ram_2746[i * 3] = 0;
}

void BmDrEdit_ClearAllSlotsAlt(void)
{
  unsigned char i;
  for (i = 0; i < 8; i++)
    ram_2747[i * 3] = 0;
}
