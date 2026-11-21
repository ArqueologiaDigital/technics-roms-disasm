/* helper Q, round 20r1, module 164 (ui/setwall_routines.s). */

extern unsigned char __near GLOBAL_ERROR_CODE;
extern unsigned char SEQ_CURRENT_SONG;
extern unsigned char __near ram_d3f;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern void CDlikeSwTtl_SendStartEvt(void);
extern void CDlikeSwTtl_SendResetEvent(void);
extern void SetWall_UpdateSlotIndex(void);

void SetWall_DataBlock1(void)
{
  GLOBAL_ERROR_CODE = 0;
  ram_d3f = SEQ_CURRENT_SONG;
}

void SetWall_SlotUpdate(void)
{
  if (!(PLAY_TRANSPORT_STATE & 0x04)) {
    CDlikeSwTtl_SendStartEvt();
    CDlikeSwTtl_SendResetEvent();
    SetWall_UpdateSlotIndex();
  }
}
