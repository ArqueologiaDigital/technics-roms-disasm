/* helper Q, round 20r1, module 235, form b: the two mode-dependent wrappers as if / else (form a: ?: argument);
   the toggle with a char result. */

extern unsigned long __near SEQ_SCREEN_OBJECT;
extern unsigned char __near ram_2742;
extern void ApDeliveryEvent(long, long, long);

#define EVT_PARA_DRAW 0x1c0000fL
#define EVT_GRAPH_DRAW 0x1c80004L
#define EVT_SET_PARAM 0x1e0003bL

void NoteEditSy_SendModeWidgetCmd(void)
{
  if (ram_2742 & 1)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 13L);
  else
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 8L);
}

void NoteEditSy_SendModeScrollCmd(void)
{
  if (ram_2742 & 1)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 9L);
  else
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 6L);
}

void AppEvent_SendModeToggle(unsigned char on)
{
  unsigned int f;
  f = (on != 0);
  ApDeliveryEvent(0x87000eL, EVT_SET_PARAM, f);
}
