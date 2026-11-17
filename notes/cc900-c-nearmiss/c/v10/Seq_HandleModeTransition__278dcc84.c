/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v10/sequencer_engine_m234.c (2026-11-16-111-p6-r22-staged)
   sha256 278dcc8402667cc209b615ab5ea8763c03b18d43d959e2e1fb6f264f6dbbd4f0 (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned int __near ram_2838;
extern unsigned char __near SEQ_CHORD_FROM_SONG;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near PLAY_TRANSPORT_STATE;
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned char __near CURRENT_MODE;
extern unsigned char __near ram_28ac;
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
