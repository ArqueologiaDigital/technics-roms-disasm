/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

#define TT_SQNOTECYCP 0x96
extern unsigned char __near ram_278a;
extern unsigned int __near ram_2792;
extern unsigned char __near ram_295c;
extern unsigned char __near ram_2746;
extern unsigned char __near ram_8d88;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern void NoteEditSy_SendVelocityCmd(void);
extern void NoteEditSy_SendModeScrollCmd(void);
extern void UI_ChangeTitleByIndex(unsigned int);
extern unsigned char PartCtrl_ReadByte(unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void SoundCtrl_SaveAndSendCmd_EE(unsigned int);

void BmDrEdit_DecrementVelocityValue(void)
{
  unsigned char v = ram_278a;
  if (v == 1) return;
  v--;
  ram_278a = v;
  NoteEditSy_SendVelocityCmd();
}

void BmDrEdit_IncrementVelocityValue(void)
{
  unsigned char v = ram_278a;
  if (v >= 0x7f) return;
  v++;
  ram_278a = v;
  NoteEditSy_SendVelocityCmd();
}

void BmDrEdit_ModeScrollUp(void)
{
  unsigned int v;
  if (ram_295c & 0x80) return;
  v = ram_2792;
  if (v >= 0x60) return;
  v++;
  ram_2792 = v;
  NoteEditSy_SendModeScrollCmd();
}

void BmDrEdit_PostModeChange96(void)
{
  if (ram_2746 & 0x80) return;
  if (ram_295c & 0x80) return;
  UI_ChangeTitleByIndex(TT_SQNOTECYCP);
}

void BmDrEdit_RefreshDisplayState(void)
{
  ram_8d88 &= ~0x01;
  SoundCtrl_SaveAndSendCmd_EE(0xf);
  DEMO_CONTROL_FLAGS |= 0x10;
}

unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned char o)
{
  return PartCtrl_ReadByte(b, o);
}

void PartCtrl_WriteByte_ZeroExtended(unsigned int b, unsigned char o, unsigned char v)
{
  PartCtrl_WriteByteToBuf(b, o, v);
}
