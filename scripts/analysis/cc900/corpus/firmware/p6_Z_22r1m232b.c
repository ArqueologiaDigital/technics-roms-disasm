/* helper Z, round 22r1, module 232 (sequencer/bmdredit_routines.s), form b: BmDrEdit_ClearAllSlots / _Alt, as
   form a but the slots as an array of 3-byte structs indexed by an int in a for loop (field 0 of each slot). */

struct bmslot { unsigned char b0; unsigned char b1; unsigned char b2; };
extern struct bmslot __near ram_2746[];
struct bmslot2 { unsigned char b1; unsigned char b2; unsigned char b0n; };
extern struct bmslot2 __near ram_2747[];

void BmDrEdit_ClearAllSlots(void)
{
  int i;
  for (i = 0; i < 8; i++)
    ram_2746[i].b0 = 0;
}

void BmDrEdit_ClearAllSlotsAlt(void)
{
  int i;
  for (i = 0; i < 8; i++)
    ram_2747[i].b1 = 0;
}
