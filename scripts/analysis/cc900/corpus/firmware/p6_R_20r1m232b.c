/* Helper R, round 1 of 2026-11-20: module 232, form b (the steppers written on the cell, the slot clear with an end
   pointer in a register). */

extern unsigned char __near ram_278a;
extern unsigned int __near ram_2792;
extern unsigned char __near ram_295c;
extern unsigned char __near ram_2747[];
extern void NoteEditSy_SendVelocityCmd(void);
extern void NoteEditSy_SendModeScrollCmd(void);

void BmDrEdit_IncrementVelocityValue(void)
{
  unsigned char v;
  if ((v = ram_278a) < 0x7f) {
    ram_278a = ++v;
    NoteEditSy_SendVelocityCmd();
  }
}

void BmDrEdit_DecrementVelocityValue(void)
{
  unsigned char v;
  if ((v = ram_278a) != 1) {
    ram_278a = --v;
    NoteEditSy_SendVelocityCmd();
  }
}

void BmDrEdit_ModeScrollUp(void)
{
  unsigned int v;
  if (!(ram_295c & 0x80) && (v = ram_2792) < 0x60) {
    ram_2792 = ++v;
    NoteEditSy_SendModeScrollCmd();
  }
}

void BmDrEdit_ClearAllSlotsAlt(void)
{
  unsigned char *p, *e;
  p = ram_2747;
  e = p + 24;
  do {
    *p = 0;
    p += 3;
  } while (p < e);
}
