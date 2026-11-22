/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_S_31r1m232b.c (2026-11-22-15-p6-r82)
   sha256 c3d290443d272580e00a40db7161302c3e280b2f592e3b4199bca6ee5616d8d1 (tar-sha256); compiled at -O3 -Xr
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
  unsigned char f, m;
  unsigned int t;

  SEQ_PLAY_FLAGS = 0;
  SEQ_RECORDED_TRACKS = 0;
  SEQ_METRO_FLAGS &= ~0x86;
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
  m = 12;
  if (!(SEQ_METRO_FLAGS & 1))
    m = 11;
  ram_22fc = m;
  return 0;
}
