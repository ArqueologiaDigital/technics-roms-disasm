/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of firmware/p6_B_9m233.c (2026-11-16-87-p6-r15)
   sha256 61dc1f48693e38c3b38320feeddc7b560e801d2c1a71bcc7d4ca3abb43493648 (tar-sha256); compiled at -O3 -XS -Xr */
extern unsigned char __near ram_22fe;
extern unsigned int __near SEQ_TRACK_MASK;
extern unsigned char __near SEQ_TRANSPORT_STATE;
extern unsigned char __near SEQ_CONTROL_FLAGS;
extern unsigned int __near SEQ_REC_TRACKS;
extern unsigned char __near ACC_TRANSPORT_STATE;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near ram_8d38;
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near ram_2520;
extern unsigned int __near ram_2522;
extern unsigned int __near ram_251c;
extern unsigned int __near ram_251e;
extern unsigned int __near ram_2328;
extern unsigned int __near ram_232a;
extern unsigned int __near SEQ_BEAT_COUNT;
extern unsigned char __near SEQ_BEAT_TICK;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned char __near ram_11f4;
extern unsigned char __near ram_431;
extern unsigned char __near ram_28a6;
extern unsigned char __near ram_28ae;
extern unsigned int SeqBuf_AllocNextSlot(unsigned int);
extern unsigned int SeqBuf_AllocNextSlotAdjusted(unsigned int);
extern void NoteEditSy_SendModeScrollReset(void);
extern void BitMapOut_PrepareAndRender(int);
extern void SeqAcc_InitPlaybackState(void);
extern void MidiChannel_ResetAndConfigure(void);
void SeqPlay_CheckStartConditions(void)
{
  unsigned char a, c;
  unsigned int m, b, t;
  a = ram_22fe;
  if (a & 0x80) return;
  a |= 0x80;
  ram_22fe = a;
  if (SEQ_TRACK_MASK == 0) { a = ram_22fe; a &= ~0x80; ram_22fe = a; return; }
  a = ram_22fe;
  if (SEQ_TRANSPORT_STATE & 0x04) { a &= ~0x80; ram_22fe = a; return; }
  if (SEQ_CONTROL_FLAGS & 0x20) { a &= ~0x80; ram_22fe = a; return; }
  a = ram_22fe;
  if (SEQ_REC_TRACKS != 0) { a &= ~0x80; ram_22fe = a; return; }
  if (ACC_TRANSPORT_STATE & 0x04) { a &= ~0x80; ram_22fe = a; return; }
  m = SEQ_START_MEASURE;
  c = ram_8d38;
  if (c == 0x85 || c == 0x86) {
    if (!(SEQ_CYCLE_FLAGS & 0x02)) SEQ_START_MEASURE = 1;
    else {
      b = ram_2520;
      if (m <= b) { SEQ_START_MEASURE = 1; SEQ_BEAT_COUNT = 0; }
      else {
        SEQ_START_MEASURE = b;
        t = SeqBuf_AllocNextSlot(ram_2520);
        ram_2328 = t;
        SEQ_BEAT_COUNT = t;
        SEQ_BEAT_TICK = 0;
        ram_232a = SeqBuf_AllocNextSlotAdjusted(ram_2522);
      }
    }
    SEQ_BEAT_TICK = 0;
  } else {
    if (!(SEQ_CYCLE_FLAGS & 0x01)) SEQ_START_MEASURE = 1;
    else {
      b = ram_251c;
      if (m <= b) { SEQ_START_MEASURE = 1; SEQ_BEAT_COUNT = 0; }
      else {
        SEQ_START_MEASURE = b;
        t = SeqBuf_AllocNextSlot(ram_251c);
        ram_2328 = t;
        SEQ_BEAT_COUNT = t;
        SEQ_BEAT_TICK = 0;
        ram_232a = SeqBuf_AllocNextSlotAdjusted(ram_251e);
      }
    }
  }
  NoteEditSy_SendModeScrollReset();
  if (SEQ_START_MEASURE == 1) {
    SEQ_RTMCFG &= ~0x08;
    ram_11f4 = 0;
    BitMapOut_PrepareAndRender(0);
  } else SEQ_RTMCFG |= 0x08;
  SeqAcc_InitPlaybackState();
  ram_431 = 0;
  ram_28a6 &= ~0x01;
  ram_28ae &= ~0x80;
  MidiChannel_ResetAndConfigure();
  ram_22fe &= ~0x80;
}
