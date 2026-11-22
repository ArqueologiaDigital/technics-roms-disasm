/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m232b.c (2026-11-21-3-p6-r59)
   sha256 f65622f5f67c87fc4a733017a34beb70e88e1428770d49d80b48bde826bdad7f (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_278a;
extern void NoteEditSy_SendVelocityCmd(void);
void BmDrEdit_DecrementVelocityValue(void)
{
  unsigned char v;
  if ((v = ram_278a) != 1) {
    ram_278a = --v;
    NoteEditSy_SendVelocityCmd();
  }
}
