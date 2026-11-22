/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m235b.c (2026-11-21-2-p6-r58)
   sha256 1a036791e99671f87440711fb2e1692a6e53b62f1bd5295ecc1313149e06ce64 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned long __near SEQ_SCREEN_OBJECT;
extern unsigned char __near ram_2742;
extern void ApDeliveryEvent(long, long, long);
#define EVT_GRAPH_DRAW 0x1c80004L
void NoteEditSy_SendModeWidgetCmd(void)
{
  if (ram_2742 & 1)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 13L);
  else
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 8L);
}
