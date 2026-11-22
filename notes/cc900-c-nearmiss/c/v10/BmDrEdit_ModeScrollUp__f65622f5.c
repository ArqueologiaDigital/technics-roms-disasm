/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_R_20r1m232b.c (2026-11-21-3-p6-r59)
   sha256 f65622f5f67c87fc4a733017a34beb70e88e1428770d49d80b48bde826bdad7f (tar-sha256); compiled at -O3 -Xr */
extern unsigned int __near ram_2792;
extern unsigned char __near ram_295c;
extern void NoteEditSy_SendModeScrollCmd(void);
void BmDrEdit_ModeScrollUp(void)
{
  unsigned int v;
  if (!(ram_295c & 0x80) && (v = ram_2792) < 0x60) {
    ram_2792 = ++v;
    NoteEditSy_SendModeScrollCmd();
  }
}
