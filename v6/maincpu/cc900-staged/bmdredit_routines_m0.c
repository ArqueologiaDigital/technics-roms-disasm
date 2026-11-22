/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_DecrementVelocity BmDrEdit_IncrementVelocity BmDrEdit_NullReturn BmDrEdit_UpdateVelocityDisplay */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_2940;
extern unsigned char __near ram_2941;
extern unsigned char __near ram_2728;
extern unsigned char __near ram_276c;
extern void BmDrEdit_DrumVoiceDown(void);
extern void BmDrEdit_UpdateVelocityDisplay(void);
extern void NoteEditSy_SendScrollCmd3(void);
extern void BmDrEdit_NullReturn(void);
extern void BmDrEdit_DecrementVelocity(void);
extern void BmDrEdit_DrumVoiceUp(void);
extern void BmDrEdit_IncrementVelocity(void);

void BmDrEdit_DecrementVelocity(void)
{
  unsigned char v;

  v = ram_276c;
  if (v == 1)
    return;
  ram_276c = v - 1;
  if (ram_2728 & 1)
    BmDrEdit_DrumVoiceDown();
  BmDrEdit_UpdateVelocityDisplay();
  NoteEditSy_SendScrollCmd3();
  BmDrEdit_NullReturn();
  ram_2940 = 0x83;
  ram_2941 = 2;
}

void BmDrEdit_IncrementVelocity(void)
{
  unsigned char v;

  v = ram_276c;
  if (v >= 0x7f)
    return;
  ram_276c = v + 1;
  if (ram_2728 & 1)
    BmDrEdit_DrumVoiceUp();
  BmDrEdit_UpdateVelocityDisplay();
  NoteEditSy_SendScrollCmd3();
  BmDrEdit_NullReturn();
  ram_2940 = 0x83;
  ram_2941 = 2;
}
