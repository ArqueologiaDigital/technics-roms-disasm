/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine.c (2026-11-16-45-p6-r9)
   sha256 5b43ccb0f5f0b0c86ae6214de92ae9d1c1dc1d567f7e9d57a09f52f4b38b93c5 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8c80;
void SeqMode_SendStatusUpdate(void)
{
  switch (ram_8c80) {
  case 0x81: ApDeliveryEvent(0x810005L, 0x1c0000fL, 1L); break;
  case 0x85: ApDeliveryEvent(0x850007L, 0x1c0000fL, 1L); break;
  case 0x87: ApDeliveryEvent(0x870003L, 0x1c0000fL, 1L); break;
  }
}
