/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m235.c (2026-11-16-125-p6-r26-staged)
   sha256 236e406980b56da4a88dfd87fb77d46fee6483d61ded6cfe9248613f02c48d32 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ACTIVE_TITLE;
extern unsigned long __near SEQ_SCREEN_OBJECT;
extern void ApDeliveryEvent(long, long, long);
void SeqAccomp_SendStopNotify(void)
{
  if (ACTIVE_TITLE == 0x85 || ACTIVE_TITLE == 0x87)
    ApDeliveryEvent(SEQ_SCREEN_OBJECT, 0x1c0000fL, 2L);
}
