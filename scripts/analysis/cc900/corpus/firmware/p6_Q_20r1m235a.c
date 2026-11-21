/* helper Q, round 20r1, module 235 (sequencer/sequencer_engine.s): event-posting wrappers of the note-edit screens. */

extern unsigned long __near SEQ_SCREEN_OBJECT;
extern unsigned char __near ram_2742;
extern unsigned char __near GLOBAL_ERROR_CODE;
extern void ApDeliveryEvent(long, long, long);
extern void UI_InterruptTitleByIndex(unsigned int);

#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_GRAPH_DRAW 0x1c80004L
#define EVT_SET_PARAM 0x1e0003bL
#define TT_MESAGE 0xee

void NoteEditSy_SendModeWidgetCmd(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, (ram_2742 & 1) ? 13L : 8L);
}

void NoteEditSy_SendModeScrollCmd(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, (ram_2742 & 1) ? 9L : 6L);
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

void NoteEditSy_ScrollCase2(long v)
{
  ApDeliveryEvent(0x880004L, EVT_SET_PARAM, v);
}

void AppEvent_SendAccompStatus(long v)
{
  ApDeliveryEvent(0x860007L, EVT_SET_PARAM, v);
}

void AppEvent_SendPlayStatus(long v)
{
  ApDeliveryEvent(0x850004L, EVT_SET_PARAM, v);
}

void AppEvent_SendModeToggle(unsigned char on)
{
  ApDeliveryEvent(0x87000eL, EVT_SET_PARAM, (unsigned int)(on != 0));
}

void SoundCtrl_SaveAndSendCmd_EE(unsigned int code)
{
  GLOBAL_ERROR_CODE = code;
  UI_InterruptTitleByIndex(TT_MESAGE);
}
