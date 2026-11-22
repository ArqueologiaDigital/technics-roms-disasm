/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_31r1m232a.c (2026-11-22-15-p6-r82)
   sha256 d12e71f1e727d42ff0f1008c8e9323ebdd0dca9518be0ec78beb41971a3074dd (tar-sha256); compiled at -O3 -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_PLAY_FLAGS;
extern unsigned int __near SEQ_RECORDED_TRACKS;
extern unsigned char __near SEQ_METRO_FLAGS;
extern unsigned char __near ram_f23c;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned int __near ram_2336;
extern unsigned char __near ram_22fc;
extern void TempoRingBuf_Init(void);
extern void Audio_CheckSubsystemReady(void);
extern void SeqAcc_InitPlaybackState(void);
int SeqPlay_ResetPlaybackState(void)
{
  unsigned char f;
  unsigned int t;

  SEQ_PLAY_FLAGS = 0;
  SEQ_RECORDED_TRACKS = 0;
  f = SEQ_METRO_FLAGS;
  f &= ~0x04;
  f &= ~0x02;
  f &= ~0x80;
  SEQ_METRO_FLAGS = f;
  if ((ram_f23c & 1) && SEQ_PUNCH_IN_MEASURE == SEQ_START_MEASURE)
    SEQ_RECORDED_TRACKS = SEQ_REC_TRACKS;
  TempoRingBuf_Init();
  t = SEQ_REC_TRACKS;
  if (t != 0) {
    SEQ_TRACK_MASK |= t;
    SEQ_CONTROL_FLAGS |= 0x08;
    Audio_CheckSubsystemReady();
    SEQ_PLAY_FLAGS |= 0x01;
    f = SEQ_METRO_FLAGS;
    if (f & 1) {
      f |= 0x02;
      SEQ_METRO_FLAGS = f;
      ram_2336 = SEQ_START_MEASURE;
    }
  }
  SeqAcc_InitPlaybackState();
  ram_22fc = (SEQ_METRO_FLAGS & 1) ? 12 : 11;
  return 0;
}
