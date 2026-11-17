/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_14b.c (2026-11-16-100-p6-r19)
   sha256 4593df46c7ccd0fe04e84b3b12d7adf29ec8187be773eb6acc8acb80e215a928 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_CHORD_FROM_SONG;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near ram_28ac;
extern unsigned int __near ram_2838;
extern void SeqModeTransit_DemoPath(void);
extern void SeqModeTransit_UpdateParts(void);
void Seq_HandleModeTransition(void)
{
  unsigned char a;
  if (SEQ_TRACK_MASK == 0) { SEQ_CHORD_FROM_SONG = 0; SEQ_RTMCFG &= ~0x08; }
  PLAY_TRANSPORT_STATE &= ~0x10;
  PLAY_TRANSPORT_STATE &= ~0x02;
  ACC_TRANSPORT_STATE &= ~0x10;
  ACC_TRANSPORT_STATE &= ~0x02;
  a = ACC_TRANSPORT_STATE;
  if (CURRENT_MODE == 19) SeqModeTransit_DemoPath();
  else if (ram_28ac & 0x20) SeqModeTransit_UpdateParts();
  else if (!(SEQ_TRANSPORT_STATE & 0x04) && !(a & 0x04)) SeqModeTransit_UpdateParts();
  ram_2838 = SEQ_TRACK_MASK;
}
