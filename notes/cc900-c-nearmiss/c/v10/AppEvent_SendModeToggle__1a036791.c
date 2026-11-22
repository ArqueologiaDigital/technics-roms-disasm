/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m235b.c (2026-11-21-2-p6-r58)
   sha256 1a036791e99671f87440711fb2e1692a6e53b62f1bd5295ecc1313149e06ce64 (tar-sha256); compiled at -Xr */
extern void ApDeliveryEvent(long, long, long);
#define EVT_SET_PARAM 0x1e0003bL
void AppEvent_SendModeToggle(unsigned char on)
{
  unsigned int f;
  f = (on != 0);
  ApDeliveryEvent(0x87000eL, EVT_SET_PARAM, f);
}
