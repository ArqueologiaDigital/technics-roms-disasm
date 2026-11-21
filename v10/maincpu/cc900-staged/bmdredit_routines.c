/* Functions of sequencer/bmdredit_routines.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern unsigned char __near ram_295c;
extern unsigned char __near ram_295e;
extern unsigned int __near ram_2792;
extern unsigned char __near ram_2742;
extern unsigned char __near ram_2746[][3];
extern unsigned int __near ram_279e;
extern unsigned int __near ram_27a0;
extern unsigned char __near ram_2786;
extern unsigned char __near SEQ_ERROR_CODE;
extern void NoteEditSy_SendModeScrollCmd(void);
extern void UI_ChangeTitleByIndex(unsigned int);
extern void BmDrEdit_LoadAlternateState(void);
extern void SeqData_SetErrorCode(unsigned int);
extern void BmDrEdit_CountMeasuresAndValidate(void);
extern void BmDrEdit_DelayAction_PlayClick(void);
extern void Metronome_PlayClick(void);
extern void BmDrEdit_BuildNoteOnEvent_WithVelocity(void);
extern void BmDrEdit_SendMetronomeNoteOn(void);
extern void BmDrEdit_CheckChannelActive(void);
extern void BmDrEdit_SelectActiveChannel(void);
#define TT_SQDRMCYCP 0x99

void BmDrEdit_CalcTrackPosition(void)
{
  if (!(ram_2742 & 0x01)) return;
  ram_2786 = ram_279e + ram_27a0;
}

void BmDrEdit_CheckAndSelectChannel(void)
{
  BmDrEdit_CheckChannelActive();
  BmDrEdit_SelectActiveChannel();
}

void BmDrEdit_DelayBExpired(void)
{
  if (ram_295e != 128) return;
  ram_295e = 0;
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
  if (ram_295c & 0x80) return;
  v = ram_2792;
  if (v == 0)
    ram_2792 = 48;
  else {
    if (v <= 1) return;
    ram_2792 = v - 1;
  }
  NoteEditSy_SendModeScrollCmd();
}

void BmDrEdit_PlayNoteAndSetDelay(void)
{
  BmDrEdit_SendMetronomeNoteOn();
  ram_295e = 134;
}

void BmDrEdit_PostModeChange99(void)
{
  if (ram_2746[0][0] & 0x80) return;
  if (ram_295c & 0x80) return;
  UI_ChangeTitleByIndex(TT_SQDRMCYCP);
}

void BmDrEdit_SendMetronomeNoteOn_Alt(void)
{
  Metronome_PlayClick();
  BmDrEdit_BuildNoteOnEvent_WithVelocity();
  ram_295e = 134;
}
