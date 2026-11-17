/* Functions of sequencer/sequencer_engine.s.  Firmware C (cc900 phase 6), built with Toshiba V4.23; checked function by function
   against the ROM (notes/cc900-phase6-2026-11-16/staged_v423.tsv).
   Names are the tree's; ram_<hex> is a RAM cell the tree has not named yet.
   __near / __tiny: the cells the ROM reaches with 16 / 8-bit operands (V4.23 then declares them medium / small;
   a plain extern is large, 24-bit).  Each __near / __tiny declaration names one object: V4.23 applies the
   qualifier to the first declarator only.
   cc900-options: -O3 -Xr
*/
/* cc900-module: NotePool_InsertEntry SeqBuf_AllocNextSlot SeqBuf_AllocNextSlotAdjusted SeqPlay_ReactivatePartsAndResume SeqPlay_ResetStartState */   /* scripts/analysis/cc900/module_calls.py v10 */

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
extern void SeqPlay_AllocBuffersAndInit(void);

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
