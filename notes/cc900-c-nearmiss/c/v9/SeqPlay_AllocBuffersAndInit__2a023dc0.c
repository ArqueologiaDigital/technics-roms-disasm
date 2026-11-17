/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v9/sequencer_engine_m234.c (2026-11-17-6-p6-r30-staged)
   sha256 2a023dc0cc11d6da31187f270d5d759d26ef31b36d80b1c38879091bc49068d8 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_BEAT_COUNT;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near SEQ_BEAT_TICK;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near ram_2328;
extern unsigned int __near ram_232a;
extern unsigned int __near ram_251c;
extern unsigned int __near ram_251e;
extern unsigned int __near ram_2520;
extern unsigned int __near ram_2522;
extern unsigned int SeqBuf_AllocNextSlot(unsigned int);
extern unsigned int SeqBuf_AllocNextSlotAdjusted(unsigned int);
extern void SeqPlay_InitializePlayback(void);
extern unsigned char SeqAcc_InitPlaybackState(void);
extern void SeqPlay_ResetStartState(void);
void SeqPlay_AllocBuffersAndInit(void)
{
  unsigned char c;
  unsigned int w, h;
  c = CURRENT_TITLE;
  if (c == 0x85 || c == 0x86) {
    if (!(SEQ_CYCLE_FLAGS & 0x02)) {
      ram_2328 = 0;
      SEQ_BEAT_COUNT = 0;
      SEQ_BEAT_TICK = 0;
      SEQ_RTMCFG &= ~0x08;
    } else {
      h = SeqBuf_AllocNextSlot(ram_2520);
      ram_2328 = h;
      SEQ_BEAT_COUNT = h;
      SEQ_BEAT_TICK = 0;
      if (h == 0) SEQ_RTMCFG &= ~0x08;
      else SEQ_RTMCFG |= 0x08;
      ram_232a = SeqBuf_AllocNextSlotAdjusted(ram_2522);
    }
    goto init;
  }
  w = SEQ_START_MEASURE;
  if (c == 0x87 || c == 0x88) {
    SEQ_BEAT_COUNT = SeqBuf_AllocNextSlot(w);
    SEQ_BEAT_TICK = 0;
init:
    SeqPlay_InitializePlayback();
  } else {
    if (SEQ_RTMCFG & 0x08) {
      SEQ_BEAT_COUNT = SeqBuf_AllocNextSlot(w);
      SEQ_BEAT_TICK = 0;
    }
    if (SEQ_CYCLE_FLAGS & 0x01) {
      ram_2328 = SeqBuf_AllocNextSlot(ram_251c);
      ram_232a = SeqBuf_AllocNextSlotAdjusted(ram_251e);
    }
    SeqAcc_InitPlaybackState();
  }
  SeqPlay_ResetStartState();
}
