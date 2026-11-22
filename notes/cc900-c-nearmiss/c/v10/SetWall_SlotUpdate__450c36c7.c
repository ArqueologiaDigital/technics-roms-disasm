/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_Q_20r1m164a.c (2026-11-21-2-p6-r58)
   sha256 450c36c786576a9c2836269be648cffc7440ddb44ede699c6950de0feba53c4f (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern void CDlikeSwTtl_SendStartEvt(void);
extern void CDlikeSwTtl_SendResetEvent(void);
extern void SetWall_UpdateSlotIndex(void);
void SetWall_SlotUpdate(void)
{
  if (!(PLAY_TRANSPORT_STATE & 0x04)) {
    CDlikeSwTtl_SendStartEvt();
    CDlikeSwTtl_SendResetEvent();
    SetWall_UpdateSlotIndex();
  }
}
