/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_17a.c (2026-11-16-123-p6-r25)
   sha256 2441becdc5df439cc4c6958d347b445adac19bd939d6b2ee4eddd8e6118166c1 (tar-sha256); compiled at -Xr */
extern unsigned int __near SEQ_ACTIVE_PARTS;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near SEQ_PLAY_FLAGS;
extern unsigned char __near SEQ_SONG_RECORD[];
extern unsigned int __near SEQ_BEAT_COUNT;
extern unsigned int __near SEQ_PUNCH_IN_MEASURE;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned int __near SEQ_RECORDED_TRACKS;
extern unsigned int __near ram_2959;
extern void SeqPlay_ReactivatePartsAndResume(void);
void SeqPlay_CheckRepeatAndReactivate(void)
{
  unsigned int c, p, s, m;
  if (!(SEQ_PLAY_FLAGS & 0x01)) return;
  if (!(SEQ_SONG_RECORD[188] & 0x01)) return;
  c = SEQ_BEAT_COUNT;
  p = SEQ_PUNCH_IN_MEASURE;
  s = SEQ_START_MEASURE;
  if (s == p) {
    ram_2959 = c;
    m = SEQ_REC_TRACKS & SEQ_ACTIVE_PARTS;
    SEQ_RECORDED_TRACKS = m;
  } else {
    if (p != 1) return;
    if ((s & 0x8000L) == 0) return;
    ram_2959 = c;
    m = SEQ_REC_TRACKS & SEQ_ACTIVE_PARTS;
    SEQ_RECORDED_TRACKS = m;
  }
  SEQ_TRACK_MASK &= ~m;
  SeqPlay_ReactivatePartsAndResume();
}
