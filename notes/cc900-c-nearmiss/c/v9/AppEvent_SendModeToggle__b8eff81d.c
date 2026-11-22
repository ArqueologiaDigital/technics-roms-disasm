/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m235.c (2026-11-21-5-p6-r60)
   sha256 b8eff81d58bdd4954c98266713d8d99e290936075edef6402be147c8471a4121 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern void ApDeliveryEvent(long, long, long);
#define EVT_SET_PARAM 0x1e0003bL
void AppEvent_SendModeToggle(unsigned char on)
{
  ApDeliveryEvent(0x87000eL, EVT_SET_PARAM, (unsigned int)(on != 0));
}
