/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m235.c (2026-11-21-5-p6-r60)
   sha256 b8eff81d58bdd4954c98266713d8d99e290936075edef6402be147c8471a4121 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern void ApDeliveryEvent(long, long, long);
extern unsigned long __near SEQ_SCREEN_OBJECT;
#define EVT_PARA_DRAW 0x1c0000fL
void NoteEditSy_SendScrollCmd8(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 8L);
}
