/* Helper R, round 1 of 2026-11-20: module 232 (sequencer/bmdredit_routines.s, sequencer/sequencer_ui.s), note-edit
   value steppers and small wrappers.  Form a. */

#define TT_SQNOTECYCP 0x96
#define EVT_LYRICS_PLAY_REQUEST 0x1c70011L

extern unsigned char __near ram_278a;
extern unsigned int __near ram_2792;
extern unsigned char __near ram_295c;
extern unsigned char __near ram_2746;
extern unsigned char __near ram_8d88;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern unsigned char __near ram_2747[];
extern unsigned int TrAsGrid_LookupTable_Table[];
extern void NoteEditSy_SendVelocityCmd(void);
extern void NoteEditSy_SendModeScrollCmd(void);
extern void UI_ChangeTitleByIndex(unsigned int);
extern unsigned char PartCtrl_ReadByte(unsigned int, unsigned int);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void SoundCtrl_SaveAndSendCmd_EE(unsigned int);
extern long ApPostEvent(long, long, long);

void BmDrEdit_IncrementVelocityValue(void)
{
  unsigned char v = ram_278a;
  if (v >= 0x7f) return;
  v++;
  ram_278a = v;
  NoteEditSy_SendVelocityCmd();
}

void BmDrEdit_DecrementVelocityValue(void)
{
  unsigned char v = ram_278a;
  if (v == 1) return;
  v--;
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

unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned char o)
{
  return PartCtrl_ReadByte(b, o);
}

void PartCtrl_WriteByte_ZeroExtended(unsigned int b, unsigned char o, unsigned char v)
{
  PartCtrl_WriteByteToBuf(b, o, v);
}

void BmDrEdit_RefreshDisplayState(void)
{
  ram_8d88 &= ~0x01;
  SoundCtrl_SaveAndSendCmd_EE(0xf);
  DEMO_CONTROL_FLAGS |= 0x10;
}

void BmDrEdit_ClearAllSlotsAlt(void)
{
  unsigned char *p;
  for (p = ram_2747; p < ram_2747 + 24; p += 3)
    *p = 0;
}

unsigned int TrAsGrid_LookupTable(unsigned char a)
{
  return TrAsGrid_LookupTable_Table[a];
}

void Audio_SendEventPostCmd(void)
{
  ApPostEvent(0x720006L, EVT_LYRICS_PLAY_REQUEST, 0L);
}
