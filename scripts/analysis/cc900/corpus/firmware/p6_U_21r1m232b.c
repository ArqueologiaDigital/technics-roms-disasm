/* helper U, round 21r1, module 232, form b: slot clears with the base taken into the end pointer first and copied
   to the running pointer (the ROM's lda xbc; ld xwa, xbc; lda xbc, (xbc+24)); the two guards as if / else with the
   call in the else branch (both ends tail jumps). */
/* cc900-module: BmDrEdit_IncrementDuration NoteEditSy_UpdateAllWidgets */

extern unsigned char __near ram_2746[];
extern unsigned char __near ram_2747[];
extern unsigned char __near ram_295c;
extern unsigned char __near ram_295d;
extern unsigned char __near ram_2774;
extern unsigned int __near ram_279a;
extern void BmDrEdit_IncrementDuration(void);
extern void NoteEditSy_UpdateAllWidgets(void);

void BmDrEdit_ClearAllSlots(void)
{
  unsigned char *p, *e;
  e = ram_2746;
  p = e;
  e += 24;
  do {
    *p = 0;
    p += 3;
  } while (p < e);
}

void BmDrEdit_ClearAllSlotsAlt(void)
{
  unsigned char *p, *e;
  e = ram_2747;
  p = e;
  e += 24;
  do {
    *p = 0;
    p += 3;
  } while (p < e);
}

void BmDrEdit_DurationUp_Check(void)
{
  if ((ram_295c & 0x80) && ram_295d != 3)
    ;
  else
    BmDrEdit_IncrementDuration();
}

void NoteEdit_UpdateScrollAndDisplay(void)
{
  if (ram_279a >= (unsigned int)(ram_2774 * 0x60))
    ;
  else
    NoteEditSy_UpdateAllWidgets();
}
