/* nearmiss copy (scripts/analysis/cc900/nearmiss.py): the function and the declarations it uses of v6/sequencer_engine_m234.c (2026-11-17-6-p6-r30-staged)
   sha256 73b39f14ef82f8b539f349fbe233e231e33ad21804bd169a266a74dded273824 (tar-sha256); compiled at -O3 -XS -Xr
   cc900-options: -O3 -Xr */
extern unsigned char __near SEQ_CYCLE_FLAGS;
extern unsigned int __near SEQ_BEAT_COUNT;
extern unsigned int __near SEQ_START_MEASURE;
extern unsigned char __near CURRENT_TITLE;
extern unsigned char __near SEQ_BEAT_TICK;
extern unsigned char __near SEQ_RTMCFG;
extern unsigned int __near ram_2322;
extern unsigned int __near ram_2324;
extern unsigned int __near ram_2502;
extern unsigned int __near ram_2504;
extern unsigned int __near ram_2506;
extern unsigned int __near ram_2508;
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
      ram_2322 = 0;
      SEQ_BEAT_COUNT = 0;
      SEQ_BEAT_TICK = 0;
      SEQ_RTMCFG &= ~0x08;
    } else {
      h = SeqBuf_AllocNextSlot(ram_2506);
      ram_2322 = h;
      SEQ_BEAT_COUNT = h;
      SEQ_BEAT_TICK = 0;
      if (h == 0) SEQ_RTMCFG &= ~0x08;
      else SEQ_RTMCFG |= 0x08;
      ram_2324 = SeqBuf_AllocNextSlotAdjusted(ram_2508);
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
      ram_2322 = SeqBuf_AllocNextSlot(ram_2502);
      ram_2324 = SeqBuf_AllocNextSlotAdjusted(ram_2504);
    }
    SeqAcc_InitPlaybackState();
  }
  SeqPlay_ResetStartState();
}
