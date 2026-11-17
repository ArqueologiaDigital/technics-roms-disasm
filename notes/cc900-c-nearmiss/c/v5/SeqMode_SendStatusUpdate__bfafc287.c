/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v5/sequencer_engine_m235.c (2026-11-16-68-p6-r12)
   sha256 bfafc2875fa1d1fd79576b9677c9d023a72104b07c71ec3b3f8fc124f5de14a1 (tar-sha256); compiled at -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near ram_8c80;
extern void ApDeliveryEvent(long, long, long);
void SeqMode_SendStatusUpdate(void)
{
  switch (ram_8c80) {
  case 0x81: ApDeliveryEvent(0x810005L, 0x1c0000fL, 1L); break;
  case 0x85: ApDeliveryEvent(0x850007L, 0x1c0000fL, 1L); break;
  case 0x87: ApDeliveryEvent(0x870003L, 0x1c0000fL, 1L); break;
  }
}
