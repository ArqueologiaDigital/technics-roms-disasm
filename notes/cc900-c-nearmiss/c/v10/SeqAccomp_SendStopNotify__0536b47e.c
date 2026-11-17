/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_17c.c (2026-11-16-123-p6-r25)
   sha256 0536b47edacf4da52d1688dc7ec8a7cec2c512b91313e971d3def973fb9e2212 (tar-sha256); compiled at -O3 -Xr */
extern unsigned char __near ACTIVE_TITLE;
extern unsigned long __near SEQ_SCREEN_OBJECT;
extern void ApDeliveryEvent(long, long, long);
void SeqAccomp_SendStopNotify(void)
{
  if (ACTIVE_TITLE != 0x85 && ACTIVE_TITLE != 0x87) return;
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, 0x1c0000fL, 2L);
  return;
}
