/* helper U, round 21r1, module 232 (sequencer/bmdredit_routines.s), form a: one-spot retries of runs r58 / r59.
   Slot clears: the ROM keeps the running pointer in XWA and the end in XBC: the end pointer declared first.
   DurationUp_Check / NoteEdit_UpdateScrollAndDisplay: the ROM tail-jumps to the callee (jr / jrl), so the guard
   returns early and the call ends the function (an if without else keeps call + ret). */
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
  unsigned char *e, *p;
  p = ram_2746;
  e = p + 24;
  do {
    *p = 0;
    p += 3;
  } while (p < e);
}

void BmDrEdit_ClearAllSlotsAlt(void)
{
  unsigned char *e, *p;
  p = ram_2747;
  e = p + 24;
  do {
    *p = 0;
    p += 3;
  } while (p < e);
}

void BmDrEdit_DurationUp_Check(void)
{
  if ((ram_295c & 0x80) && ram_295d != 3)
    return;
  BmDrEdit_IncrementDuration();
}

void NoteEdit_UpdateScrollAndDisplay(void)
{
  if (ram_279a >= (unsigned int)(ram_2774 * 0x60))
    return;
  NoteEditSy_UpdateAllWidgets();
}
