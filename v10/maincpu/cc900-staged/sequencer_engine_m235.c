/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), STAGED: Toshiba V4.23 reproduces these functions' ROM bytes
   (notes/cc900-phase6-2026-11-16/staged_v423.tsv); they move into cc900/ once `make` compiles with V4.23.
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/

extern void ApDeliveryEvent(long, long, long);
#define EVT_SET_PARAM 0x1e0003bL
extern void AppEvent_SendAccompStatus(long v);
extern void AppEvent_SendModeToggle(unsigned char on);
extern void AppEvent_SendPlayStatus(long v);
extern void NoteEditSy_ScrollCase2(long v);
extern unsigned long __near SEQ_SCREEN_OBJECT;
#define EVT_PARA_DRAW 0x1c0000fL
extern void NoteEditSy_SendScrollCmd0(void);
extern void NoteEditSy_SendScrollCmd2(void);
extern void NoteEditSy_SendScrollCmd3(void);
extern void NoteEditSy_SendScrollCmd8(void);
#define EVT_GRAPH_DRAW 0x1c80004L
extern void NoteEditSy_SendWidgetCmd1(void);
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void UI_InterruptTitleByIndex(unsigned int);
#define TT_MESAGE 0xee
extern void SoundCtrl_SaveAndSendCmd_EE(unsigned int code);
extern unsigned char __near ram_2742;
extern void NoteEditSy_SendModeScrollCmd(void);
extern void NoteEditSy_SendModeWidgetCmd(void);
extern void AppEvent_SendVoiceUpdate(long v);
extern void NoteEditSy_ScrollCase1(long v);
extern void NoteEditSy_ScrollReset(long v);
extern void SetVisible(long, unsigned int);
extern void SeqIndicator_HideBoth(void);
extern void Part_ClearAllVoiceChannels(void);
extern void Part_UnlinkVoiceFromChain(void);
extern void SeqLoadPre(void);
extern unsigned char SEQ_SONG_SLOTS[];
extern long FileIO_WriteByte_Impl(void *, long);
extern void SeqSave_WriteBlockToFile(unsigned char a);

void AppEvent_SendAccompStatus(long v)
{
  ApDeliveryEvent(0x860007L, EVT_SET_PARAM, v);
}

void AppEvent_SendModeToggle(unsigned char on)
{
  ApDeliveryEvent(0x87000eL, EVT_SET_PARAM, (unsigned int)(on != 0));
}

void AppEvent_SendPlayStatus(long v)
{
  ApDeliveryEvent(0x850004L, EVT_SET_PARAM, v);
}

void NoteEditSy_ScrollCase2(long v)
{
  ApDeliveryEvent(0x880004L, EVT_SET_PARAM, v);
}

void NoteEditSy_SendScrollCmd0(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 0L);
}

void NoteEditSy_SendScrollCmd2(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 2L);
}

void NoteEditSy_SendScrollCmd3(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 3L);
}

void NoteEditSy_SendScrollCmd8(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 8L);
}

void NoteEditSy_SendWidgetCmd1(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 1L);
}

void SoundCtrl_SaveAndSendCmd_EE(unsigned int code)
{
  GLOBAL_ERROR_CODE = code;
  UI_InterruptTitleByIndex(TT_MESAGE);
}

void NoteEditSy_SendModeScrollCmd(void)
{
  if (ram_2742 & 1)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 9L);
  else
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 6L);
}

void NoteEditSy_SendModeWidgetCmd(void)
{
  if (ram_2742 & 1)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 13L);
  else
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 8L);
}

void AppEvent_SendVoiceUpdate(long v)
{
  ApDeliveryEvent(0x810003L, EVT_SET_PARAM, v);
}

void NoteEditSy_ScrollCase1(long v)
{
  ApDeliveryEvent(0x87000dL, EVT_SET_PARAM, v);
}

void NoteEditSy_ScrollReset(long v)
{
  ApDeliveryEvent(0x850006L, EVT_SET_PARAM, v);
}

void SeqIndicator_HideBoth(void)
{
  SetVisible(0x850013L, 0);
  SetVisible(0x850014L, 0);
}

void SeqLoadPre(void)
{
  Part_ClearAllVoiceChannels();
  Part_UnlinkVoiceFromChain();
}

void SeqSave_WriteBlockToFile(unsigned char a)
{
  FileIO_WriteByte_Impl((void *)(SEQ_SONG_SLOTS + ((unsigned long)a << 11)), 0x800L);
}
