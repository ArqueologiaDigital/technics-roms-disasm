/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m235a.c (2026-11-21-2-p6-r58)
   sha256 714a61e9798aacf7c616fc476cb14b604f3048efbcad2d7b9e7bf912ab7adabb (tar-sha256); compiled at -Xr */
extern void ApDeliveryEvent(long, long, long);
#define EVT_SET_PARAM 0x1e0003bL
void AppEvent_SendModeToggle(unsigned char on)
{
  ApDeliveryEvent(0x87000eL, EVT_SET_PARAM, (unsigned int)(on != 0));
}
