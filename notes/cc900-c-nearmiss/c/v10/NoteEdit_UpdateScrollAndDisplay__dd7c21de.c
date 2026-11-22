/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_U_21r1m232b.c (2026-11-21-7-p6-r62)
   sha256 dd7c21de109f6e206cbe83663c9a18937a6a6ff53a6ac015c5ecdeee7fb4ed8c (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ram_2774;
extern unsigned int __near ram_279a;
extern void NoteEditSy_UpdateAllWidgets(void);
void NoteEdit_UpdateScrollAndDisplay(void)
{
  if (ram_279a >= (unsigned int)(ram_2774 * 0x60))
    ;
  else
    NoteEditSy_UpdateAllWidgets();
}
