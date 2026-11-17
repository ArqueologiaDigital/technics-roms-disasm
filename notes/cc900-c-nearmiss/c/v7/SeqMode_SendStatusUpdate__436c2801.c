/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v7/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 436c280195261ab58a6879fafc91b12d3049967758304e75fcdb6dd2be32f122 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8c9c;
extern void ApDeliveryEvent(long, long, long);
void SeqMode_SendStatusUpdate(void)
{
  switch (ram_8c9c) {
  case 0x81: ApDeliveryEvent(0x810005L, 0x1c0000fL, 1L); break;
  case 0x85: ApDeliveryEvent(0x850007L, 0x1c0000fL, 1L); break;
  case 0x87: ApDeliveryEvent(0x870003L, 0x1c0000fL, 1L); break;
  }
}
