/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: BmDrEdit_BuildNoteOnEvent_WithVelocity BmDrEdit_CheckChannelActive BmDrEdit_CountMeasuresAndValidate BmDrEdit_DelayAction_PlayClick BmDrEdit_IncrementDuration BmDrEdit_LoadAlternateState BmDrEdit_SelectActiveChannel BmDrEdit_SendMetronomeNoteOn Metronome_PlayClick NoteEditSy_UpdateAllWidgets SeqAcc_HandlePlaybackTick SeqAcc_InitAndDispatch SeqAcc_SetupRepeatCount */   /* scripts/analysis/cc900/module_calls.py v10 */

extern unsigned char __near ram_2728;
extern unsigned int __near ram_2784;
extern unsigned int __near ram_2786;
extern unsigned char __near ram_276c;
extern void BmDrEdit_CalcTrackPosition(void);
extern void BmDrEdit_CheckChannelActive(void);
extern void BmDrEdit_SelectActiveChannel(void);
extern void BmDrEdit_CheckAndSelectChannel(void);
extern unsigned char __near ram_2942;
extern void BmDrEdit_DelayAction_PlayClick(void);
extern void BmDrEdit_DelayBExpired(void);
extern unsigned char __near SEQ_ERROR_CODE;
extern void BmDrEdit_LoadAlternateState(void);
extern void SeqData_SetErrorCode(unsigned int);
extern void BmDrEdit_CountMeasuresAndValidate(void);
extern void BmDrEdit_LoadAlternateAndValidate(void);
extern unsigned char __near ram_2940;
extern unsigned int __near ram_2778;
extern void NoteEditSy_SendModeScrollCmd(void);
extern void BmDrEdit_ModeScrollDown(void);
extern void BmDrEdit_SendMetronomeNoteOn(void);
extern void BmDrEdit_PlayNoteAndSetDelay(void);
extern unsigned char __near ram_272c[][3];
extern void UI_ChangeTitleByIndex(unsigned int);
#define TT_SQDRMCYCP 0x99
extern void BmDrEdit_PostModeChange99(void);
extern void Metronome_PlayClick(void);
extern void BmDrEdit_BuildNoteOnEvent_WithVelocity(void);
extern void BmDrEdit_SendMetronomeNoteOn_Alt(void);
extern unsigned char __near ram_2770;
extern void NoteEditSy_SendVelocityCmd(void);
extern void BmDrEdit_DecrementVelocityValue(void);
extern void BmDrEdit_IncrementVelocityValue(void);
extern void BmDrEdit_ModeScrollUp(void);
extern unsigned char __near ram_8cc8;
extern unsigned char __near DEMO_CONTROL_FLAGS;
extern void SoundCtrl_SaveAndSendCmd_EE(unsigned int);
extern void BmDrEdit_RefreshDisplayState(void);
extern unsigned char PartCtrl_ReadByte(unsigned int, unsigned int);
extern unsigned char PartCtrl_ReadByteExtended(unsigned int b, unsigned char o);
extern void PartCtrl_WriteByteToBuf(unsigned int, unsigned int, unsigned int);
extern void PartCtrl_WriteByte_ZeroExtended(unsigned int b, unsigned char o, unsigned char v);

void BmDrEdit_CalcTrackPosition(void)
{
  if (!(ram_2728 & 0x01)) return;
  ram_276c = ram_2784 + ram_2786;
}

void BmDrEdit_CheckAndSelectChannel(void)
{
  BmDrEdit_CheckChannelActive();
  BmDrEdit_SelectActiveChannel();
}

void BmDrEdit_DelayBExpired(void)
{
  if (ram_2942 != 128) return;
  ram_2942 = 0;
  BmDrEdit_DelayAction_PlayClick();
}

void BmDrEdit_LoadAlternateAndValidate(void)
{
  BmDrEdit_LoadAlternateState();
  if (SEQ_ERROR_CODE != 0)
    SeqData_SetErrorCode(0xb8);
  BmDrEdit_CountMeasuresAndValidate();
}

void BmDrEdit_ModeScrollDown(void)
{
  unsigned int v;
  if (ram_2940 & 0x80) return;
  v = ram_2778;
  if (v == 0)
    ram_2778 = 48;
  else {
    if (v <= 1) return;
    ram_2778 = v - 1;
  }
  NoteEditSy_SendModeScrollCmd();
}

void BmDrEdit_PlayNoteAndSetDelay(void)
{
  BmDrEdit_SendMetronomeNoteOn();
  ram_2942 = 134;
}

void BmDrEdit_PostModeChange99(void)
{
  if (ram_272c[0][0] & 0x80) return;
  if (ram_2940 & 0x80) return;
  UI_ChangeTitleByIndex(TT_SQDRMCYCP);
}

void BmDrEdit_SendMetronomeNoteOn_Alt(void)
{
  Metronome_PlayClick();
  BmDrEdit_BuildNoteOnEvent_WithVelocity();
  ram_2942 = 134;
}

void BmDrEdit_DecrementVelocityValue(void)
{
  unsigned char v = ram_2770;
  if (v == 1) return;
  v--;
  ram_2770 = v;
  NoteEditSy_SendVelocityCmd();
}

void BmDrEdit_IncrementVelocityValue(void)
{
  unsigned char v = ram_2770;
  if (v >= 0x7f) return;
  v++;
  ram_2770 = v;
  NoteEditSy_SendVelocityCmd();
}

void BmDrEdit_ModeScrollUp(void)
{
  unsigned int v;
  if (ram_2940 & 0x80) return;
  v = ram_2778;
  if (v >= 0x60) return;
  v++;
  ram_2778 = v;
  NoteEditSy_SendModeScrollCmd();
}

void BmDrEdit_RefreshDisplayState(void)
{
  ram_8cc8 &= ~0x01;
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
