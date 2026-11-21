/* helper Z, round 22r1, module 232 (sequencer/bmdredit_routines.s), form a: BmDrEdit_ClearAllSlots / _Alt.  Every
   pointer spelling so far (runs r58, r62, r64) loads the base into the pointer's register and copies it to the end
   register; the ROM loads it into the end register XBC, copies it to the pointer XWA and forms the end in place
   (`lda xbc, base; ld xwa, xbc; lda xbc, (xbc+24)`): the shape -O3's strength reduction leaves for an indexed
   loop (one base temporary feeding both the running pointer and the end).  Here a byte index over the eight
   3-byte slots, `ram[i * 3] = 0`, as a for loop with constant bounds (no entry test).  Form b: a do / while with
   an int index. */

extern unsigned char __near ram_2746[];
extern unsigned char __near ram_2747[];

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
