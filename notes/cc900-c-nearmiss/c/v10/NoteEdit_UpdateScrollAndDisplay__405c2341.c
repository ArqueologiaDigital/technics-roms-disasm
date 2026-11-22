/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m232a.c (2026-11-21-2-p6-r58)
   sha256 405c23417c2391f7ca3f29b41d45e864dc4c18a25003bfb1aa8e250c3cd9a758 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_2774;
extern unsigned int __near ram_279a;
extern void NoteEditSy_UpdateAllWidgets(void);
void NoteEdit_UpdateScrollAndDisplay(void)
{
  if (ram_279a < (unsigned int)(ram_2774 * 0x60))
    NoteEditSy_UpdateAllWidgets();
}
