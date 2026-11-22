/* helper W, round 21r2, module 232 (sequencer/bmdredit_routines.s), form a: BmDrEdit_ClearAllSlots / _Alt.  Run
   r62's best (p6_U_21r1m232b@O3Xr) was off only in the first two instructions: V4.23 loaded the base into XWA and
   copied it to XBC, the ROM loads it into XBC and copies it to XWA (`lda xbc; ld xwa, xbc; lda xbc, (xbc+24)`), the
   shape of one base value shared by the running pointer and a loop-invariant end.  Here the loop bound is written
   against the array itself (`p < ram_2746 + 24`), no end local. */

extern unsigned char __near ram_2746[];
extern unsigned char __near ram_2747[];

void BmDrEdit_ClearAllSlots(void)
{
  unsigned char *p;
  p = ram_2746;
  do {
    *p = 0;
    p += 3;
  } while (p < ram_2746 + 24);
}

void BmDrEdit_ClearAllSlotsAlt(void)
{
  unsigned char *p;
  p = ram_2747;
  do {
    *p = 0;
    p += 3;
  } while (p < ram_2747 + 24);
}
