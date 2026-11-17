/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_14a.c (2026-11-16-100-p6-r19)
   sha256 85fbeeab11365f896e371bcac755fbdcf9888c9c7500cb9a0ebbc1e1bd869b02 (tar-sha256); compiled at -O3 -XS -Xr */
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
  a = ACC_TRANSPORT_STATE;
  a &= ~0x10;
  a &= ~0x02;
  ACC_TRANSPORT_STATE = a;
  if (CURRENT_MODE == 19) SeqModeTransit_DemoPath();
  else if ((ram_28ac & 0x20) || (!(SEQ_TRANSPORT_STATE & 0x04) && !(a & 0x04))) SeqModeTransit_UpdateParts();
  ram_2838 = SEQ_TRACK_MASK;
}
