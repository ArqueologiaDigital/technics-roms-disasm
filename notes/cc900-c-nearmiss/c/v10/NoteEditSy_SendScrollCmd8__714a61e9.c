/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m235a.c (2026-11-21-2-p6-r58)
   sha256 714a61e9798aacf7c616fc476cb14b604f3048efbcad2d7b9e7bf912ab7adabb (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned long __near SEQ_SCREEN_OBJECT;
extern void ApDeliveryEvent(long, long, long);
#define EVT_PARA_DRAW 0x1c0000fL
void NoteEditSy_SendScrollCmd8(void)
{
  ApDeliveryEvent(SEQ_SCREEN_OBJECT, EVT_PARA_DRAW, 8L);
}
