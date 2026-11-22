/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_31r1m232b.c (2026-11-22-15-p6-r82)
   sha256 c3d290443d272580e00a40db7161302c3e280b2f592e3b4199bca6ee5616d8d1 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_295c;
extern unsigned char __near ram_295d;
extern unsigned char __near ram_2742;
extern unsigned char __near ram_2786;
extern void BmDrEdit_DrumVoiceUp(void);
extern void BmDrEdit_UpdateVelocityDisplay(void);
extern void NoteEditSy_SendScrollCmd3(void);
extern void BmDrEdit_NullReturn(void);
void BmDrEdit_IncrementVelocity(void)
{
  if (ram_2786 >= 0x7f)
    return;
  ram_2786++;
  if (ram_2742 & 1)
    BmDrEdit_DrumVoiceUp();
  BmDrEdit_UpdateVelocityDisplay();
  NoteEditSy_SendScrollCmd3();
  BmDrEdit_NullReturn();
  ram_295c = 0x83;
  ram_295d = 2;
}
