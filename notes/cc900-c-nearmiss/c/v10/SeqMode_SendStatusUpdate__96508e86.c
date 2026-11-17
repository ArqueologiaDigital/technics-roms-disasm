/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine.c (2026-11-16-45-p6-r9)
   sha256 96508e86e589f8d14b12ceab0004a52f62048b42281d58fa666d36e8a7ca8e5b (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8d38;
void SeqMode_SendStatusUpdate(void)
{
  switch (ram_8d38) {
  case 0x81: ApDeliveryEvent(0x810005L, 0x1c0000fL, 1L); break;
  case 0x85: ApDeliveryEvent(0x850007L, 0x1c0000fL, 1L); break;
  case 0x87: ApDeliveryEvent(0x870003L, 0x1c0000fL, 1L); break;
  }
}
