/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m235.c (2026-11-21-5-p6-r60)
   sha256 977683b578571284fc22dae25fe0670b23005954d0c59229f1ff39ea4c3f0659 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void ApDeliveryEvent(long, long, long);
extern unsigned long __near SEQ_SCREEN_OBJECT;
#define EVT_GRAPH_DRAW 0x1c80004L
extern unsigned char __near ram_2728;
void NoteEditSy_SendModeWidgetCmd(void)
{
  if (ram_2728 & 1)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 13L);
  else
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_GRAPH_DRAW, 8L);
}
